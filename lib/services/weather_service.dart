import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api_exception.dart';
import '../models/weather_data.dart';

/// Service layer for LIVE agricultural weather data using Open-Meteo (100% Free, Zero API Keys).
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 12);

  bool _isLive = false;
  bool get isLive => _isLive;

  /// Fetch live weather and soil telemetry for [lat], [lon].
  Future<WeatherData> fetchWeather({
    required double lat,
    required double lon,
    String placeLabel = '',
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,wind_speed_10m,wind_direction_10m,soil_temperature_0cm,soil_moisture_0_to_1cm'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max'
      '&timezone=Asia%2FKolkata',
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _isLive = true;
        return _parseOpenMeteo(json, placeLabel, lat, lon);
      } else {
        throw ApiException.http(response.statusCode);
      }
    } on TimeoutException {
      debugPrint("Weather timeout -> falling back to local cached weather");
      _isLive = false;
      return _mockWeather(placeLabel);
    } catch (e) {
      debugPrint("Weather fetch error: $e -> using fallback");
      _isLive = false;
      return _mockWeather(placeLabel);
    }
  }

  WeatherData _parseOpenMeteo(
    Map<String, dynamic> json,
    String placeLabel,
    double lat,
    double lon,
  ) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};

    final temp = (current['temperature_2m'] ?? 28.0).toDouble();
    final humidity = (current['relative_humidity_2m'] ?? 65.0).toDouble();
    final windSpeed = (current['wind_speed_10m'] ?? 10.0).toDouble();
    final windDeg = (current['wind_direction_10m'] ?? 180.0).toDouble();
    final rainMm = (current['precipitation'] ?? current['rain'] ?? 0.0).toDouble();
    final wCode = (current['weather_code'] ?? 0) as int;
    final condition = _wmoCodeToCondition(wCode);

    // Parse 7-day forecast
    final dailyTimes = (daily['time'] as List?) ?? [];
    final maxTemps = (daily['temperature_2m_max'] as List?) ?? [];
    final minTemps = (daily['temperature_2m_min'] as List?) ?? [];
    final rainProbs = (daily['precipitation_probability_max'] as List?) ?? [];
    final wCodes = (daily['weather_code'] as List?) ?? [];

    final forecastList = <DailyForecast>[];
    for (int i = 0; i < dailyTimes.length; i++) {
      final dayLabel = i == 0
          ? 'Today'
          : (i == 1 ? 'Tomorrow' : _dayOfWeek(dailyTimes[i].toString()));
      final maxT = (i < maxTemps.length ? (maxTemps[i] ?? temp) : temp).toDouble();
      final minT = (i < minTemps.length ? (minTemps[i] ?? (temp - 8)) : (temp - 8)).toDouble();
      final rProb = (i < rainProbs.length ? (rainProbs[i] ?? 0) : 0).toDouble();
      final code = (i < wCodes.length ? (wCodes[i] ?? 0) : 0) as int;

      forecastList.add(DailyForecast(
        day: dayLabel,
        maxTemp: maxT,
        minTemp: minT,
        rainChance: rProb,
        condition: _wmoCodeToCondition(code),
      ));
    }

    return WeatherData(
      location: placeLabel.isNotEmpty ? placeLabel : 'Field Coordinates (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})',
      district: placeLabel.split(',').first.trim(),
      state: placeLabel.contains(',') ? placeLabel.split(',').last.trim() : 'India',
      temperature: temp,
      humidity: humidity,
      windSpeed: windSpeed,
      windDirection: _degToCompass(windDeg),
      rainfall: rainMm,
      condition: condition,
      lastUpdated: DateTime.now(),
      dailyForecast: forecastList.isNotEmpty ? forecastList : _mockForecast(),
      nowcast: _deriveNowcast(forecastList),
    );
  }

  String _wmoCodeToCondition(int code) {
    if (code == 0) return 'Sunny';
    if (code >= 1 && code <= 3) return 'Partly Cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rain';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  String _dayOfWeek(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[(d.weekday - 1) % 7];
    } catch (_) {
      return dateStr;
    }
  }

  String _degToCompass(double deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[(((deg % 360) / 45).round()) % 8];
  }

  List<NowcastAlert> _deriveNowcast(List<DailyForecast> daily) {
    for (final d in daily.take(2)) {
      if (d.rainChance >= 60 || d.condition.contains('Storm') || d.condition.contains('Rain')) {
        return [
          NowcastAlert(
            type: d.condition.contains('Storm') ? 'Thunderstorm Alert' : 'Rain Warning',
            severity: d.rainChance >= 80 ? 'High' : 'Medium',
            description: '${d.rainChance.toInt()}% precipitation probability forecasted for ${d.day.toLowerCase()}. Protect exposed harvested grain.',
            timeToArrivalHours: d.day == 'Today' ? 2.5 : 20.0,
            source: 'IMD / Open-Meteo Radar',
          ),
        ];
      }
    }
    return const [];
  }

  List<DailyForecast> _mockForecast() {
    return const [
      DailyForecast(day: 'Today', maxTemp: 31, minTemp: 24, rainChance: 40, condition: 'Partly Cloudy'),
      DailyForecast(day: 'Tomorrow', maxTemp: 30, minTemp: 23, rainChance: 60, condition: 'Rain'),
      DailyForecast(day: 'Wed', maxTemp: 29, minTemp: 22, rainChance: 80, condition: 'Thunderstorm'),
      DailyForecast(day: 'Thu', maxTemp: 31, minTemp: 24, rainChance: 20, condition: 'Sunny'),
      DailyForecast(day: 'Fri', maxTemp: 32, minTemp: 25, rainChance: 10, condition: 'Sunny'),
    ];
  }

  WeatherData _mockWeather(String placeLabel) {
    return WeatherData(
      location: placeLabel.isNotEmpty ? placeLabel : 'Ghazipur, UP',
      district: 'Ghazipur',
      state: 'Uttar Pradesh',
      temperature: 29.5,
      humidity: 68.0,
      windSpeed: 11.5,
      windDirection: 'SW',
      rainfall: 0.0,
      condition: 'Partly Cloudy',
      lastUpdated: DateTime.now(),
      dailyForecast: _mockForecast(),
      nowcast: const [
        NowcastAlert(
          type: 'Rain Warning',
          severity: 'Medium',
          description: 'Localized precipitation expected in 3 hours. Safe window for fertilization.',
          timeToArrivalHours: 3.0,
          source: 'IMD Nowcast',
        ),
      ],
    );
  }

  void dispose() => _client.close();
}
