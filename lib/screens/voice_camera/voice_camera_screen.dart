import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../core/localization_ext.dart';
import '../../services/api_service.dart';
import '../../services/knowledge_base_service.dart';
import '../../services/tts_service.dart';

class VoiceCameraScreen extends StatefulWidget {
  const VoiceCameraScreen({super.key});

  @override
  State<VoiceCameraScreen> createState() => _VoiceCameraScreenState();
}

class _VoiceCameraScreenState extends State<VoiceCameraScreen> {
  bool _isListening = false;
  bool _isLoading = false;
  String _aiResponse = '';
  String _userQuery = '';
  Timer? _timer;
  int _waveformBars = 12;
  final TextEditingController _customQueryController = TextEditingController();

  final List<Map<String, String>> _quickQuestions = const [
    {
      'icon': '🌾',
      'q': 'What fertilizer for wheat?',
      'qHi': 'गेहूं के लिए किस खाद का उपयोग करें?',
      'ans': '🌾 Wheat Fertilizer Recommendation:\n'
          '• Basal Dose: DAP (55 kg/acre) + MOP (20 kg/acre) at sowing.\n'
          '• 1st Top Dressing (CRI Stage, 21-25 days): Urea 45 kg/acre + Zinc Sulphate.\n'
          '• 2nd Top Dressing (Late Tillering, 45 days): Urea 45 kg/acre.\n'
          '⚠️ Soil Check: Current Nitrogen is moderate (45 mg/kg).',
    },
    {
      'icon': '🐛',
      'q': 'Identify pest from photo',
      'qHi': 'फोटो से कीट की पहचान करें',
      'ans': '🐛 Image Analysis Result:\n'
          '• Detected: Aphids (माहू / चेपा) on leaf undersides (94% confidence).\n'
          '• Immediate Action: Spray Neem Oil 1500 PPM @ 5ml/L water.\n'
          '• Chemical Option: Imidacloprid 17.8% SL @ 0.5ml/L if infestation > 15%.',
    },
    {
      'icon': '💧',
      'q': 'When should I water?',
      'qHi': 'मुझे पानी कब देना चाहिए?',
      'ans': '💧 Irrigation Advisory:\n'
          '• Current Soil Moisture: 65% (Optimal Range: 40-70%).\n'
          '• Next Irrigation Window: In 3 to 4 days.\n'
          '• IMD Forecast: Light rain (10%) expected tomorrow, avoid overwatering today.',
    },
    {
      'icon': '📈',
      'q': 'Best time to sell?',
      'qHi': 'बेचने का सबसे अच्छा समय?',
      'ans': '📈 Market Price Advisory:\n'
          '• Current Wheat Mandi Price: ₹2,340/quintal (+2.5% today).\n'
          '• 7-Day Forecast: Projected to reach ₹2,400.\n'
          '• Recommendation: Favorable selling window in 10-14 days for optimal margins.',
    },
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _customQueryController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _startListening() {
    TtsService.instance.stop();
    setState(() {
      _isListening = true;
      _aiResponse = '';
      _userQuery = '';
    });
    _timer = Timer.periodic(
      const Duration(milliseconds: 300),
      (t) => setState(() {
        _waveformBars = 8 + (DateTime.now().second % 8);
      }),
    );
    // Simulate speech detection
    Timer(const Duration(seconds: 3), () {
      if (mounted) _stopListeningAndAskAI('Why are my wheat leaves turning yellow? (मेरे गेहूं के पत्ते पीले क्यों हो रहे हैं?)');
    });
  }

  void _stopListening() {
    if (_isListening) {
      _stopListeningAndAskAI('Why are my wheat leaves turning yellow? (मेरे गेहूं के पत्ते पीले क्यों हो रहे हैं?)');
    }
  }

  Future<void> _stopListeningAndAskAI(String query) async {
    _timer?.cancel();
    setState(() {
      _isListening = false;
      _isLoading = true;
      _userQuery = query;
    });

    final response = await ApiService().askAI(query);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _aiResponse = response;
      });
      // Voice-first: Read out the answer in the current language
      TtsService.instance.speak(response, context.langCode);
    }
  }

  void _handleQuickQuestion(Map<String, String> item) async {
    final query = '${item['q']!} (${item['qHi']!})';
    setState(() {
      _isLoading = true;
      _userQuery = query;
      _aiResponse = '';
    });

    final response = await ApiService().askAI(query);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _aiResponse = response;
      });
      // Voice-first: Read out the answer in the current language
      TtsService.instance.speak(response, context.langCode);
    }
  }

  Future<void> _submitCustomQuery() async {
    final query = _customQueryController.text.trim();
    if (query.isEmpty) return;

    _customQueryController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _userQuery = query;
      _aiResponse = '';
    });

    final response = await ApiService().askAI(query);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _aiResponse = response;
      });
      // Voice-first: Read out the answer in the current language
      TtsService.instance.speak(response, context.langCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              context.tr('voice'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              'आवाज़ सहायक (Live AI Engine)',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              _handleQuickQuestion(_quickQuestions[1]);
            },
            tooltip: 'Camera Diagnosis',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAssistantHeader(),
            const SizedBox(height: 16),
            _buildVoiceVisualization(),
            const SizedBox(height: 16),
            Text(
              _isListening
                  ? 'Listening to speech... (सुन रहा हूँ...)'
                  : (context.langCode == 'hi' ? 'माइक दबाएं या नीचे कोई भी कृषि प्रश्न पूछें' : 'Tap the mic or ask ANY agricultural question below'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            _buildCustomQueryInput(),
            const SizedBox(height: 14),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primaryGreen),
                    const SizedBox(height: 12),
                    Text(
                      context.langCode == 'hi' ? 'IoT टेलीमेट्री, लोकल दस्तावेज़ व AI का संयोजन हो रहा है...' : 'Fusing IoT Telemetry, Local Knowledge & AI Engine...',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            if (_userQuery.isNotEmpty && !_isLoading) _buildUserQueryDisplay(),
            if (_aiResponse.isNotEmpty && !_isLoading) _buildResponseDisplay(),
            const SizedBox(height: 16),
            _buildQuickQuestionsSection(),
            const SizedBox(height: 24),
            _buildMicButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomQueryInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _customQueryController,
        decoration: InputDecoration(
          hintText: 'Type any unscripted crop query... (e.g. salinity spike)',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: AppColors.primaryGreen),
            onPressed: _submitCustomQuery,
          ),
        ),
        onSubmitted: (_) => _submitCustomQuery(),
      ),
    );
  }

  Widget _buildAssistantHeader() {
    final kb = KnowledgeBaseService.instance;
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.primaryGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.agriculture,
                size: 38,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Krishi AI Voice Companion',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Text(
          'Multi-lingual crop advisory & query solver',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_stories, size: 14, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(
                'RAG Knowledge Base: ${kb.chunkCount > 0 ? '${kb.fileCount} local docs (${kb.chunkCount} chunks)' : 'Ready'}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceVisualization() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          _waveformBars,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 6,
            height: _isListening
                ? (index % 3 == 0 ? 55 : (index % 3 == 1 ? 25 : 40))
                : 12,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: _isListening
                  ? AppColors.primaryGreen.withOpacity(0.5 + (index % 3) * 0.25)
                  : AppColors.lightGreen.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserQueryDisplay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.record_voice_over, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Query (आपका प्रश्न):',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userQuery,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseDisplay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'AI Diagnosis & Advice (निदान व उपाय):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Text(
            _aiResponse,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: TtsService.instance.playingNotifier,
                builder: (context, isPlaying, _) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      if (isPlaying) {
                        TtsService.instance.stop();
                      } else {
                        TtsService.instance.speak(_aiResponse, context.langCode);
                      }
                    },
                    icon: Icon(isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded, size: 18),
                    label: Text(isPlaying ? (context.langCode == 'hi' ? 'रोकें' : 'Stop') : (context.langCode == 'hi' ? 'आवाज़ में सुनें' : 'Read Out')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying ? AppColors.alertRed : AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 2,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/market');
                },
                icon: const Icon(Icons.store, size: 18),
                label: Text(context.tr('market')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warningOrange,
                  side: const BorderSide(color: AppColors.warningOrange),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.bolt, color: AppColors.warningOrange, size: 18),
            SizedBox(width: 4),
            Text(
              'Sample Farmer Questions (नमूना प्रश्न):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickQuestions.map((q) {
            return InkWell(
              onTap: () => _handleQuickQuestion(q),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightGreen),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(q['icon'] ?? '', style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      q['q'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening ? AppColors.alertRed : AppColors.primaryGreen,
          boxShadow: [
            BoxShadow(
              color: (_isListening ? AppColors.alertRed : AppColors.primaryGreen)
                  .withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
          size: 38,
          color: Colors.white,
        ),
      ),
    );
  }
}
