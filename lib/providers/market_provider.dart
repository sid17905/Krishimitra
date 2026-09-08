import 'package:flutter/foundation.dart';
import '../core/api_exception.dart';
import '../core/result_state.dart';
import '../models/market_price.dart';
import '../models/market_data_source.dart';
import '../services/market_service.dart';

/// Holds the market screen's async state as a [ResultState] list of prices.
///
/// Mirrors [WeatherProvider]: the screen renders shimmer / data / error-retry
/// based on [state], and pull-to-refresh + crop selection both call [load].
class MarketProvider extends ChangeNotifier {
  MarketProvider({MarketService? service})
      : _service = service ?? MarketService();

  final MarketService _service;

  ResultState<List<MarketPrice>> _state = const LoadingState();
  ResultState<List<MarketPrice>> get state => _state;

  bool get isLive => _service.isLive;

  List<String> get crops => MarketDataRepository.crops;

  String _selectedCrop = 'Wheat';
  String get selectedCrop => _selectedCrop;

  /// Switch the crop and reload live prices for it.
  Future<void> selectCrop(String crop) async {
    if (crop == _selectedCrop) return;
    _selectedCrop = crop;
    await load();
  }

  /// Fetch prices for the current crop, driving loading→success/error.
  Future<void> load() async {
    _state = const LoadingState();
    notifyListeners();

    try {
      final prices = await _service.fetchPrices(crop: _selectedCrop);
      // Sort highest price first so the best mandi surfaces at the top.
      prices.sort((a, b) => b.pricePerQuintal.compareTo(a.pricePerQuintal));
      _state = SuccessState(prices);
    } on ApiException catch (e) {
      _state = ErrorState(e.message, isTimeout: e.isTimeout);
    } catch (e) {
      _state = ErrorState('Unexpected error: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
