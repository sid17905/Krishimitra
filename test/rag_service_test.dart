import 'package:flutter_test/flutter_test.dart';
import 'package:krishimitra/services/knowledge_base_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KnowledgeChunk & TF-IDF Retrieval Tests', () {
    test('KnowledgeChunk extracts alphanumeric tokens and ignores small words', () {
      final chunk = KnowledgeChunk(
        sourceFile: 'wheat_schedule.md',
        heading: 'Basal Dose',
        text: 'Apply DAP at 55 kg per acre plus MOP at 20 kg per acre.',
      );

      expect(chunk.tokens, contains('apply'));
      expect(chunk.tokens, contains('dap'));
      expect(chunk.tokens, contains('acre'));
      expect(chunk.tokens, isNot(contains('at'))); // <= 2 letters ignored
    });

    test('KnowledgeBaseService index and retrieval returns grounded context', () async {
      final kb = KnowledgeBaseService.instance;
      await kb.load();

      // Retrieve for a fertilizer query
      final fertilizerHits = kb.retrieve('What is the fertilizer schedule for wheat?');
      expect(fertilizerHits, isNotEmpty);
      expect(fertilizerHits.first.sourceFile, contains('wheat'));

      // Retrieve for a pest/aphids query
      final pestHits = kb.retrieve('How to treat aphids and yellow leaves?');
      expect(pestHits, isNotEmpty);
      expect(
        pestHits.any((h) => h.text.toLowerCase().contains('aphids') || h.text.toLowerCase().contains('neem') || h.text.toLowerCase().contains('yellow')),
        isTrue,
      );

      // Build context prompt block
      final contextBlock = kb.buildContext('wheat fertilizer DAP urea');
      expect(contextBlock, contains('verified local knowledge'));
      expect(contextBlock, contains('wheat_fertilizer_schedule.md'));
    });
  });
}
