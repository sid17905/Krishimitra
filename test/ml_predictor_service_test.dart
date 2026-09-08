import 'package:flutter_test/flutter_test.dart';
import 'package:krishimitra/models/sensor_data.dart';
import 'package:krishimitra/services/ml_predictor_service.dart';

void main() {
  group('MLPredictorService Tests (SIH 2026 Telemetry Models)', () {
    final sampleSensor = SensorData(
      id: 'esp32-001',
      name: 'Farm 01 Field Unit',
      moisture: 65.0,
      temperature: 28.5,
      humidity: 72.0,
      ph: 6.8,
      npkN: 45.0,
      npkP: 22.0,
      npkK: 35.0,
      timestamp: DateTime.now(),
    );

    test('predictBestCrop classifies Wheat as top match for sample NPK', () {
      final result = MLPredictorService.instance.predictBestCrop(sampleSensor);

      expect(result.crop, 'Wheat');
      expect(result.cropHi, 'गेहूं');
      expect(result.confidence, greaterThan(0.8));
      expect(result.topRanked, isNotEmpty);
    });

    test('optimizeFertilizers calculates proper NPK dosages & pH advice', () {
      final fert = MLPredictorService.instance.optimizeFertilizers(sampleSensor, 'Wheat');

      expect(fert.ureaKgPerAcre, greaterThan(0));
      expect(fert.dapKgPerAcre, greaterThan(0));
      expect(fert.mopKgPerAcre, greaterThan(0));
      expect(fert.soilHealthScore, greaterThan(70));
    });

    test('predictYield estimates yield uplift and economic gain', () {
      final yieldRes = MLPredictorService.instance.predictYield(sampleSensor, 'Wheat');

      expect(yieldRes.optimizedYieldTonPerHa, greaterThan(yieldRes.baseYieldTonPerHa));
      expect(yieldRes.yieldGainPercent, greaterThan(15.0));
      expect(yieldRes.estimatedIncomeGainPerAcre, greaterThan(5000));
    });
  });
}
