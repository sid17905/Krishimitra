class Alert {
  final String id;
  final String type; // Nowcast, Contamination, Advisory
  final String severity; // High, Medium, Info
  final String title;
  final String description;
  final String location;
  final DateTime timestamp;
  final bool isRead;
  final String suggestedAction;
  final String source;

  const Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.suggestedAction,
    this.isRead = false,
    this.source = 'KRISHI_MITRA',
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'Medium',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      suggestedAction: json['suggested_action'] ?? '',
      isRead: json['is_read'] ?? false,
      source: json['source'] ?? 'KRISHI_MITRA',
    );
  }
}
