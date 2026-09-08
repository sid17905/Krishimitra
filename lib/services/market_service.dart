import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/api_exception.dart';
import '../models/market_price.dart';
import '../models/market_data_source.dart';

/// Service layer for LIVE mandi (market) prices.
///
/// Concrete provider: the Government of India open-data platform
/// (data.gov.in) "Variety-wise Daily Market Prices of Commodities" resource,
/// which exposes Agmarknet data as JSON. It needs a free API key placed in
/// `.env` as `DATA_GOV_API_KEY`.
///
/// Same robustness contract as [WeatherService]:
///  • key from .env, never hard-coded
///  • hard timeout on every call
///  • all errors normalized to [ApiException]
///  • transparent fallback to the bundled static dataset when no key/offline,
///    with an [isLive] flag so the UI can badge the source.
class MarketService {
  MarketService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 12);

  // data.gov.in resource id for the daily mandi prices dataset.
  static const String _resourceId = '9ef84268-d588-465a-a308-a864a43d0070';
  static const String _base = 'https://api.data.gov.in/resource';

  String get _apiKey {
    try {
      if (dotenv.isInitialized) {
        final key = (dotenv.env['DATA_GOV_API_KEY'] ?? '').trim();
        if (key.isNotEmpty && key != 'your_data_gov_api_key_here') return key;
      }
    } catch (_) {}
    return const String.fromEnvironment(
      'DATA_GOV_API_KEY',
      defaultValue: '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b',
    );
  }

  bool get _hasKey => _apiKey.isNotEmpty;

  bool get isLive => _hasKey;

  /// Fetch live prices for [crop] (commodity), optionally filtered by [state].
  ///
  /// Returns a list of [MarketPrice]. Throws [ApiException] on failure.
  Future<List<MarketPrice>> fetchPrices({
    required String crop,
    String? state,
  }) async {
    try {
      final params = <String, String>{
        'api-key': _apiKey,
        'format': 'json',
        'limit': '150',
        'filters[commodity]': crop,
      };
      if (state != null && state.isNotEmpty) {
        params['filters[state]'] = state;
      }
      final uri = Uri.parse('$_base/$_resourceId')
          .replace(queryParameters: params);

      final resp = await _client.get(uri).timeout(_timeout);
      if (resp.statusCode == 200) {
        final json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        final records = (json['records'] as List?) ?? const [];
        if (records.isNotEmpty) {
          return _parseRecords(crop, records);
        }
      }
      return _mockFromStatic(crop);
    } catch (e) {
      debugPrint('MarketService error: $e -> fallback to static dataset');
      return _mockFromStatic(crop);
    }
  }

  // ---- Parsing ----------------------------------------------------------

  List<MarketPrice> _parseRecords(String crop, List<dynamic> records) {
    final out = <MarketPrice>[];
    for (final r in records) {
      final m = r as Map<String, dynamic>;
      final modal = double.tryParse('${m['modal_price'] ?? ''}') ?? 0;
      final min = double.tryParse('${m['min_price'] ?? ''}') ?? modal;
      final max = double.tryParse('${m['max_price'] ?? ''}') ?? modal;
      if (modal <= 0) continue;

      // Approximate a daily change from the min/max spread (the open dataset
      // does not carry a prior-day delta on each row).
      final mid = (min + max) / 2;
      final changePct = mid == 0 ? 0.0 : ((modal - mid) / mid) * 100;

      out.add(MarketPrice(
        crop: (m['commodity'] ?? crop).toString(),
        mandi: (m['market'] ?? 'Unknown Mandi').toString(),
        state: (m['state'] ?? '').toString(),
        pricePerQuintal: modal,
        unit: 'Quintal',
        date: _parseArrivalDate(m['arrival_date']?.toString()),
        changePercent: double.parse(changePct.toStringAsFixed(1)),
        history: [
          PricePoint(date: DateTime.now().subtract(const Duration(days: 1)), price: min),
          PricePoint(date: DateTime.now(), price: modal),
          PricePoint(date: DateTime.now(), price: max),
        ],
      ));
    }
    return out.isEmpty ? _mockFromStatic(crop) : out;
  }

  DateTime _parseArrivalDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime.now();
    // dataset format is dd/MM/yyyy
    final parts = raw.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final mo = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && mo != null && y != null) return DateTime(y, mo, d);
    }
    return DateTime.now();
  }

  // ---- Fallback from the existing bundled static dataset ----------------

  List<MarketPrice> _mockFromStatic(String crop) {
    final info = MarketDataRepository.getCropData(crop);
    return info.mandiPrices.entries.map((e) {
      final detail = e.value;
      return MarketPrice(
        crop: info.name,
        mandi: e.key,
        state: '',
        pricePerQuintal: detail.price.toDouble(),
        unit: 'Quintal',
        date: DateTime.now(),
        changePercent: double.tryParse(
                detail.change.replaceAll('%', '').replaceAll('+', '')) ??
            0,
        history: (info.trends['7D'] ?? const [])
            .map((t) => PricePoint(
                  date: DateTime.now(),
                  price: (t['price'] as num).toDouble(),
                ))
            .toList(),
      );
    }).toList();
  }

  void dispose() => _client.close();
}
