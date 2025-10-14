// lib/services/exchange_rate_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateService {
  // Taux de change par défaut (mis à jour manuellement si besoin)
  static const Map<String, double> _defaultRates = {
    '€': 1.0,      // Euro (base)
    '\$': 1.10,    // Dollar US
    'CHF': 0.95,   // Franc Suisse
    '£': 1.17,     // Livre Sterling
    'A\$': 0.67,   // Dollar Australien
    'NZ\$': 0.62,  // Dollar Néo-Zélandais
    'CA\$': 0.81,  // Dollar Canadien
    '¥': 0.0074,   // Yen Japonais
    '₽': 0.011,    // Rouble Russe
    '₹': 0.013,    // Roupie Indienne
  };

  static Map<String, double> _cachedRates = {};
  static DateTime? _lastUpdate;
  static const Duration _cacheValidity = Duration(hours: 24);

  /// Récupère les taux de change depuis l'API (avec cache)
  static Future<Map<String, double>> getExchangeRates() async {
    // Si le cache est valide, retourner les taux en cache
    if (_cachedRates.isNotEmpty && _lastUpdate != null) {
      if (DateTime.now().difference(_lastUpdate!) < _cacheValidity) {
        return _cachedRates;
      }
    }

    // Charger depuis SharedPreferences si disponible
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('exchange_rates');
    final cachedTimestamp = prefs.getInt('exchange_rates_timestamp');
    
    if (cachedJson != null && cachedTimestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
      if (DateTime.now().difference(cacheTime) < _cacheValidity) {
        _cachedRates = Map<String, double>.from(json.decode(cachedJson));
        _lastUpdate = cacheTime;
        return _cachedRates;
      }
    }

    // Sinon, essayer de récupérer depuis l'API
    try {
      // API gratuite : exchangerate-api.com (pas besoin de clé pour les requêtes de base)
      final response = await http.get(
        Uri.parse('https://open.exchangerate-api.com/v6/latest/EUR'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        // Convertir en Map<String, double> avec les symboles de devises
        _cachedRates = {
          '€': 1.0,
          '\$': rates['USD']?.toDouble() ?? _defaultRates['\$']!,
          'CHF': 1.0 / (rates['CHF']?.toDouble() ?? (1.0 / _defaultRates['CHF']!)),
          '£': 1.0 / (rates['GBP']?.toDouble() ?? (1.0 / _defaultRates['£']!)),
          'A\$': rates['AUD']?.toDouble() ?? _defaultRates['A\$']!,
          'NZ\$': rates['NZD']?.toDouble() ?? _defaultRates['NZ\$']!,
          'CA\$': rates['CAD']?.toDouble() ?? _defaultRates['CA\$']!,
          '¥': rates['JPY']?.toDouble() ?? _defaultRates['¥']!,
          '₽': rates['RUB']?.toDouble() ?? _defaultRates['₽']!,
          '₹': rates['INR']?.toDouble() ?? _defaultRates['₹']!,
        };

        // Sauvegarder dans SharedPreferences
        _lastUpdate = DateTime.now();
        await prefs.setString('exchange_rates', json.encode(_cachedRates));
        await prefs.setInt('exchange_rates_timestamp', _lastUpdate!.millisecondsSinceEpoch);

        return _cachedRates;
      }
    } catch (e) {
      print('[ExchangeRateService] Erreur lors de la récupération des taux: $e');
    }

    // En cas d'échec, utiliser les taux par défaut
    _cachedRates = Map.from(_defaultRates);
    _lastUpdate = DateTime.now();
    return _cachedRates;
  }

  /// Convertit un montant d'une devise vers une autre
  static Future<double> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    final rates = await getExchangeRates();
    
    final fromRate = rates[fromCurrency] ?? _defaultRates[fromCurrency] ?? 1.0;
    final toRate = rates[toCurrency] ?? _defaultRates[toCurrency] ?? 1.0;

    // Conversion via EUR comme devise de base
    final amountInEur = amount / fromRate;
    final convertedAmount = amountInEur * toRate;

    return convertedAmount;
  }

  /// Obtient le taux de change entre deux devises
  static Future<double> getRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return 1.0;
    
    return await convert(amount: 1.0, fromCurrency: fromCurrency, toCurrency: toCurrency);
  }
}
