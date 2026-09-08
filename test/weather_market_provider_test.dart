import 'package:flutter_test/flutter_test.dart';
import 'package:krishimitra/core/result_state.dart';
import 'package:krishimitra/services/weather_service.dart';
import 'package:krishimitra/services/market_service.dart';
import 'package:krishimitra/providers/weather_provider.dart';
import 'package:krishimitra/providers/market_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WeatherService & WeatherProvider Tests', () {
    test('WeatherService returns fallback mock data when no API key is provided', () async {
      final service = WeatherService();
      final data = await service.fetchWeather(lat: 25.58, lon: 83.58, placeLabel: 'Ghazipur, UP');

      expect(data.location, 'Ghazipur, UP');
      expect(data.temperature, 29.5);
      expect(data.dailyForecast, isNotEmpty);
      expect(service.isLive, isFalse);
    });

    test('WeatherProvider transitions from LoadingState to SuccessState', () async {
      final provider = WeatherProvider();
      expect(provider.state.isLoading, isTrue);

      await provider.load();

      expect(provider.state.isSuccess, isTrue);
      final data = provider.state.dataOrNull;
      expect(data, isNotNull);
      expect(data!.location, contains('Ghazipur'));
    });

    test('WeatherProvider location change triggers reload', () async {
      final provider = WeatherProvider();
      await provider.selectLocation('Pune, Maharashtra');

      expect(provider.selectedLocation, 'Pune, Maharashtra');
      expect(provider.state.isSuccess, isTrue);
      expect(provider.state.dataOrNull?.location, 'Pune, Maharashtra');
    });
  });

  group('MarketService & MarketProvider Tests', () {
    test('MarketService returns fallback prices for Wheat', () async {
      final service = MarketService();
      final prices = await service.fetchPrices(crop: 'Wheat');

      expect(prices, isNotEmpty);
      expect(prices.first.crop, 'Wheat');
      expect(prices.first.pricePerQuintal, greaterThan(0));
    });

    test('MarketProvider transitions state and sorts highest price first', () async {
      final provider = MarketProvider();
      await provider.load();

      expect(provider.state.isSuccess, isTrue);
      final prices = provider.state.dataOrNull!;
      expect(prices, isNotEmpty);
      
      // Verify descending price sort order
      for (int i = 0; i < prices.length - 1; i++) {
        expect(prices[i].pricePerQuintal >= prices[i + 1].pricePerQuintal, isTrue);
      }
    });

    test('MarketProvider switches crop to Rice', () async {
      final provider = MarketProvider();
      await provider.selectCrop('Rice');

      expect(provider.selectedCrop, 'Rice');
      expect(provider.state.isSuccess, isTrue);
      expect(provider.state.dataOrNull?.first.crop, 'Rice');
    });
  });
}
