import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../core/localization_ext.dart';
import '../../core/result_state.dart';
import '../../models/weather_data.dart';
import '../../providers/weather_provider.dart';
import '../../services/tts_service.dart';
import '../../widgets/state_widgets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedSeason = 'Kharif';

  @override
  void initState() {
    super.initState();
    // Kick off the first live fetch after the frame is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<WeatherProvider>();
      if (p.state is! SuccessState) p.load();
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final state = provider.state;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('weather_title')),
        backgroundColor: AppColors.waterBlue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: SourceBadge(
                isLive: provider.isLive,
                liveLabel: context.tr('live_badge'),
                offlineLabel: context.tr('offline_badge'),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.playingNotifier,
            builder: (context, isPlaying, _) {
              return IconButton(
                icon: Icon(isPlaying ? Icons.stop_circle : Icons.volume_up),
                tooltip: isPlaying ? context.tr('stop') : context.tr('read_out'),
                onPressed: () {
                  if (isPlaying) {
                    TtsService.instance.stop();
                  } else {
                    final state = provider.state;
                    if (state is SuccessState<WeatherData>) {
                      final data = state.data;
                      final locale = context.langCode;
                      final text =
                          '${data.temperature.toStringAsFixed(0)} degrees celsius, ${data.condition}, humidity ${data.humidity.toStringAsFixed(0)} percent, wind ${data.windSpeed.toStringAsFixed(0)} km/h, rainfall ${data.rainfall.toStringAsFixed(0)} mm';
                      TtsService.instance.speak(text, locale);
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      // Pull-to-refresh: dragging down re-runs the live fetch.
      body: RefreshIndicator(
        color: AppColors.waterBlue,
        onRefresh: () => context.read<WeatherProvider>().load(),
        child: _buildBody(context, provider, state),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherProvider provider,
    ResultState<WeatherData> state,
  ) {
    // The switch is exhaustive thanks to the sealed ResultState type.
    switch (state) {
      case LoadingState():
        // Skeleton must be scrollable so RefreshIndicator still works.
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [ShimmerList(items: 3)],
        );

      case ErrorState(:final message, :final isTimeout):
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: ErrorRetry(
                message: isTimeout ? context.tr('error_timeout') : message,
                isTimeout: isTimeout,
                retryLabel: context.tr('retry'),
                onRetry: () => context.read<WeatherProvider>().load(),
              ),
            ),
          ],
        );

      case SuccessState(:final data):
        return _buildSuccess(context, provider, data);
    }
  }

  Widget _buildSuccess(
    BuildContext context,
    WeatherProvider provider,
    WeatherData data,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationSelector(context, provider),
          const SizedBox(height: 8),
          Text(
            context.tr('pull_to_refresh'),
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _buildCurrentWeather(data),
          const SizedBox(height: 24),
          _buildSeasonSelector(),
          const SizedBox(height: 12),
          _buildSeasonalAdvice(),
          const SizedBox(height: 24),
          _buildDailyForecast(data),
          const SizedBox(height: 24),
          _buildNowcastAdvisories(data),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(BuildContext context, WeatherProvider provider) {
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
              value: provider.selectedLocation,
              isExpanded: true,
              underline: const SizedBox(),
              items: WeatherProvider.locations.keys
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) {
                if (v != null) context.read<WeatherProvider>().selectLocation(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherData data) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('updated_just_now'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    data.location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(_conditionIcon(data.condition), size: 40, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    '${data.temperature.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    data.condition,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherMetric(Icons.cloud,
                        '${data.humidity.toStringAsFixed(0)}%', context.tr('humidity_label')),
                    _buildWeatherMetric(Icons.air,
                        '${data.windSpeed.toStringAsFixed(0)} km/h', context.tr('wind_label')),
                    _buildWeatherMetric(Icons.water_drop,
                        '${data.rainfall.toStringAsFixed(0)} mm', context.tr('rain_label')),
                  ],
                ),
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
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
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
            'crop': 'Paddy, Soybean, Cotton, Maize',
            'advice': 'Planting season has begun. Soil moisture is good for sowing.',
            'color': AppColors.primaryGreen,
          }
        : _selectedSeason == 'Rabi'
            ? {
                'crop': 'Wheat, Gram, Mustard, Barley',
                'advice': 'Optimal time for wheat sowing. Water availability is adequate.',
                'color': AppColors.waterBlue,
              }
            : {
                'crop': 'Cucumber, Watermelon, Fodder Maize',
                'advice': 'Summer crop season. Ensure irrigation during dry spells.',
                'color': AppColors.warningOrange,
              };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                '$_selectedSeason ${context.tr('season_advice')}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${context.tr('recommended_crops')}: ${info['crop']}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            info['advice'] as String,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(WeatherData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('daily_outlook'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.dailyForecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final day = data.dailyForecast[index];
                final rain = day.rainChance;
                return Container(
                  width: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.waterBlue
                        .withOpacity(rain == 0 ? 0.08 : (rain >= 80 ? 0.25 : 0.15)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.waterBlue.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(day.day,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Icon(
                        _conditionIcon(day.condition),
                        color: rain >= 80
                            ? AppColors.alertRed
                            : AppColors.waterBlue,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${day.maxTemp.toStringAsFixed(0)}°/${day.minTemp.toStringAsFixed(0)}°',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${rain.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: rain == 0 ? Colors.green.shade700 : AppColors.warningOrange,
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

  Widget _buildNowcastAdvisories(WeatherData data) {
    if (data.nowcast.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Expanded(child: Text('No severe weather expected in the near term.')),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.radar, color: AppColors.alertRed),
            const SizedBox(width: 8),
            Text(context.tr('nowcast_advisory'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...data.nowcast.map((a) {
          final color =
              a.severity == 'High' ? AppColors.alertRed : AppColors.warningOrange;
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.thunderstorm, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.type,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: color)),
                      Text(a.description,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Text(a.source,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _conditionIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('storm') || c.contains('thunder')) return Icons.thunderstorm;
    if (c.contains('rain') || c.contains('drizzle')) return Icons.water_drop;
    if (c.contains('cloud')) return Icons.cloud;
    if (c.contains('snow')) return Icons.ac_unit;
    return Icons.wb_sunny;
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
            Icon(icon, color: isSelected ? Colors.white : AppColors.primaryGreen),
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
