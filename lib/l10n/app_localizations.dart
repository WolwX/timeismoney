// lib/l10n/app_localizations.dart

import 'package:flutter/material.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

/// Classe de base pour la localisation de l'application
abstract class AppLocalizations {
  // Général
  String get appTitle;
  String get loading;
  String get error;
  String get ok;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get reset;
  
  // Timer
  String get start;
  String get stop;
  String get pause;
  String get resume;
  String get resetTimer;
  String get editTime;
  String get hours;
  String get minutes;
  String get seconds;
  String get hourShort;
  String get minuteShort;
  String get secondShort;
  
  // Taux et revenus
  String get hourlyRate;
  String get hourlyRateNet;
  String get hourlyRateGross;
  String get monthlyIncome;
  String get yearlyIncome;
  String get netIncome;
  String get grossIncome;
  String get charges;
  String get netPercentage;
  String get chargesPercentage;
  
  // Préréglages
  String get smicFrench;
  String get minimumWageSwitzerland;
  String get customRate;
  String get presetRates;
  
  // Navigation et menus
  String get settings;
  String get about;
  String get moreDetails;
  String get lessDetails;
  
  // Messages
  String get timersSynced;
  String get startAllTimers;
  String get stopAllTimers;
  String get resetAllTimers;
  String get syncTimers;
  
  // Paramètres
  String get language;
  String get chooseLanguage;
  String get systemDefault;
  String get version;
  
  // Langues
  String get french;
  String get english;
  String get spanish;
  
  // Conversion de devises
  String get currencyConversion;
  String get convertedTo;
  String get exchangeRate;
  
  // Méthode statique pour récupérer les traductions selon la locale
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  // Méthode pour obtenir la localisation selon le code de langue
  static AppLocalizations? getLocalization(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return AppLocalizationsFr();
      case 'en':
        return AppLocalizationsEn();
      case 'es':
        return AppLocalizationsEs();
      default:
        return AppLocalizationsFr();
    }
  }
}

/// Delegate pour charger les localisations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'es':
        return AppLocalizationsEs();
      case 'fr':
      default:
        return AppLocalizationsFr();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
