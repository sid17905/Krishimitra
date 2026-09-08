import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Global, app-wide language state.
///
/// This is the single source of truth for the current language. It is provided
/// once near the root of the widget tree (see `main.dart`) so ANY screen can:
///   • read the current locale, and
///   • change it, instantly rebuilding every widget that listens.
///
/// It also persists the choice with SharedPreferences so the language survives
/// app restarts.
class LocaleProvider extends ChangeNotifier {
  static const String _prefsKey = 'selected_language_code';

  // Default to Hindi to match the app's existing default farmer persona.
  Locale _locale = const Locale('hi');
  bool _isReady = false;

  Locale get locale => _locale;

  /// The bare language code ('en', 'hi', ...). Handy for the old
  /// `AppStrings.get(key, code)` map and for dropdowns.
  String get languageCode => _locale.languageCode;

  /// Human-readable name for the current language (e.g. "हिंदी").
  String get languageLabel =>
      AppConstants.supportedLanguages[_locale.languageCode] ?? 'English';

  /// True once the persisted value has been loaded. Lets the UI avoid a flash.
  bool get isReady => _isReady;

  /// The list of `Locale`s the MaterialApp should advertise as supported.
  static List<Locale> get supportedLocales => AppConstants
      .supportedLanguages.keys
      .map((code) => Locale(code))
      .toList();

  /// Loads the saved language on startup. Call once before/at app launch.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null &&
          AppConstants.supportedLanguages.containsKey(saved)) {
        _locale = Locale(saved);
      }
    } catch (_) {
      // If prefs are unavailable, silently keep the default locale.
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  /// Switches the app language and notifies every listening widget.
  ///
  /// Because `MaterialApp.locale` is bound to this provider, calling this from
  /// ANY page updates the ENTIRE widget tree at once — no per-screen state.
  Future<void> setLanguage(String code) async {
    if (!AppConstants.supportedLanguages.containsKey(code)) return;
    if (code == _locale.languageCode) return;

    _locale = Locale(code);
    notifyListeners(); // instant UI update across all pages

    // Persist in the background; UI does not wait on disk I/O.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, code);
    } catch (_) {
      // Non-fatal: the in-memory locale is already applied.
    }
  }
}
