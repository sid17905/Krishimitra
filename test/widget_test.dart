import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:krishimitra/main.dart';
import 'package:krishimitra/providers/locale_provider.dart';
import 'package:krishimitra/providers/weather_provider.dart';
import 'package:krishimitra/providers/market_provider.dart';

void main() {
  testWidgets('KrishiMitra app renders and mounts global providers', (WidgetTester tester) async {
    final localeProvider = LocaleProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ChangeNotifierProvider<WeatherProvider>(create: (_) => WeatherProvider()),
          ChangeNotifierProvider<MarketProvider>(create: (_) => MarketProvider()),
        ],
        child: const KrishiMitraApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(KrishiMitraApp), findsOneWidget);
  });
}
