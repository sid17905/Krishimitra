import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedLocation = 'Ghazipur, UP';
  String _selectedSeason = 'Kharif';

  final List<String> _locations = [
    'Ghazipur, UP',
    'Varanasi, UP',
    'Patna, Bihar',
    'Pune, MH',
  ];

  final List<Map<String, dynamic>> _dailyForecast = [
    {'day': 'Today', 'icon': Icons.wb_sunny, 'temp': '28°/18°', 'rain': '0%', 'desc': 'Sunny'},
    {'day': 'Tomorrow', 'icon': Icons.cloud, 'temp': '27°/17°', 'rain': '10%', 'desc': 'Cloudy'},
    {'day': 'Wed', 'icon': Icons.water_drop, 'temp': '26°/16°', 'rain': '60%', 'desc': 'Rain'},
    {'day': 'Thu', 'icon': Icons.thunderstorm, 'temp': '25°/15°', 'rain': '80%', 'desc': 'Storm'},
    {'day': 'Fri', 'icon': Icons.cloud, 'temp': '27°/17°', 'rain': '20%', 'desc': 'Cloudy'},
    {'day': 'Sat', 'icon': Icons.wb_sunny, 'temp': '29°/19°', 'rain': '0%', 'desc': 'Sunny'},
    {'day': 'Sun', 'icon': Icons.wb_sunny, 'temp': '30°/20°', 'rain': '0%', 'desc': 'Sunny'},
  ];

  final List<Map<String, dynamic>> _stormAdvisory = [
    {
      'type': 'Nowcast Warning',
      'desc': 'Thunderstorm expected within 3 hours',
      'icon': Icons.thunderstorm,
      'color': AppColors.alertRed,
      'time': 'Now',
    },
    {
      'type': 'Heat Advisory',
      'desc': 'Temperature expected to reach 35°C',
      'icon': Icons.thermostat,
      'color': AppColors.warningOrange,
      'time': 'In 2 days',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Intelligence'),
        backgroundColor: AppColors.waterBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationSelector(),
            const SizedBox(height: 16),
            _buildCurrentWeather(),
            const SizedBox(height: 24),
            _buildSeasonSelector(),
            const SizedBox(height: 12),
            _buildSeasonalAdvice(),
            const SizedBox(height: 24),
            _buildDailyForecast(),
            const SizedBox(height: 24),
            _buildNowcastAdvisories(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.waterBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.waterBlue),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              underline: const SizedBox(),
              items: _locations.map((l) => DropdownMenuItem(
                value: l,
                child: Text(l),
              )).toList(),
              onChanged: (v) => setState(() => _selectedLocation = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monday',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Ghazipur, UP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(Icons.wb_sunny, size: 40, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    '28°C',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Mostly Sunny',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 40),
              Row(
                children: [
                  _buildWeatherMetric(Icons.cloud, '10%', 'Humidity'),
                  const SizedBox(width: 12),
                  _buildWeatherMetric(Icons.air, '12 km/h', 'Wind'),
                  const SizedBox(width: 12),
                  _buildWeatherMetric(Icons.water_drop, '0%', 'Rain'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonSelector() {
    return Row(
      children: [
        Expanded(
          child: _SeasonTab(
            label: 'Kharif',
            icon: Icons.spa,
            isSelected: _selectedSeason == 'Kharif',
            onTap: () => setState(() => _selectedSeason = 'Kharif'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SeasonTab(
            label: 'Rabi',
            icon: Icons.wb_incandescent,
            isSelected: _selectedSeason == 'Rabi',
            onTap: () => setState(() => _selectedSeason = 'Rabi'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SeasonTab(
            label: 'Zaid',
            icon: Icons.eco,
            isSelected: _selectedSeason == 'Zaid',
            onTap: () => setState(() => _selectedSeason = 'Zaid'),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonalAdvice() {
    final Map<String, Object> info = _selectedSeason == 'Kharif'
        ? {
            'crop': 'Paddy, Soybean, Cotton',
            'advice': 'Planting season has begun. Soil moisture is good for sowing.',
            'color': AppColors.primaryGreen,
          }
        : _selectedSeason == 'Rabi'
            ? {
                'crop': 'Wheat, Gram, Mustard',
                'advice': 'Optimal time for wheat sowing. Water availability is adequate.',
                'color': AppColors.waterBlue,
              }
            : {
                'crop': 'Cucumber, Watermelon',
                'advice': 'Summer crop season. Ensure irrigation during dry spells.',
                'color': AppColors.warningOrange,
              };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: info['color'] as Color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: info['color'] as Color),
              const SizedBox(width: 8),
              Text(
                '$_selectedSeason Season Advice',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recommended crops: ${info['crop']}',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            info['advice'] as String,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7-Day Outlook',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _dailyForecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final day = _dailyForecast[index];
                return Container(
                  width: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.waterBlue.withOpacity(day['rain'] == '0%'
                        ? 0.1
                        : (day['rain'] == '80%' ? 0.3 : 0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day['day'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        day['icon'],
                        color: day['rain'] == '80%'
                            ? AppColors.alertRed
                            : AppColors.waterBlue,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day['temp'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        day['rain'],
                        style: TextStyle(
                          fontSize: 11,
                          color: day['rain'] == '0%'
                              ? Colors.green
                              : AppColors.warningOrange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowcastAdvisories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.radar, color: AppColors.alertRed),
            SizedBox(width: 8),
            Text(
              'Nowcast & Advisory',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._stormAdvisory.map((a) => Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: a['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: a['color'].withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(a['icon'], color: a['color']),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['type'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: a['color'],
                      ),
                    ),
                    Text(
                      a['desc'],
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                a['time'],
                style: TextStyle(
                  color: a['color'],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _SeasonTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeasonTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGreen,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primaryGreen,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
