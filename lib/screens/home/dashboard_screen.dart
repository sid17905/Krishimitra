import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;
  String _selectedLanguage = 'hi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.sensors),
              onPressed: () => Navigator.pushNamed(context, '/sensors'),
              tooltip: AppStrings.get('sensor_module', _selectedLanguage),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                _showProfileDialog();
              },
              tooltip: 'Account Profile',
            ),
          ],
        ),
        title: Text(
          AppStrings.get('app_name', _selectedLanguage),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          _buildLanguageDropdown(),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(),
                  const SizedBox(height: 16),
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  _buildModuleGrid(),
                  const SizedBox(height: 16),
                  _buildRecentAlerts(),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                Text('Ghazipur, UP', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
            _profileInfoRow(Icons.sensors, 'ESP32 Node #1: Online'),
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
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
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
                Text(
                  AppStrings.get('greeting', _selectedLanguage),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.get('greeting_sub', _selectedLanguage),
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white24,
            child: Icon(Icons.agriculture, size: 38, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard(
          '🌡️',
          AppStrings.get('temp_label', _selectedLanguage),
          '28°C',
          AppColors.waterBlue,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '💧',
          AppStrings.get('moisture_label', _selectedLanguage),
          '65%',
          AppColors.primaryGreen,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '🌾',
          AppStrings.get('crop_label', _selectedLanguage),
          AppStrings.get('Wheat', _selectedLanguage),
          AppColors.soilBrown,
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid() {
    final gridModules = AppConstants.dashboardModules
        .where((m) => m['id'] != 'voice_camera' && m['id'] != 'sensors')
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: gridModules.length,
      itemBuilder: (context, index) {
        final module = gridModules[index];
        return _buildModuleCard(module);
      },
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    final String moduleKey = '${module['id']}_module';
    final String localizedTitle = AppStrings.get(moduleKey, _selectedLanguage);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/${module['id']}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: module['color'].withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(module['icon'], size: 32, color: module['color']),
            const SizedBox(height: 8),
            Text(
              localizedTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
        Text(
          AppStrings.get('recent_alerts', _selectedLanguage),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          '⚠️',
          AppStrings.get('rain_warning_title', _selectedLanguage),
          AppStrings.get('rain_warning_desc', _selectedLanguage),
          AppColors.warningOrange,
        ),
        const SizedBox(height: 10),
        _buildAlertItem(
          '🌾',
          AppStrings.get('wheat_sell_title', _selectedLanguage),
          AppStrings.get('wheat_sell_desc', _selectedLanguage),
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
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DropdownButton<String>(
        value: _selectedLanguage,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        items: AppConstants.supportedLanguages.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ))
            .toList(),
        selectedItemBuilder: (context) {
          return AppConstants.supportedLanguages.entries.map((e) {
            return Center(
              child: Text(
                e.value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          }).toList();
        },
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedLanguage = value);
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
      onTap: (index) {
        setState(() => _selectedIndex = index);
        final routes = ['/market', '/voice', '/weather'];
        Navigator.pushNamed(context, routes[index]);
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.trending_up),
          label: AppStrings.get('market', _selectedLanguage),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.mic),
          label: AppStrings.get('voice', _selectedLanguage),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.wb_sunny),
          label: AppStrings.get('weather', _selectedLanguage),
        ),
      ],
    );
  }
}
