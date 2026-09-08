import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:krishimitra/providers/locale_provider.dart';
import 'package:krishimitra/constants/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial locale defaults to Hindi (hi)', () {
      final provider = LocaleProvider();
      expect(provider.languageCode, 'hi');
      expect(provider.locale, const Locale('hi'));
      expect(provider.languageLabel, 'हिंदी');
    });

    test('setLanguage updates locale and notifies listeners', () async {
      final provider = LocaleProvider();
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.setLanguage('en');

      expect(provider.languageCode, 'en');
      expect(provider.locale, const Locale('en'));
      expect(provider.languageLabel, 'English');
      expect(notified, isTrue);

      // Verify persistence to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language_code'), 'en');
    });

    test('load() restores persisted language choice', () async {
      SharedPreferences.setMockInitialValues({
        'selected_language_code': 'mr',
      });

      final provider = LocaleProvider();
      await provider.load();

      expect(provider.languageCode, 'mr');
      expect(provider.languageLabel, 'मराठी');
      expect(provider.isReady, isTrue);
    });

    test('supportedLocales matches AppConstants.supportedLanguages', () {
      final locales = LocaleProvider.supportedLocales;
      expect(locales.length, AppConstants.supportedLanguages.length);
      expect(locales.map((l) => l.languageCode), containsAll(['en', 'hi', 'bn', 'ta', 'te', 'mr']));
    });
  });
}
