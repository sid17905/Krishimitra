import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class SensorDashboardScreen extends StatefulWidget {
  const SensorDashboardScreen({super.key});

  @override
  State<SensorDashboardScreen> createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  bool _isConnected = true;
  Timer? _updateTimer;
  double _moisture = 65.0;
  double _temperature = 28.5;
  double _humidity = 72.0;
  double _ph = 6.8;
  double _npkN = 45.0;
  double _npkP = 22.0;
  double _npkK = 35.0;

  @override
  void initState() {
    super.initState();
    // Simulate real-time sensor updates
    _updateTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => setState(() {
        _moisture = (60 + (_moisture * 0.8) % 20).clamp(30, 90);
        _temperature = (26 + (_temperature * 0.7) % 8);
        _humidity = (60 + (_humidity * 0.7) % 25);
        _ph = (6.2 + (_ph * 0.9) % 1.5);
      }),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ESP32 Field Sensors'),
        backgroundColor: AppColors.waterBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => setState(() => _isConnected = !_isConnected),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatus(),
            const SizedBox(height: 16),
            _buildSensorCard(
              title: 'Soil Moisture',
              icon: Icons.water_drop,
              value: '${_moisture.toStringAsFixed(0)}%',
              range: 'Optimal: 40-70%',
              color: AppColors.waterBlue,
              status: _isMoistureOptimal() ? 'Optimal' : 'Caution',
            ),
            const SizedBox(height: 12),
            _buildSensorCard(
              title: 'Temperature',
              icon: Icons.thermostat,
              value: '${_temperature.toStringAsFixed(1)}°C',
              range: 'Optimal: 15-35°C',
              color: AppColors.warningOrange,
              status: 'Normal',
            ),
            const SizedBox(height: 12),
            _buildSensorCard(
              title: 'Humidity',
              icon: Icons.water,
              value: '${_humidity.toStringAsFixed(0)}%',
              range: 'Optimal: 30-85%',
              color: AppColors.primaryGreen,
              status: 'Normal',
            ),
            const SizedBox(height: 12),
            _buildSensorCard(
              title: 'Soil pH',
              icon: Icons.science,
              value: _ph.toStringAsFixed(1),
              range: 'Crops prefer 6.0-7.5',
              color: Colors.purple,
              status: _ph > 7.5 ? 'High' : (_ph < 6 ? 'Low' : 'Optimal'),
            ),
            const SizedBox(height: 24),
            Text(
              'NPK Nutrient Levels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildNPKBar(
              label: 'Nitrogen (N)',
              value: _npkN,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildNPKBar(
              label: 'Phosphorous (P)',
              value: _npkP,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildNPKBar(
              label: 'Potassium (K)',
              value: _npkK,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            _buildHistoryChart(),
          ],
        ),
      ),
    );
  }

  bool _isMoistureOptimal() {
    return _moisture >= 40 && _moisture <= 70;
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isConnected ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.circle : Icons.circle_outlined,
            size: 16,
            color: _isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected
                ? 'ESP32 Connected - Field Unit #1'
                : 'ESP32 Disconnected',
            style: TextStyle(
              color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.sensors,
            color: _isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required IconData icon,
    required String value,
    required String range,
    required Color color,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  range,
                  style: const TextStyle(
                    fontSize: 12,
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
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: status == 'Optimal' || status == 'Normal'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNPKBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.1),
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${value.toStringAsFixed(0)} mg/kg',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChart() {
    // Simplified historical data bar chart
    final List<double> data = [45, 52, 48, 60, 55, 65, 58, 72];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '24-Hour Moisture Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      height: data[index] * 1.5,
                      decoration: BoxDecoration(
                        color: data[index] >= 70
                            ? Colors.orange
                            : Colors.blue.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${data[index]}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
