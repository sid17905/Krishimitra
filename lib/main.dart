import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/voice_camera/voice_camera_screen.dart';
import 'screens/sensors/sensor_dashboard_screen.dart';
import 'screens/market/market_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/alerts/alerts_screen.dart';

void main() {
  runApp(const KrishiMitraApp());
}

class KrishiMitraApp extends StatelessWidget {
  const KrishiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const DashboardScreen(),
      routes: {
        '/voice': (context) => const VoiceCameraScreen(),
        '/sensors': (context) => const SensorDashboardScreen(),
        '/market': (context) => const MarketScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/alerts': (context) => const AlertsScreen(),
      },
    );
  }
}
