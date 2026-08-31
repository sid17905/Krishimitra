class SensorData {
  final String id;
  final String name;
  final double moisture;
  final double temperature;
  final double humidity;
  final double ph;
  final double npkN;
  final double npkP;
  final double npkK;
  final DateTime timestamp;
  final bool isOnline;

  const SensorData({
    required this.id,
    required this.name,
    required this.moisture,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.npkN,
    required this.npkP,
    required this.npkK,
    required this.timestamp,
    this.isOnline = true,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      moisture: (json['moisture'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
      npkN: (json['npk_n'] ?? 0).toDouble(),
      npkP: (json['npk_p'] ?? 0).toDouble(),
      npkK: (json['npk_k'] ?? 0).toDouble(),
        timestamp: DateTime.parse(
            json['timestamp'] ?? DateTime.now().toIso8601String()),
        isOnline: json['is_online'] ?? true,
    );
  }
}
