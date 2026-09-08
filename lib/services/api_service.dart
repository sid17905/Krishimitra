import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sensor_data.dart';
import '../models/market_price.dart';
import '../models/weather_data.dart';
import '../models/alert.dart';
import 'knowledge_base_service.dart';
import 'ml_predictor_service.dart';

class ApiService {
  // Base URLs for government APIs
  static const String imdBaseUrl = 'https://mausam.imd.gov.in/api';
  static const String agmarknetUrl = 'https://agmarknet.gov.in';
  static const String cpcbUrl = 'https://app.cpcbccr.com';
  static const String bhuwanUrl = 'https://bhuwan.gov.in';
  static const String localApiBase = 'http://localhost:8000/api';
  
  // ==========================================
  // AI CONFIGURATION (Loaded safely from .env)
  // ==========================================
  static String get groqApiKey {
    try {
      if (dotenv.isInitialized) {
        final key = (dotenv.env['GROQ_API_KEY'] ?? '').trim();
        if (key.isNotEmpty) return key;
      }
    } catch (_) {}
    return const String.fromEnvironment('GROQ_API_KEY', defaultValue: '').trim();
  }

  static String get geminiApiKey {
    try {
      if (dotenv.isInitialized) {
        final key = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
        if (key.isNotEmpty) return key;
      }
    } catch (_) {}
    return const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '').trim();
  }

  static const List<String> _candidateGroqModels = [
    'qwen/qwen3.8-27b',
    'openai/gpt-oss-120b',
    'openai/gpt-oss-20b',
    'llama-3.3-70b-versatile',
    'llama-3.1-8b-instant',
  ];
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Prompts LLM (Groq or Gemini) with dynamic sensor context.
  ///
  /// The prompt is GROUNDED two ways:
  ///  1. Live-ish ESP32 sensor telemetry (soil, NPK, pH...).
  ///  2. Retrieval-Augmented Generation over the farmer's own local documents
  ///     in `assets/knowledge/` via [KnowledgeBaseService]. Relevant snippets
  ///     are injected so answers reflect YOUR files, not just generic training.
  Future<String> askAI(String query) async {
    try {
      final sensorDataList = await fetchSensorData();
      final sensorData = sensorDataList.isNotEmpty ? sensorDataList.first : null;

      String systemContext = "You are KrishiMitra, an expert agronomy AI assistant for Indian smallholder farmers. ";
      systemContext += "Reply concisely and clearly, prioritizing actionable advice. Use bullet points and emojis. ";
      systemContext += "Provide bilingual responses if appropriate (English and Hindi). ";
      systemContext += "When the LOCAL KNOWLEDGE section is provided, prefer it over general knowledge and mention the source file. ";

      if (sensorData != null) {
        systemContext += "\n\nReal-time telemetry from the farmer's ESP32 field node:\n";
        systemContext += "• Soil Moisture: ${sensorData.moisture}%\n";
        systemContext += "• Temperature: ${sensorData.temperature}°C\n";
        systemContext += "• Humidity: ${sensorData.humidity}%\n";
        systemContext += "• Soil pH: ${sensorData.ph}\n";
        systemContext += "• Soil NPK (mg/kg): N=${sensorData.npkN}, P=${sensorData.npkP}, K=${sensorData.npkK}\n";

        // ---- Background ML Predictor Calculations ----
        final cropPred = MLPredictorService.instance.predictBestCrop(sensorData);
        final fertPred = MLPredictorService.instance.optimizeFertilizers(sensorData, 'Wheat');
        final yieldPred = MLPredictorService.instance.predictYield(sensorData, 'Wheat');

        systemContext += "\nBackground ML Engine Diagnostics (Explain these simply to the farmer without jargon):\n";
        systemContext += "• Best Suited Crop: ${cropPred.crop} (${(cropPred.confidence * 100).toInt()}% match)\n";
        systemContext += "• Fertilizer Optimization Needed: Urea ${fertPred.ureaKgPerAcre} kg/acre, DAP ${fertPred.dapKgPerAcre} kg/acre, MOP ${fertPred.mopKgPerAcre} kg/acre\n";
        systemContext += "• pH Advice: ${fertPred.phCorrection}\n";
        systemContext += "• Expected Yield Boost: +${yieldPred.yieldGainPercent}% (Est. +₹${yieldPred.estimatedIncomeGainPerAcre.toInt()}/acre extra income)\n";
      }

      // ---- RAG: ground the answer on local knowledge files ----
      // Ensure the index is built (no-op after the first call), then retrieve.
      await KnowledgeBaseService.instance.load();
      final ragContext = KnowledgeBaseService.instance.buildContext(query, k: 3);
      if (ragContext.isNotEmpty) {
        systemContext += "\n\n===== LOCAL KNOWLEDGE (retrieved from farmer's documents) =====\n";
        systemContext += ragContext;
        systemContext += "\n===== END LOCAL KNOWLEDGE =====\n";
      }

      final groqKey = groqApiKey;
      final geminiKey = geminiApiKey;

      // Check if Groq API key is provided
      if (groqKey.isNotEmpty && groqKey != 'your_groq_api_key_here') {
        return await _callGroq(systemContext, query, groqKey);
      }

      // Check if Gemini API key is provided
      if (geminiKey.isNotEmpty && geminiKey != 'your_gemini_api_key_here') {
        return await _callGemini(systemContext, query, geminiKey);
      }

      // Fallback message if neither key is set in .env
      return "⚠️ Setup Needed: Please enter your GROQ_API_KEY in the '.env' file to enable live, ultra-fast unscripted AI responses!";
    } catch (e) {
      return "🤖 An error occurred while processing the AI request: $e";
    }
  }

  /// Ultra-fast Groq LPU Inference with automatic model fallback
  Future<String> _callGroq(String systemContext, String query, String apiKey) async {
    String lastError = '';
    for (final model in _candidateGroqModels) {
      try {
        final response = await http.post(
          Uri.parse(_groqUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': systemContext},
              {'role': 'user', 'content': query},
            ],
            'temperature': 0.6,
            'max_tokens': 800,
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          return data['choices'][0]['message']['content'].toString().trim();
        } else {
          lastError = "Groq ($model error ${response.statusCode}): ${response.body}";
          // If model not found or forbidden, try next candidate
          continue;
        }
      } catch (e) {
        lastError = "Groq ($model connection error): $e";
        continue;
      }
    }
    return "🤖 Groq Engine Note: $lastError";
  }

  /// Google Gemini 1.5 Flash Inference
  Future<String> _callGemini(String systemContext, String query, String apiKey) async {
    final promptText = "$systemContext\n\nFarmer's Query: $query";
    final response = await http.post(
      Uri.parse('$_geminiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': promptText}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final answer = data['candidates'][0]['content']['parts'][0]['text'];
      return answer.toString().trim();
    } else {
      return "🤖 Gemini API Error (${response.statusCode}): ${response.body}";
    }
  }

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
      dailyForecast: const [
        DailyForecast(day: 'Today', maxTemp: 28, minTemp: 18, rainChance: 0, condition: 'Sunny'),
        DailyForecast(day: 'Tomorrow', maxTemp: 27, minTemp: 17, rainChance: 10, condition: 'Cloudy'),
        DailyForecast(day: 'Wed', maxTemp: 26, minTemp: 16, rainChance: 60, condition: 'Rain'),
        DailyForecast(day: 'Thu', maxTemp: 25, minTemp: 15, rainChance: 80, condition: 'Storm'),
        DailyForecast(day: 'Fri', maxTemp: 27, minTemp: 17, rainChance: 20, condition: 'Cloudy'),
      ],
      nowcast: const [
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
