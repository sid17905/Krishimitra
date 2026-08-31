class WeatherData {
  final String location;
  final String district;
  final String state;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double rainfall;
  final String condition;
  final DateTime lastUpdated;
  final List<DailyForecast> dailyForecast;
  final List<NowcastAlert> nowcast;

  const WeatherData({
    required this.location,
    required this.district,
    required this.state,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.rainfall,
    required this.condition,
    required this.lastUpdated,
    required this.dailyForecast,
    required this.nowcast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final dailyJson = json['daily_forecast'] as List? ?? [];
    final nowcastJson = json['nowcast'] as List? ?? [];
    return WeatherData(
      location: json['location'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      windSpeed: (json['wind_speed'] ?? 0).toDouble(),
      windDirection: json['wind_direction'] ?? 'N',
      rainfall: (json['rainfall'] ?? 0).toDouble(),
      condition: json['condition'] ?? 'Clear',
      lastUpdated:
          DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
      dailyForecast: dailyJson
          .map((d) => DailyForecast.fromJson(d as Map<String, dynamic>))
          .toList(),
      nowcast: nowcastJson
          .map((n) => NowcastAlert.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyForecast {
  final String day;
  final double maxTemp;
  final double minTemp;
  final double rainChance;
  final String condition;

  const DailyForecast({
    required this.day,
    required this.maxTemp,
    required this.minTemp,
    required this.rainChance,
    required this.condition,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      day: json['day'] ?? '',
      maxTemp: (json['max_temp'] ?? 0).toDouble(),
      minTemp: (json['min_temp'] ?? 0).toDouble(),
      rainChance: (json['rain_chance'] ?? 0).toDouble(),
      condition: json['condition'] ?? 'Clear',
    );
  }
}

class NowcastAlert {
  final String type;
  final String severity;
  final String description;
  final double timeToArrivalHours;
  final String source;

  const NowcastAlert({
    required this.type,
    required this.severity,
    required this.description,
    required this.timeToArrivalHours,
    required this.source,
  });

  factory NowcastAlert.fromJson(Map<String, dynamic> json) {
    return NowcastAlert(
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'Medium',
      description: json['description'] ?? '',
      timeToArrivalHours: (json['time_to_arrival_hours'] ?? 0).toDouble(),
      source: json['source'] ?? 'IMD',
    );
  }
}
