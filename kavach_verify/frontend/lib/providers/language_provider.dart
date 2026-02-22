import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

/// Provides the current locale ('en', 'hi', 'mr') and persists the choice.
class LanguageProvider extends ChangeNotifier {
  static const _key = 'app_locale';
  String _locale = 'en';

  String get locale => _locale;

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString(_key) ?? 'en';
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale);
  }

  /// Convenience shortcut so widgets can do `lang.tr('key')`.
  String tr(String key) => AppStrings.get(key, _locale);

  /// Translate dynamic API-returned content using phrase matching.
  String trContent(String text) => AppStrings.translateContent(text, _locale);
}
