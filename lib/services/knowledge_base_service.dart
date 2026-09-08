import 'dart:math';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:flutter/foundation.dart';

/// One retrievable chunk of local knowledge (a slice of a source document).
class KnowledgeChunk {
  final String sourceFile; // e.g. "crop_calendar.md"
  final String heading; // nearest heading for context
  final String text; // the chunk body
  final Set<String> tokens; // pre-tokenized terms for fast scoring

  KnowledgeChunk({
    required this.sourceFile,
    required this.heading,
    required this.text,
  }) : tokens = _tokenize('$heading $text').toSet();

  static Iterable<String> _tokenize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u0900-\u097F\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2);
}

/// On-device Retrieval-Augmented Generation (RAG) engine.
///
/// WHAT IT DOES
///  1. Scans `assets/knowledge/` for local `.md` / `.txt` files that you drop
///     into the project (crop calendars, scheme docs, agronomy notes, the
///     farmer's own field records, etc.).
///  2. Splits each file into overlapping chunks and indexes them in memory.
///  3. On a query, retrieves the most relevant chunks using a lightweight
///     TF-IDF cosine similarity (fully on-device, no server, no embeddings API
///     required — deterministic and offline-friendly).
///  4. Returns a compact "context block" that the caller injects into the LLM
///     prompt so the AI answers are GROUNDED in your specific files rather than
///     only its generic training data.
///
/// WHY THIS APPROACH (vs. vector embeddings):
///  • Zero extra network calls / API cost and works fully offline.
///  • Deterministic and debuggable for a demo/eval setting.
///  • The retrieved chunks slot straight into the existing Groq/Gemini prompt.
///  • If you later want semantic embeddings, `retrieve()` is the single seam to
///    swap TF-IDF for a vector store — the rest of the app is unaffected.
class KnowledgeBaseService {
  KnowledgeBaseService._();
  static final KnowledgeBaseService instance = KnowledgeBaseService._();

  static const String _dir = 'assets/knowledge/';

  final List<KnowledgeChunk> _chunks = [];
  final Map<String, double> _idf = {}; // term → inverse document frequency
  bool _loaded = false;
  int _fileCount = 0;

  bool get isLoaded => _loaded;
  int get chunkCount => _chunks.length;
  int get fileCount => _fileCount;

  /// Scans and indexes all local knowledge files. Safe to call more than once;
  /// only the first call does the work.
  Future<void> load() async {
    if (_loaded) return;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assetPaths = manifest
          .listAssets()
          .where((p) =>
              p.startsWith(_dir) &&
              (p.endsWith('.md') || p.endsWith('.txt')))
          .toList();

      final seenFiles = <String>{};
      for (final path in assetPaths) {
        final content = await rootBundle.loadString(path);
        final fileName = path.split('/').last;
        seenFiles.add(fileName);
        _indexDocument(fileName, content);
      }
      _fileCount = seenFiles.length;
      _computeIdf();
      _loaded = true;
      debugPrint(
          'KnowledgeBase: indexed $_fileCount file(s), ${_chunks.length} chunk(s).');
    } catch (e) {
      debugPrint('KnowledgeBase load error: $e');
      _loaded = true; // don't retry forever; app still works without RAG
    }
  }

  /// Splits a document into heading-aware, overlapping chunks and stores them.
  void _indexDocument(String fileName, String content) {
    // Track the most recent markdown heading so each chunk keeps its context.
    final lines = content.split('\n');
    String currentHeading = fileName;
    final buffer = <String>[];

    void flush() {
      final body = buffer.join(' ').trim();
      if (body.isNotEmpty) {
        _chunks.add(KnowledgeChunk(
          sourceFile: fileName,
          heading: currentHeading,
          text: body,
        ));
      }
      buffer.clear();
    }

    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('#')) {
        // New heading → close the previous chunk.
        flush();
        currentHeading = line.replaceAll('#', '').trim();
        continue;
      }
      if (line.isEmpty) {
        // Paragraph break → chunk boundary once the buffer is sizeable.
        if (buffer.join(' ').length > 240) flush();
        continue;
      }
      buffer.add(line);
      // Hard cap so a huge paragraph still becomes multiple chunks.
      if (buffer.join(' ').length > 600) flush();
    }
    flush();
  }

  /// Computes inverse-document-frequency weights across all chunks.
  void _computeIdf() {
    final docFreq = <String, int>{};
    for (final c in _chunks) {
      for (final term in c.tokens) {
        docFreq[term] = (docFreq[term] ?? 0) + 1;
      }
    }
    final n = _chunks.length;
    _idf.clear();
    docFreq.forEach((term, df) {
      // Smoothed idf.
      _idf[term] = (1 + (n / (df + 1))).abs().let(log);
    });
  }

  /// Returns the top-[k] most relevant chunks for [query] using TF-IDF cosine.
  List<KnowledgeChunk> retrieve(String query, {int k = 3}) {
    if (_chunks.isEmpty) return const [];
    final qTokens = KnowledgeChunk._tokenize(query).toList();
    if (qTokens.isEmpty) return const [];

    // Build query vector (term → tf-idf weight).
    final qVec = <String, double>{};
    for (final t in qTokens) {
      qVec[t] = (qVec[t] ?? 0) + (_idf[t] ?? 0);
    }
    final qNorm = _norm(qVec.values);
    if (qNorm == 0) return const [];

    final scored = <MapEntry<KnowledgeChunk, double>>[];
    for (final c in _chunks) {
      double dot = 0;
      final cVec = <String, double>{};
      for (final t in c.tokens) {
        final w = _idf[t] ?? 0;
        cVec[t] = w;
        if (qVec.containsKey(t)) dot += w * qVec[t]!;
      }
      final cNorm = _norm(cVec.values);
      if (cNorm == 0) continue;
      final score = dot / (qNorm * cNorm);
      if (score > 0) scored.add(MapEntry(c, score));
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(k).map((e) => e.key).toList();
  }

  /// Convenience: retrieve and format a ready-to-inject prompt context block.
  /// Returns an empty string when nothing relevant is found.
  String buildContext(String query, {int k = 3}) {
    final hits = retrieve(query, k: k);
    if (hits.isEmpty) return '';
    final sb = StringBuffer();
    sb.writeln(
        'Use the following verified local knowledge from the farmer\'s own '
        'documents to ground your answer. Cite the source file when relevant.');
    for (var i = 0; i < hits.length; i++) {
      final h = hits[i];
      sb.writeln('\n[Source ${i + 1}: ${h.sourceFile} › ${h.heading}]');
      sb.writeln(h.text);
    }
    return sb.toString();
  }

  double _norm(Iterable<double> values) {
    double sum = 0;
    for (final v in values) {
      sum += v * v;
    }
    return sqrt(sum);
  }
}

/// Small helper so we can write `x.let(fn)` (Kotlin-style) for readability.
extension _Let<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}
