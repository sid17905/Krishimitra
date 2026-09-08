import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../core/localization_ext.dart';
import '../../models/sensor_data.dart';
import '../../providers/locale_provider.dart';
import '../../services/ml_predictor_service.dart';
import '../../services/tts_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final SensorData _sensor = SensorData(
    id: 'esp32-001',
    name: 'Field Unit #1 (Block A)',
    moisture: 65,
    temperature: 28.5,
    humidity: 72,
    ph: 6.8,
    npkN: 45,
    npkP: 22,
    npkK: 35,
    timestamp: DateTime.now(),
  );

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 104,
        leading: Row(
          children: [
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: const Icon(Icons.sensors, size: 22),
              onPressed: () => Navigator.pushNamed(context, '/sensors'),
              tooltip: context.tr('sensor_module'),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: const Icon(Icons.account_circle, size: 22),
              onPressed: _showProfileDialog,
              tooltip: 'Account Profile',
            ),
          ],
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('app_name'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        actions: [
          _buildLanguageDropdown(),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(),
                  const SizedBox(height: 14),
                  _buildDailyFarmAdvisoryCard(),
                  const SizedBox(height: 14),
                  _buildQuickStats(),
                  const SizedBox(height: 18),
                  _buildModuleGrid(),
                  const SizedBox(height: 18),
                  _buildRecentAlerts(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ramesh Kumar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Ghazipur, UP (Farm 01)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            _profileInfoRow(Icons.phone, '+91 98765 43210'),
            const SizedBox(height: 8),
            _profileInfoRow(Icons.landscape, '5.2 Acres (Block B)'),
            const SizedBox(height: 8),
            _profileInfoRow(Icons.grass, 'Primary Crop: Wheat / Paddy'),
            const SizedBox(height: 8),
            _profileInfoRow(Icons.sensors, 'ESP32 Node #1: Online (99.4% uptime)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: AppColors.lightGreen, size: 8),
                      SizedBox(width: 6),
                      Text('TELEMETRY LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('greeting'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('greeting_sub'),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.agriculture_rounded, size: 36, color: AppColors.primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Plain-language, intuitive farm summary generated by background ML engines
  Widget _buildDailyFarmAdvisoryCard() {
    final isHindi = context.langCode == 'hi' || context.langCode == 'mr';
    final cropPred = MLPredictorService.instance.predictBestCrop(_sensor);
    final fertPred = MLPredictorService.instance.optimizeFertilizers(_sensor, 'Wheat');
    final yieldPred = MLPredictorService.instance.predictYield(_sensor, 'Wheat');

    final advice1 = isHindi
        ? '🌾 खेत स्थिति: मिट्टी की नमी ${_sensor.moisture.toInt()}% उत्तम है। ${cropPred.cropHi} के लिए ${fertPred.ureaKgPerAcre.toInt()} किग्रा यूरिया की खुराक समय पर डालें।'
        : '🌾 Soil Status: Moisture (${_sensor.moisture.toInt()}%) is optimal for ${cropPred.crop}. Apply ${fertPred.ureaKgPerAcre.toInt()} kg Urea as scheduled.';

    final advice2 = isHindi
        ? '📈 संभावित लाभ: इस पोषण प्रबंधन से आपकी उपज में +${yieldPred.yieldGainPercent}% और लगभग ₹${yieldPred.estimatedIncomeGainPerAcre.toInt()}/एकड़ का अतिरिक्त लाभ संभव है।'
        : '📈 Expected Yield: Proper nutrient balance projected to boost yield by +${yieldPred.yieldGainPercent}% (~₹${yieldPred.estimatedIncomeGainPerAcre.toInt()}/acre gain).';

    final spokenText = isHindi
        ? 'नमस्ते! आज आपके खेत की मिट्टी में नमी ${_sensor.moisture.toInt()} प्रतिशत है, जो ${cropPred.cropHi} की फसल के लिए उत्तम है। इस समय ${fertPred.ureaKgPerAcre.toInt()} किलोग्राम यूरिया डालना सबसे अच्छा रहेगा। इससे आपकी उपज में ${yieldPred.yieldGainPercent.toInt()} प्रतिशत तक की बढ़ोतरी होगी।'
        : 'Hello! Your field soil moisture is ${_sensor.moisture.toInt()}%, which is optimal for ${cropPred.crop}. Applying ${fertPred.ureaKgPerAcre.toInt()} kg of Urea as planned will boost your yield by approximately ${yieldPred.yieldGainPercent.toInt()} percent.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'दैनिक खेत सलाह (पृष्ठभूमि AI इंजन)' : 'Daily AI Farm Advisory (Auto Background ML)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    Text(
                      isHindi ? 'खेत सेंसर व मौसम विश्लेषण पर आधारित' : 'Auto-computed from field sensors & weather',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: TtsService.instance.playingNotifier,
                builder: (context, isPlaying, _) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      print("[BUTTON] Listen button pressed! isPlaying=$isPlaying");
                      if (isPlaying) {
                        TtsService.instance.stop();
                      } else {
                        print("[BUTTON] Calling speak with langCode=${context.langCode}, text='${spokenText.substring(0, spokenText.length > 30 ? 30 : spokenText.length)}...'");
                        TtsService.instance.speak(spokenText, context.langCode);
                      }
                    },
                    icon: Icon(isPlaying ? Icons.stop_circle : Icons.volume_up, size: 16),
                    label: Text(isPlaying ? (isHindi ? 'रोकें' : 'Stop') : (isHindi ? 'सुनें' : 'Listen')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying ? AppColors.alertRed : AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(height: 18),
          Text(advice1, style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(advice2, style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard(
          '🌡️',
          context.tr('temp_label'),
          '28°C',
          AppColors.waterBlue,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '💧',
          context.tr('moisture_label'),
          '65%',
          AppColors.primaryGreen,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '🌾',
          context.tr('crop_label'),
          context.tr('Wheat'),
          AppColors.soilBrown,
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid() {
    final gridModules = [
      {
        'id': 'voice',
        'title': context.tr('voice_module'),
        'icon': Icons.mic_rounded,
        'color': AppColors.primaryGreen,
        'route': '/voice',
      },
      {
        'id': 'sensors',
        'title': context.tr('sensor_module'),
        'icon': Icons.sensors_rounded,
        'color': AppColors.waterBlue,
        'route': '/sensors',
      },
      {
        'id': 'market',
        'title': context.tr('market_module'),
        'icon': Icons.trending_up_rounded,
        'color': AppColors.warningOrange,
        'route': '/market',
      },
      {
        'id': 'weather',
        'title': context.tr('weather_module'),
        'icon': Icons.wb_sunny_rounded,
        'color': const Color(0xFF0891B2),
        'route': '/weather',
      },
      {
        'id': 'alerts',
        'title': context.tr('alerts_module'),
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.alertRed,
        'route': '/alerts',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.95,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: gridModules.length,
      itemBuilder: (context, index) {
        final module = gridModules[index];
        return _buildModuleCard(module);
      },
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    final color = module['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, module['route'] as String),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(module['icon'] as IconData, size: 26, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              module['title'] as String,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('recent_alerts'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/alerts'),
              child: Text(context.tr('view_all'), style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAlertItem(
          '⚠️',
          context.tr('rain_warning_title'),
          context.tr('rain_warning_desc'),
          AppColors.warningOrange,
        ),
        const SizedBox(height: 8),
        _buildAlertItem(
          '🌾',
          context.tr('wheat_sell_title'),
          context.tr('wheat_sell_desc'),
          AppColors.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildAlertItem(String emoji, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
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
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    final currentCode = context.langCode;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: DropdownButton<String>(
        value: currentCode,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        items: AppConstants.supportedLanguages.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ))
            .toList(),
        selectedItemBuilder: (context) {
          return AppConstants.supportedLanguages.entries.map((e) {
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  e.value,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            );
          }).toList();
        },
        onChanged: (value) {
          if (value != null) {
            context.read<LocaleProvider>().setLanguage(value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.trOnce('language_changed')),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        final routes = ['/market', '/voice', '/weather', '/alerts'];
        if (index < routes.length) {
          Navigator.pushNamed(context, routes[index]);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.trending_up_rounded),
          label: context.tr('market'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.mic_rounded),
          label: context.tr('voice'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.wb_sunny_rounded),
          label: context.tr('weather'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.warning_amber_rounded),
          label: context.tr('alerts_module'),
        ),
      ],
    );
  }
}
