import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class VoiceCameraScreen extends StatefulWidget {
  const VoiceCameraScreen({super.key});

  @override
  State<VoiceCameraScreen> createState() => _VoiceCameraScreenState();
}

class _VoiceCameraScreenState extends State<VoiceCameraScreen> {
  bool _isListening = false;
  String _aiResponse = '';
  String _userQuery = '';
  Timer? _timer;
  int _waveformBars = 12;

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
      'ans': '🐛 Image Analysis Result (Simulated):\n'
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
    super.dispose();
  }

  void _startListening() {
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
    // Simulate receiving response after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) _stopListening();
    });
  }

  void _stopListening() {
    _timer?.cancel();
    setState(() {
      _isListening = false;
      _userQuery = 'Why are my wheat leaves turning yellow? (मेरे गेहूं के पत्ते पीले क्यों हो रहे हैं?)';
      _aiResponse =
          '🌱 Diagnosis: Nitrogen Deficiency & Moisture Imbalance\n\n'
          'Based on your ESP32 soil sensor telemetry and visual symptom analysis:\n'
          '• Soil Nitrogen is low (32 mg/kg vs optimal 50-80 mg/kg).\n'
          '• Chlorosis is visible on older leaf blades.\n\n'
          '📋 Recommended Action Plan:\n'
          '1. Apply Urea fertilizer at 45 kg per acre during upcoming irrigation.\n'
          '2. Spray 2% Urea foliar solution (20g/L water) for rapid nitrogen absorption.\n'
          '3. Re-check soil NPK reading on the Sensor Dashboard in 5 days.';
    });
  }

  void _handleQuickQuestion(Map<String, String> item) {
    setState(() {
      _userQuery = '${item['q']!} (${item['qHi']!})';
      _aiResponse = item['ans']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Voice Assistant',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'आवाज़ सहायक (AI Prototype)',
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
            _buildDisclaimerBanner(),
            const SizedBox(height: 16),
            _buildAssistantHeader(),
            const SizedBox(height: 16),
            _buildVoiceVisualization(),
            const SizedBox(height: 16),
            Text(
              _isListening
                  ? 'Listening to speech... (सुन रहा हूँ...)'
                  : 'Tap the mic or select a question below',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_userQuery.isNotEmpty) _buildUserQueryDisplay(),
            if (_aiResponse.isNotEmpty) _buildResponseDisplay(),
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

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade900, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prototype Representation (प्रोटोटाइप मोड)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Note: AI Voice Assistant backend is not deployed to a live cloud service. This is an interactive static representation and UI simulation for Smart India Hackathon demonstration.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.brown.shade800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightGreen.withOpacity(0.25),
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: const Icon(
            Icons.agriculture,
            size: 38,
            color: AppColors.primaryGreen,
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
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.volume_up, size: 18),
                label: const Text('Audio Out'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/market');
                },
                icon: const Icon(Icons.store, size: 18),
                label: const Text('View Mandi'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warningOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
