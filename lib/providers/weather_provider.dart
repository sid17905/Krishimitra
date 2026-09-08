import 'package:flutter/foundation.dart';
import '../core/api_exception.dart';
import '../core/result_state.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

/// Holds the weather screen's async state and exposes it as a [ResultState].
///
/// The screen listens to this provider and renders:
///   • [LoadingState]  → shimmer skeleton
///   • [SuccessState]  → the weather UI + LIVE/OFFLINE badge
///   • [ErrorState]    → an error card with a Retry button
///
/// Keeping this logic in a ChangeNotifier (not the widget's setState) means the
/// state survives widget rebuilds and can be shared/tested in isolation.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider({WeatherService? service})
      : _service = service ?? WeatherService();

  final WeatherService _service;

  ResultState<WeatherData> _state = const LoadingState();
  ResultState<WeatherData> get state => _state;

  bool get isLive => _service.isLive;

  // Selectable agricultural districts across India (label -> lat/lon)
  static const Map<String, ({double lat, double lon})> locations = {
    'Ghazipur, UP': (lat: 25.58, lon: 83.58),
    'Varanasi, UP': (lat: 25.32, lon: 82.97),
    'Kanpur, UP': (lat: 26.45, lon: 80.33),
    'Patna, Bihar': (lat: 25.59, lon: 85.14),
    'Muzaffarpur, Bihar': (lat: 26.12, lon: 85.39),
    'Pune, Maharashtra': (lat: 18.52, lon: 73.86),
    'Nashik, Maharashtra': (lat: 19.99, lon: 73.79),
    'Ludhiana, Punjab': (lat: 30.90, lon: 75.85),
    'Karnal, Haryana': (lat: 29.68, lon: 76.99),
    'Indore, MP': (lat: 22.72, lon: 75.86),
    'Jaipur, Rajasthan': (lat: 26.91, lon: 75.79),
    'Rajkot, Gujarat': (lat: 22.30, lon: 70.80),
    'Bengaluru, Karnataka': (lat: 12.97, lon: 77.59),
    'Hyderabad, Telangana': (lat: 17.38, lon: 78.48),
    'Coimbatore, Tamil Nadu': (lat: 11.01, lon: 76.96),
    'Burdwan, West Bengal': (lat: 23.23, lon: 87.86),
  };

  String _selectedLocation = 'Ghazipur, UP';
  String get selectedLocation => _selectedLocation;

  /// Change location and immediately reload weather for it.
  Future<void> selectLocation(String label) async {
    if (!locations.containsKey(label) || label == _selectedLocation) return;
    _selectedLocation = label;
    await load();
  }

  /// Fetches weather for the current location, driving the state machine.
  /// Called on first build, on pull-to-refresh, and on retry.
  Future<void> load() async {
    _state = const LoadingState();
    notifyListeners();

    final coord = locations[_selectedLocation]!;
    try {
      final data = await _service.fetchWeather(
        lat: coord.lat,
        lon: coord.lon,
        placeLabel: _selectedLocation,
      );
      _state = SuccessState(data);
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
