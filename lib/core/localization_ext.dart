import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/locale_provider.dart';

/// Ergonomic translation access for widgets.
///
/// Instead of manually threading the selected language code into every
/// `AppStrings.get(key, code)` call, a widget can just write:
///
/// ```dart
/// Text(context.tr('greeting'))
/// ```
///
/// `context.tr` reads the current language from [LocaleProvider] (listening,
/// so the widget rebuilds when the language changes) and looks the key up in
/// the existing `AppStrings.translations` map, with graceful fallback:
///   selected language → English → the raw key.
extension LocalizationX on BuildContext {
  /// Translate [key] into the currently selected language.
  String tr(String key) {
    final code = watch<LocaleProvider>().languageCode;
    return AppStrings.get(key, code);
  }

  /// Same as [tr] but does NOT subscribe to rebuilds. Use inside callbacks
  /// (e.g. building a SnackBar) where you only need a one-off value.
  String trOnce(String key) {
    final code = read<LocaleProvider>().languageCode;
    return AppStrings.get(key, code);
  }

  /// The active language code ('en', 'hi', ...), listening for changes.
  String get langCode => watch<LocaleProvider>().languageCode;
}
