import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/market_data_source.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCrop = 'Wheat';
  String _selectedMandi = 'Ghazipur Mandi';
  String _timeRange = '7D';

  @override
  Widget build(BuildContext context) {
    final cropInfo = MarketDataRepository.getCropData(_selectedCrop);
    final mandiDetail = cropInfo.mandiPrices[_selectedMandi] ??
        cropInfo.mandiPrices.values.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Market Prices',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'बाज़ार मूल्य (मंडी भाव)',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.warningOrange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCropSelector(),
            const SizedBox(height: 16),
            _buildPriceCard(cropInfo, mandiDetail),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 12),
            _buildPriceChart(cropInfo),
            const SizedBox(height: 16),
            _buildSellingTip(cropInfo),
            const SizedBox(height: 16),
            _buildPriceForecast(cropInfo),
            const SizedBox(height: 16),
            _buildNearbyMandiSection(cropInfo),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCropSelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MarketDataRepository.crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final crop = MarketDataRepository.crops[index];
          final isSelected = crop == _selectedCrop;
          final cropData = MarketDataRepository.getCropData(crop);
          return GestureDetector(
            onTap: () => setState(() => _selectedCrop = crop),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.warningOrange : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.warningOrange : AppColors.lightGreen,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.warningOrange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${cropData.name} (${cropData.nameHi})',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceCard(CropStaticMarketInfo cropInfo, MandiPriceDetail mandiDetail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade700,
            Colors.deepOrange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${cropInfo.name} (${cropInfo.nameHi})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedMandi,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '₹${mandiDetail.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      mandiDetail.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      color: mandiDetail.isUp ? Colors.lightGreenAccent : Colors.yellowAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${mandiDetail.change} today',
                      style: TextStyle(
                        color: mandiDetail.isUp ? Colors.lightGreenAccent : Colors.yellowAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              cropInfo.unit,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.lightGreen),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedMandi,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.store, color: AppColors.warningOrange, size: 20),
              items: MarketDataRepository.mandis
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          m,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedMandi = v);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lightGreen),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: _timeRange,
            underline: const SizedBox(),
            icon: const Icon(Icons.calendar_today, color: AppColors.warningOrange, size: 18),
            items: ['7D', '30D', '90D']
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _timeRange = v);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceChart(CropStaticMarketInfo cropInfo) {
    final List<Map<String, dynamic>> rawData =
        cropInfo.trends[_timeRange] ?? cropInfo.trends['7D']!;

    // Adjust chart data based on selected Mandi price factor
    final mandiDetail = cropInfo.mandiPrices[_selectedMandi];
    final int basePrice = mandiDetail?.price ?? rawData.last['price'] as int;
    final int referenceLast = rawData.last['price'] as int;
    final int diff = basePrice - referenceLast;

    final data = rawData.map((d) {
      return {
        'label': d['label'] as String,
        'price': (d['price'] as int) + diff,
      };
    }).toList();

    double maxPrice = data
        .map((d) => d['price'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    double minPrice = data
        .map((d) => d['price'] as int)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();

    if (maxPrice == minPrice) {
      maxPrice += 100;
      minPrice -= 100;
    }

    final String timeFrameLabel = _timeRange == '7D'
        ? '7 Days (7 दिन)'
        : _timeRange == '30D'
            ? '30 Days (30 दिन)'
            : '90 Days (90 दिन)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.warningOrange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Trend - $timeFrameLabel',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedMandi,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(
                data: data,
                minPrice: minPrice,
                maxPrice: maxPrice,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data
                .map((d) => Text(
                      d['label'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSellingTip(CropStaticMarketInfo cropInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.amberAccent,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cropInfo.sellingTip,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cropInfo.sellingTipHi,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceForecast(CropStaticMarketInfo cropInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Forecast (मूल्य पूर्वानुमान)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.auto_graph, color: AppColors.primaryGreen, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: cropInfo.forecast.map((f) {
              final bool isUp = f['isUp'] as bool? ?? true;
              final Color badgeColor = isUp ? Colors.green : Colors.deepOrange;

              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        f['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${f['price']}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f['change'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            'Based on 30-day Agmarknet & e-NAM verified data',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyMandiSection(CropStaticMarketInfo cropInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.storefront, color: AppColors.primaryGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'Nearby Mandi Prices (आस-पास के मंडी भाव)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...cropInfo.nearbyMandis.map((m) {
          final String changeStr = m['change'] ?? '+1.0%';
          final bool isUp = !changeStr.startsWith('-');
          return Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.store, color: AppColors.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${cropInfo.name} (${cropInfo.unit})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      m['price']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      changeStr,
                      style: TextStyle(
                        color: isUp ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double minPrice;
  final double maxPrice;
  final Color color;

  _LineChartPainter({
    required this.data,
    required this.minPrice,
    required this.maxPrice,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartWidth = size.width;
    final chartHeight = size.height;
    const padding = 8.0;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.15)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 3; i++) {
      final dy = padding + i * ((chartHeight - 2 * padding) / 3);
      canvas.drawLine(
        Offset(padding, dy),
        Offset(chartWidth - padding, dy),
        gridPaint,
      );
    }

    // Draw line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    final stepX = (chartWidth - 2 * padding) / (data.length > 1 ? data.length - 1 : 1);

    for (int i = 0; i < data.length; i++) {
      final price = data[i]['price'] as int;
      final x = padding + i * stepX;
      final y = padding +
          ((maxPrice - price) / (maxPrice - minPrice)) *
              (chartHeight - 2 * padding);
      points.add(Offset(x, y));
    }

    // Fill area under curve
    final path = Path();
    path.moveTo(points.first.dx, chartHeight - padding);
    for (final p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(points.last.dx, chartHeight - padding);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Draw line connecting points
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 4.5, pointPaint);
      canvas.drawCircle(p, 4.5, pointBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
