import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../core/localization_ext.dart';
import '../../models/sensor_data.dart';
import '../../services/tts_service.dart';
import '../../services/ml_predictor_service.dart';

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
  final double _npkN = 45.0;
  final double _npkP = 22.0;
  final double _npkK = 35.0;
  bool _showPredictions = false;
  CropPredictionResult? _cropResult;
  FertilizerRecommendation? _fertResult;
  bool _isPredicting = false;

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
    TtsService.instance.stop();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _runPrediction() async {
    if (_isPredicting) return;
    setState(() => _isPredicting = true);
    try {
      // Build sensor data from current readings
      final sensor = SensorData(
        id: 'esp32-001',
        name: 'Field Unit #1 (Block A)',
        moisture: _moisture,
        temperature: _temperature,
        humidity: _humidity,
        ph: _ph,
        npkN: _npkN,
        npkP: _npkP,
        npkK: _npkK,
        timestamp: DateTime.now(),
      );
      final cropResult = MLPredictorService.instance.predictBestCrop(sensor);
      final fertResult = MLPredictorService.instance.optimizeFertilizers(sensor, 'Wheat');
      if (mounted) {
        setState(() {
          _cropResult = cropResult;
          _fertResult = fertResult;
          _showPredictions = true;
          _isPredicting = false;
        });
        // Auto-read predictions aloud in farmer's language
        final lang = context.langCode;
        TtsService.instance.speakCropResult(cropResult, lang);
        TtsService.instance.speakFertilizerResult(fertResult, lang);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPredicting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.tr('sensor_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.waterBlue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isConnected
                ? Icons.bluetooth_connected
                : Icons.bluetooth_disabled),
            onPressed: () => setState(() => _isConnected = !_isConnected),
            tooltip: 'Toggle Bluetooth Node',
          ),
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.playingNotifier,
            builder: (context, isPlaying, child) => IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.volume_up),
              onPressed: () => TtsService.instance.speakSensorData(
                _moisture,
                _temperature,
                _humidity,
                _ph,
                context.langCode,
              ),
              tooltip: context.tr('read_out'),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.playingNotifier,
            builder: (context, isPlaying, child) => IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.psychology_alt),
              onPressed: _isPredicting
                  ? null
                  : () async {
                      if (_cropResult == null || _fertResult == null) {
                        await _runPrediction();
                      } else {
                        final lang = context.langCode;
                        TtsService.instance.speakCropResult(_cropResult!, lang);
                        TtsService.instance.speakFertilizerResult(_fertResult!, lang);
                      }
                    },
              tooltip: context.tr('read_ai_predictions'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatus(),
            const SizedBox(height: 14),
            _buildPredictorTrigger(),
            const SizedBox(height: 14),
            _buildSensorCard(
              title: context.tr('soil_moisture'),
              icon: Icons.water_drop_rounded,
              value: '${_moisture.toStringAsFixed(0)}%',
              range: 'Optimal: 40-70%',
              color: AppColors.waterBlue,
              status: _isMoistureOptimal()
                  ? context.tr('optimal')
                  : context.tr('caution'),
            ),
            const SizedBox(height: 10),
            _buildSensorCard(
              title: context.tr('temp_label'),
              icon: Icons.thermostat_rounded,
              value: '${_temperature.toStringAsFixed(1)}°C',
              range: 'Optimal: 15-35°C',
              color: AppColors.warningOrange,
              status: context.tr('normal'),
            ),
            const SizedBox(height: 10),
            _buildSensorCard(
              title: context.tr('humidity_label'),
              icon: Icons.water_rounded,
              value: '${_humidity.toStringAsFixed(0)}%',
              range: 'Optimal: 30-85%',
              color: AppColors.primaryGreen,
              status: context.tr('normal'),
            ),
            const SizedBox(height: 10),
            _buildSensorCard(
              title: context.tr('soil_ph'),
              icon: Icons.science_rounded,
              value: _ph.toStringAsFixed(1),
              range: 'Crops prefer 6.0-7.5',
              color: Colors.purple,
              status: _ph > 7.5
                  ? context.tr('high')
                  : (_ph < 6 ? context.tr('low') : context.tr('optimal')),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('npk_levels'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildNPKBar(
              label: context.tr('nitrogen'),
              value: _npkN,
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            _buildNPKBar(
              label: context.tr('phosphorus'),
              value: _npkP,
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            _buildNPKBar(
              label: context.tr('potassium'),
              value: _npkK,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            if (_showPredictions) ...[
              const SizedBox(height: 16),
              _buildPredictionResults(),
              const SizedBox(height: 16),
            ],
            _buildHistoryChart(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _isMoistureOptimal() {
    return _moisture >= 40 && _moisture <= 70;
  }

  Widget _buildPredictorTrigger() {
    return GestureDetector(
      onTap: _isPredicting ? null : _runPrediction,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome,
                color: AppColors.primaryGreen, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: _isPredicting
                  ? const Text(
                      'Running AI prediction...',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen),
                    )
                  : const Text(
                      'Run AI Crop & Fertilizer Optimizer on these readings',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen),
                    ),
            ),
            if (_isPredicting) const SizedBox(width: 8),
            if (_isPredicting)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('ai_predictions'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_cropResult != null) ...[
            Text(
              '${context.langCode == 'hi' ? 'अनुशंसित फसल' : 'Best Crop'}: ${_cropResult!.crop} (${_cropResult!.cropHi})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${context.langCode == 'hi' ? 'उपयुक्तता' : 'Suitability'}: ${(_cropResult!.confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.langCode == 'hi' ? _cropResult!.reasoningHi : _cropResult!.reasoning,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_fertResult != null) ...[
            Text(
              context.tr('fertilizer_optimizer'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text('Urea: ${_fertResult!.ureaKgPerAcre} kg/ac'),
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Chip(
                  label: Text('DAP: ${_fertResult!.dapKgPerAcre} kg/ac'),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Chip(
                  label: Text('MOP: ${_fertResult!.mopKgPerAcre} kg/ac'),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.langCode == 'hi' ? _fertResult!.organicAdviceHi : _fertResult!.organicAdvice,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isConnected ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.circle : Icons.circle_outlined,
            size: 14,
            color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected
                ? context.tr('sensor_connected')
                : context.tr('sensor_disconnected'),
            style: TextStyle(
              color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.sensors,
            color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
            size: 18,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  range,
                  style: const TextStyle(
                    fontSize: 11.5,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: status == context.tr('optimal') ||
                          status == context.tr('normal')
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 8,
                backgroundColor: color.withOpacity(0.12),
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${value.toStringAsFixed(0)} mg/kg',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChart() {
    final List<double> data = [45, 52, 48, 60, 55, 65, 58, 72];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('moisture_trend'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      height: data[index] * 1.2,
                      decoration: BoxDecoration(
                        color: data[index] >= 70
                            ? Colors.orange.shade400
                            : AppColors.waterBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${data[index].toInt()}',
                          style: const TextStyle(
                            fontSize: 9,
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
