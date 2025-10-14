// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _localeKey = 'selected_locale';

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  /// Charge la locale sauvegardée depuis SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
    // Si null, utilise la langue du système (par défaut)
  }

  /// Change la locale et la sauvegarde
  Future<void> setLocale(Locale? locale) async {
    if (locale == _locale) return;
    
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      // null = langue du système
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }

  /// Réinitialise à la langue du système
  Future<void> clearLocale() async {
    await setLocale(null);
  }
}
