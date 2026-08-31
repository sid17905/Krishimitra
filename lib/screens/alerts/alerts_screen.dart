import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _filter = 'All';

  final List<Map<String, dynamic>> _alerts = [
    {
      'type': 'Nowcast',
      'severity': 'High',
      'title': 'Thunderstorm Warning',
      'desc': 'Thunderstorm approaching with wind speeds up to 40km/h. Expected within 2 hours.',
      'icon': Icons.thunderstorm,
      'color': AppColors.alertRed,
      'time': '10 min ago',
      'location': 'Ghazipur, UP',
      'action': 'Secure crop covers and avoid fieldwork',
    },
    {
      'type': 'Contamination',
      'severity': 'Medium',
      'title': 'EC/Potential Contamination Detected',
      'desc': 'Soil EC spike detected near field sensor #3. Cross-matched with CPCB water quality data suggesting runoff risk.',
      'icon': Icons.warning,
      'color': AppColors.warningOrange,
      'time': '1 hour ago',
      'location': 'Field - Block B',
      'action': 'Verify water source and contact local agriculture officer',
    },
    {
      'type': 'Advisory',
      'severity': 'Info',
      'title': 'Optimal Wheat Selling Window',
      'desc': 'Current mandi prices are 5% above 30-day average. This is the best time to sell in this quarter.',
      'icon': Icons.trending_up,
      'color': AppColors.primaryGreen,
      'time': '3 hours ago',
      'location': 'Ghazipur Mandi',
      'action': 'Consider selling within next 2 days',
    },
    {
      'type': 'Nowcast',
      'severity': 'Medium',
      'title': 'Heavy Rain Approaching',
      'desc': 'IMD nowcast shows localized heavy rainfall expected in 6 hours. Wind-vector adjusted time-to-arrival: 5.5 hours.',
      'icon': Icons.water_drop,
      'color': AppColors.waterBlue,
      'time': '5 hours ago',
      'location': 'Ghazipur, UP',
      'action': 'Delay pesticide/fetilizer application until after rain',
    },
    {
      'type': 'Contamination',
      'severity': 'High',
      'title': 'PH Level Out of Range',
      'desc': 'Soil pH reading 8.2 (highly alkaline) detected. This may affect nutrient absorption for paddy.',
      'icon': Icons.science,
      'color': AppColors.alertRed,
      'time': 'Yesterday',
      'location': 'Field - Block A',
      'action': 'Add sulfur-based soil amendment. Consult local Krishi Vigyan Kendra.',
    },
  ];

  final List<String> _filters = ['All', 'Nowcast', 'Contamination', 'Advisory'];

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = _filter == 'All'
        ? _alerts
        : _alerts.where((a) => a['type'] == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Warnings'),
        backgroundColor: AppColors.alertRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAlertStats(),
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredAlerts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAlertSummary();
                }
                return _buildAlertCard(filteredAlerts[index - 1]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertStats() {
    int nowcast = _alerts.where((a) => a['type'] == 'Nowcast').length;
    int contamination = _alerts.where((a) => a['type'] == 'Contamination').length;
    int advisory = _alerts.where((a) => a['type'] == 'Advisory').length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AlertStatItem(
            label: 'Nowcast',
            count: nowcast,
            icon: Icons.thunderstorm,
            color: AppColors.waterBlue,
          ),
          _AlertStatItem(
            label: 'Contamination',
            count: contamination,
            icon: Icons.warning,
            color: AppColors.warningOrange,
          ),
          _AlertStatItem(
            label: 'Advisory',
            count: advisory,
            icon: Icons.lightbulb,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final isSelected = _filter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                onSelected: (_) => setState(() => _filter = f),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAlertSummary() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌾 Smart Alerts Active',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'KrishiMitra monitors your field 24/7 combining ESP32 sensors, IMD nowcast radar, and CPCB water quality data.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final Color alertColor = alert['color'];
    final String severity = alert['severity'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: severity == 'High'
                ? AppColors.alertRed
                : severity == 'Medium'
                    ? AppColors.warningOrange
                    : AppColors.primaryGreen,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: alertColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(alert['icon'], color: alertColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          alert['type'],
                          style: TextStyle(
                            color: alertColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (severity == 'High') ...[
                          const SizedBox(width: 6),
                          const _SeverityBadge(label: 'HIGH'),
                        ],
                      ],
                    ),
                    Text(
                      alert['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                alert['time'],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert['desc'],
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  alert['location'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates,
                  size: 16,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Suggested action: ${alert['action']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Got it'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.volume_up, size: 16),
                label: const Text('Hear')
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/sensors');
                },
                icon: const Icon(Icons.sensors, size: 16),
                label: const Text('Sensors'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertStatItem extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _AlertStatItem({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String label;

  const _SeverityBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.alertRed,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
