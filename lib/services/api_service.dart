import 'dart:convert';
import 'dart:async';
import '../models/sensor_data.dart';
import '../models/market_price.dart';
import '../models/weather_data.dart';
import '../models/alert.dart';

class ApiService {
  // Base URLs for government APIs
  static const String imdBaseUrl = 'https://mausam.imd.gov.in/api';
  static const String agmarknetUrl = 'https://agmarknet.gov.in';
  static const String cpcbUrl = 'https://app.cpcbccr.com';
  static const String bhuwanUrl = 'https://bhuwan.gov.in';
  static const String localApiBase = 'http://localhost:8000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Fetches sensor data from local ESP32 gateway / backend
  Future<List<SensorData>> fetchSensorData() async {
    try {
      // In production, call your backend API which is connected to ESP32
      // final response = await http.get(Uri.parse('$localApiBase/sensors'));

      // For prototype, return mock data
      return _mockSensorData();
    } catch (e) {
      // Fall back to mock data in prototype
      return _mockSensorData();
    }
  }

  /// Fetch market prices from Agmarknet/e-NAM
  Future<List<MarketPrice>> fetchMarketPrices({
    String? crop,
    String? mandi,
  }) async {
    try {
      // In production, call Agmarknet API
      // final response = await http.get(Uri.parse('$agmarknetUrl/...'));

      return _mockMarketPrices();
    } catch (e) {
      return _mockMarketPrices();
    }
  }

  /// Fetch weather data from IMD
  Future<WeatherData> fetchWeatherData({
    required String latitude,
    required String longitude,
  }) async {
    try {
      // In production, call IMD API
      // final response = await http.get(Uri.parse('$imdBaseUrl/weather?lat=$latitude&lon=$longitude'));

      return _mockWeatherData();
    } catch (e) {
      return _mockWeatherData();
    }
  }

  /// Fetch contamination alerts from CPCB/NWMP + sensor cross-match
  Future<List<Alert>> fetchAlerts() async {
    try {
      // In production, call backend which fuses ESP32 sensor + CPCB data
      return _mockAlerts();
    } catch (e) {
      return _mockAlerts();
    }
  }

  // Mock data for prototype demonstration
  List<SensorData> _mockSensorData() {
    final now = DateTime.now();
    return [
      SensorData(
        id: 'esp32-001',
        name: 'Field Unit #1 (Block A)',
        moisture: 65,
        temperature: 28.5,
        humidity: 72,
        ph: 6.8,
        npkN: 45,
        npkP: 22,
        npkK: 35,
        timestamp: now,
      ),
      SensorData(
        id: 'esp32-002',
        name: 'Field Unit #2 (Block B)',
        moisture: 72,
        temperature: 27.1,
        humidity: 68,
        ph: 7.2,
        npkN: 40,
        npkP: 18,
        npkK: 30,
        timestamp: now,
      ),
    ];
  }

  List<MarketPrice> _mockMarketPrices() {
    return [
      MarketPrice(
        crop: 'Wheat',
        mandi: 'Ghazipur Mandi',
        state: 'Uttar Pradesh',
        pricePerQuintal: 2340,
        unit: 'Quintal',
        date: DateTime.now(),
        changePercent: 2.5,
        history: [
          PricePoint(date: DateTime.now().subtract(const Duration(days: 1)), price: 2280),
          PricePoint(date: DateTime.now().subtract(const Duration(days: 2)), price: 2260),
          PricePoint(date: DateTime.now().subtract(const Duration(days: 3)), price: 2300),
        ],
      ),
      MarketPrice(
        crop: 'Rice',
        mandi: 'Ghazipur Mandi',
        state: 'Uttar Pradesh',
        pricePerQuintal: 1980,
        unit: 'Quintal',
        date: DateTime.now(),
        changePercent: -1.2,
        history: [
          PricePoint(date: DateTime.now().subtract(const Duration(days: 1)), price: 2010),
          PricePoint(date: DateTime.now().subtract(const Duration(days: 2)), price: 2005),
          PricePoint(date: DateTime.now().subtract(const Duration(days: 3)), price: 1995),
        ],
      ),
    ];
  }

  WeatherData _mockWeatherData() {
    return WeatherData(
      location: 'Ghazipur',
      district: 'Ghazipur',
      state: 'Uttar Pradesh',
      temperature: 28,
      humidity: 72,
      windSpeed: 12,
      windDirection: 'SW',
      rainfall: 0,
      condition: 'Mostly Sunny',
      lastUpdated: DateTime.now(),
      dailyForecast: [
        DailyForecast(day: 'Today', maxTemp: 28, minTemp: 18, rainChance: 0, condition: 'Sunny'),
        DailyForecast(day: 'Tomorrow', maxTemp: 27, minTemp: 17, rainChance: 10, condition: 'Cloudy'),
        DailyForecast(day: 'Wed', maxTemp: 26, minTemp: 16, rainChance: 60, condition: 'Rain'),
        DailyForecast(day: 'Thu', maxTemp: 25, minTemp: 15, rainChance: 80, condition: 'Storm'),
        DailyForecast(day: 'Fri', maxTemp: 27, minTemp: 17, rainChance: 20, condition: 'Cloudy'),
      ],
      nowcast: [
        NowcastAlert(
          type: 'Thunderstorm',
          severity: 'High',
          description: 'Thunderstorm approaching in 2 hours',
          timeToArrivalHours: 2,
          source: 'IMD',
        ),
      ],
    );
  }

  List<Alert> _mockAlerts() {
    return [
      Alert(
        id: '1',
        type: 'Nowcast',
        severity: 'High',
        title: 'Thunderstorm Warning',
        description: 'Thunderstorm approaching with wind speeds up to 40km/h',
        location: 'Ghazipur, UP',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        suggestedAction: 'Secure crop covers and avoid fieldwork',
      ),
      Alert(
        id: '2',
        type: 'Contamination',
        severity: 'Medium',
        title: 'EC Spikes Detected',
        description: 'Soil EC spike near sensor #3. CPCB data shows runoff risk.',
        location: 'Field - Block B',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        suggestedAction: 'Verify water source and contact local agriculture officer',
      ),
    ];
  }
}
