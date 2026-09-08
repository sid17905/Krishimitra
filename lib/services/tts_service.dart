import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'ml_predictor_service.dart';

/// Text-to-Speech (TTS) Service for localized audio readouts across KrishiMitra.
class TtsService {
  TtsService._internal() {
    _initTts();
  }

  static final TtsService instance = TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String _currentPlayingText = '';
  bool _isInitialized = false;
  String _lastError = '';
  List<String> _availableLanguages = [];

  bool get isPlaying => _isPlaying;
  String get currentPlayingText => _currentPlayingText;
  String get lastError => _lastError;

  final ValueNotifier<bool> playingNotifier = ValueNotifier<bool>(false);

  static const Map<String, String> _languageLocaleMap = {
    'hi': 'hi-IN',
    'en': 'en-IN',
    'mr': 'mr-IN',
    'bn': 'bn-IN',
    'te': 'te-IN',
    'ta': 'ta-IN',
    'gu': 'gu-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
    'pa': 'pa-IN',
  };

  Future<void> _initTts() async {
    try {
      // Get available engines
      final dynamic engines = await _flutterTts.getEngines;
      debugPrint("Available TTS engines: $engines");
      
      if (Platform.isAndroid) {
        // Set Google TTS as engine
        try {
          await _flutterTts.setEngine('com.google.android.tts');
          debugPrint("Set TTS engine to Google TTS");
        } catch (e) {
          debugPrint("Could not set engine: $e");
        }


      }

      await _flutterTts.awaitSpeakCompletion(true);

      // Get available languages
      final dynamic languages = await _flutterTts.getLanguages;
      if (languages is List) {
        _availableLanguages = languages.map((e) => e.toString()).toList();
        debugPrint("Available TTS languages (${_availableLanguages.length}): ${_availableLanguages.take(20).join(', ')}...");
      }

      // Set default parameters
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      // Test speak to trigger voice data download prompt if needed
      // This will silently fail if no voice data, which is expected
      try {
        await _flutterTts.setLanguage('en-US');
      } catch (e) {
        debugPrint("Initial language set error: $e");
      }

    } catch (e) {
      debugPrint("TTS init configuration warning: $e");
      _lastError = e.toString();
    }

    // Set up handlers
    _flutterTts.setStartHandler(() {
      debugPrint("=== TTS STARTED SPEAKING ===");
      print("[TTS] === STARTED SPEAKING ===");
      _isPlaying = true;
      playingNotifier.value = true;
    });

    _flutterTts.setCompletionHandler(() {
      debugPrint("=== TTS COMPLETED SPEAKING ===");
      print("[TTS] === COMPLETED SPEAKING ===");
      _isPlaying = false;
      _currentPlayingText = '';
      playingNotifier.value = false;
    });

    _flutterTts.setCancelHandler(() {
      debugPrint("=== TTS CANCELLED ===");
      _isPlaying = false;
      _currentPlayingText = '';
      playingNotifier.value = false;
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("=== TTS ERROR: $msg ===");
      print("[TTS] === ERROR: $msg ===");
      _lastError = msg.toString();
      _isPlaying = false;
      _currentPlayingText = '';
      playingNotifier.value = false;
    });

    // Attempt to set progress handler for better debugging
    try {
      _flutterTts.setProgressHandler((text, start, end, word) {
        debugPrint("TTS progress: word '$word' at $start-$end");
      });
    } catch (e) {
      // Progress handler may not be available on all platforms
    }

    _isInitialized = true;
    debugPrint("=== TTS INITIALIZATION COMPLETE ===");
    print("[TTS] === INITIALIZATION COMPLETE ===");
  }

  Future<void> speak(String text, String languageCode) async {
    debugPrint("=== TTS SPEAK CALLED === text: '${text.substring(0, text.length > 50 ? 50 : text.length)}...', lang: $languageCode");
    print("[TTS] === SPEAK CALLED: lang=$languageCode, text='${text.substring(0, text.length > 30 ? 30 : text.length)}...' ===");

    if (text.trim().isEmpty) {
      debugPrint("TTS: Empty text, skipping");
      return;
    }

    if (_isPlaying && _currentPlayingText == text) {
      debugPrint("TTS: Same text playing, stopping");
      await stop();
      return;
    }

    await stop();

    if (!_isInitialized) {
      debugPrint("TTS: Re-initializing...");
      await _initTts();
    }

    // Clean text
    final cleanText = text
        .replaceAll(RegExp(r'[\*#_`~]'), '')
        .replaceAll(RegExp(r'[•►▪️🌱🌾💧🌡️📈⚠️🐛]'), '')
        .replaceAll(RegExp(r'₹'), 'Rupees ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleanText.isEmpty) {
      debugPrint("TTS: Clean text empty after processing, skipping");
      return;
    }

    debugPrint("TTS: Clean text to speak: '$cleanText'");

    // Set volume and rate
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5);
    } catch (e) {
      debugPrint("TTS: Error setting volume/rate: $e");
    }

    // Determine best language
    final targetLocale = _languageLocaleMap[languageCode] ?? 'hi-IN';
    String useLocale = targetLocale;
    
    // Check if target language is available, fallback to en-US or hi-IN
    bool langAvailable = _availableLanguages.contains(targetLocale);
    debugPrint("TTS: Target locale '$targetLocale' available: $langAvailable");
    
    if (!langAvailable) {
      // Try direct language code
      for (final entry in _languageLocaleMap.entries) {
        if (_availableLanguages.contains(entry.value)) {
          useLocale = entry.value;
          langAvailable = true;
          debugPrint("TTS: Using fallback locale '$useLocale' for language ${entry.key}");
          break;
        }
      }
      
      if (!langAvailable) {
        // Final fallback to English
        if (_availableLanguages.contains('en-US')) {
          useLocale = 'en-US';
        } else if (_availableLanguages.contains('en-IN')) {
          useLocale = 'en-IN';
        } else if (_availableLanguages.contains('hi-IN')) {
          useLocale = 'hi-IN';
        } else if (_availableLanguages.isNotEmpty) {
          useLocale = _availableLanguages.first;
        }
        debugPrint("TTS: Using fallback locale '$useLocale'");
      }
    }

    // Set language
    try {
      await _flutterTts.setLanguage(useLocale);
      debugPrint("TTS: Language set to '$useLocale'");
    } catch (e) {
      debugPrint("TTS: Error setting language '$useLocale': $e");
      // Try English as last resort
      try {
        await _flutterTts.setLanguage('en-US');
        debugPrint("TTS: Fell back to en-US");
      } catch (e2) {
        debugPrint("TTS: Could not set any language: $e2");
      }
    }

    _currentPlayingText = text;
    _isPlaying = true;
    playingNotifier.value = true;

    // Speak
    try {
      debugPrint("TTS: Calling flutterTts.speak()...");
      final result = await _flutterTts.speak(cleanText);
      debugPrint("TTS: speak() returned: $result");
    } catch (e) {
      debugPrint("TTS SPEAK EXCEPTION: $e");
      _lastError = e.toString();
      _isPlaying = false;
      _currentPlayingText = '';
      playingNotifier.value = false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _isPlaying = false;
    _currentPlayingText = '';
    playingNotifier.value = false;
  }

  Future<bool> isLanguageAvailable(String languageCode) async {
    final locale = _languageLocaleMap[languageCode] ?? languageCode;
    return _availableLanguages.contains(locale);
  }

  Future<void> speakCropResult(CropPredictionResult result, String languageCode) async {
    final text = languageCode == 'hi'
        ? 'फसल उपयुक्तता: ${result.cropHi} ${(result.confidence * 100).toStringAsFixed(0)} प्रतिशत। ${result.reasoningHi}'
        : 'Crop: ${result.crop} with ${(result.confidence * 100).toStringAsFixed(0)}% match. ${result.reasoning}';
    await speak(text, languageCode);
  }

  Future<void> speakFertilizerResult(FertilizerRecommendation fert, String languageCode) async {
    final text = languageCode == 'hi'
        ? 'उर्वरक: यूरिया ${fert.ureaKgPerAcre.toStringAsFixed(0)} किलो, डीएपी ${fert.dapKgPerAcre.toStringAsFixed(0)} किलो, पोटाश ${fert.mopKgPerAcre.toStringAsFixed(0)} किलो प्रति एकड़।'
        : 'Fertilizers: Urea ${fert.ureaKgPerAcre.toStringAsFixed(0)} kg, DAP ${fert.dapKgPerAcre.toStringAsFixed(0)} kg, Potash ${fert.mopKgPerAcre.toStringAsFixed(0)} kg per acre.';
    await speak(text, languageCode);
  }

  Future<void> speakYieldResult(YieldPredictionResult yieldRes, String languageCode) async {
    final text = languageCode == 'hi'
        ? 'उपज: ${yieldRes.optimizedYieldTonPerHa.toStringAsFixed(1)} टन प्रति हेक्टेयर। अतिरिक्त आय ${yieldRes.estimatedIncomeGainPerAcre.toInt()} रुपये प्रति एकड़।'
        : 'Yield: ${yieldRes.optimizedYieldTonPerHa.toStringAsFixed(1)} tons per hectare. Extra income: ${yieldRes.estimatedIncomeGainPerAcre.toInt()} rupees per acre.';
    await speak(text, languageCode);
  }

  Future<void> speakDiagnosis(String diagnosisText, String languageCode) async {
    await speak(diagnosisText, languageCode);
  }

  Future<void> speakMarketPrice(String cropName, int price, String change, String languageCode) async {
    final text = languageCode == 'hi'
        ? '$cropName का भाव $price रुपये प्रति क्विंटल।'
        : '$cropName price is $price rupees per quintal.';
    await speak(text, languageCode);
  }

  Future<void> speakWeatherAdvisory(String advisory, String languageCode) async {
    await speak(advisory, languageCode);
  }

  Future<void> speakSensorData(double moisture, double temp, double humidity, double ph, String languageCode) async {
    final text = languageCode == 'hi'
        ? 'नमी ${moisture.toStringAsFixed(0)} प्रतिशत, तापमान ${temp.toStringAsFixed(0)} डिग्री, पीएच ${ph.toStringAsFixed(1)}।'
        : 'Moisture ${moisture.toStringAsFixed(0)} percent, Temperature ${temp.toStringAsFixed(0)} degrees, pH ${ph.toStringAsFixed(1)}.';
    await speak(text, languageCode);
  }
}
