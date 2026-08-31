class MarketPrice {
  final String crop;
  final String mandi;
  final String state;
  final double pricePerQuintal;
  final String unit;
  final DateTime date;
  final double changePercent;
  final List<PricePoint> history;

  const MarketPrice({
    required this.crop,
    required this.mandi,
    required this.state,
    required this.pricePerQuintal,
    required this.unit,
    required this.date,
    required this.changePercent,
    required this.history,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    final historyJson = json['history'] as List? ?? [];
    return MarketPrice(
      crop: json['crop'] ?? '',
      mandi: json['mandi'] ?? '',
      state: json['state'] ?? '',
      pricePerQuintal: (json['price_per_quintal'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'Quintal',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      changePercent: (json['change_percent'] ?? 0).toDouble(),
      history: historyJson
          .map((h) => PricePoint.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PricePoint {
  final DateTime date;
  final double price;

  const PricePoint({required this.date, required this.price});

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
