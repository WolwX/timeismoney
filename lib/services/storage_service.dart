// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Clé pour sauvegarder le taux
  static const String _hourlyRateKey = 'hourlyRate';
  // Clé pour sauvegarder la devise
  static const String _currencyKey = 'currencySymbol';

  // Méthode pour charger le taux
  Future<double> loadHourlyRate() async {
    final prefs = await SharedPreferences.getInstance();
    // Retourne la valeur sauvegardée, ou 15.0 par défaut si rien n'est trouvé
    return prefs.getDouble(_hourlyRateKey) ?? 15.0; 
  }

  // Méthode pour sauvegarder le taux
  Future<void> saveHourlyRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_hourlyRateKey, rate);
  }
  
  // Méthode pour charger la devise
  Future<String> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    // Retourne la valeur sauvegardée, ou '€' par défaut
    return prefs.getString(_currencyKey) ?? '€';
  }

  // Méthode pour sauvegarder la devise
  Future<void> saveCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, symbol);
  }
}