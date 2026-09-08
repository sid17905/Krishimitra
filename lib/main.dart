import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'providers/locale_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/market_provider.dart';
import 'services/knowledge_base_service.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/voice_camera/voice_camera_screen.dart';
import 'screens/sensors/sensor_dashboard_screen.dart';
import 'screens/market/market_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/alerts/alerts_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try loading the .env file. If it fails, the app still runs gracefully.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: No .env file found. AI features require an API key.");
  }

  // Load the persisted language BEFORE first frame so there is no flash of the
  // wrong locale.
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  // Warm up the on-device RAG index in the background (non-blocking).
  KnowledgeBaseService.instance.load();

  runApp(
    MultiProvider(
      providers: [
        // Global language state — the single source of truth for the whole app.
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        // Feature state holders (loading/success/error) for the live screens.
        ChangeNotifierProvider<WeatherProvider>(
          create: (_) => WeatherProvider(),
        ),
        ChangeNotifierProvider<MarketProvider>(
          create: (_) => MarketProvider(),
        ),
      ],
      child: const KrishiMitraApp(),
    ),
  );
}

class KrishiMitraApp extends StatelessWidget {
  const KrishiMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the locale so a language toggle ANYWHERE rebuilds the whole app
    // through MaterialApp.locale.
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      // ---- Localization wiring ----
      locale: locale,
      supportedLocales: LocaleProvider.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Some Indian language codes may not have full Material translations;
      // fall back to the closest supported (or English) instead of crashing.
      localeResolutionCallback: (deviceLocale, supported) => locale,
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
