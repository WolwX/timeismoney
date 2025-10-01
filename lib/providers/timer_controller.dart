// lib/providers/timer_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerController extends ChangeNotifier {
  Timer? _timer;
  bool _isRunning = false;
  Duration _elapsedDuration = Duration.zero;
  double _hourlyRate = 15.00; // Taux par défaut
  String _currency = '€'; // Devise par défaut
  double _currentGains = 0.0;
  String _rateTitle = 'Taux Personnalisé';
  
  // NOUVEAU : Taux de conversion Net/Brut en pourcentage (ex: 77.0 pour 77% Net du Brut)
  double _netRatePercentage = 77.0; 

  bool get isRunning => _isRunning;
  Duration get elapsedDuration => _elapsedDuration;
  double get hourlyRate => _hourlyRate;
  String get currency => _currency;
  double get currentGains => _currentGains;
  String get rateTitle => _rateTitle;
  double get netRatePercentage => _netRatePercentage; 

  // NOUVEAU GETTER : Taux de conversion utilisé pour le calcul (ex: 0.77)
  double get netConversionFactor => _netRatePercentage / 100.0; 

  TimerController() {
    loadPreferences();
  }

  // --- Persistance des données (Shared Preferences) ---

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('hourlyRate', _hourlyRate);
    prefs.setString('currency', _currency);
    prefs.setString('rateTitle', _rateTitle);
    prefs.setDouble('netRatePercentage', _netRatePercentage); // NOUVEAU : Sauvegarde du taux Net
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _hourlyRate = prefs.getDouble('hourlyRate') ?? 15.00;
    _currency = prefs.getString('currency') ?? '€';
    _rateTitle = prefs.getString('rateTitle') ?? 'Taux Personnalisé';
    _netRatePercentage = prefs.getDouble('netRatePercentage') ?? 77.0; // NOUVEAU : Chargement du taux Net (77% par défaut)
    notifyListeners();
  }

  // --- Gestion du Taux et de la Devise ---

  void setHourlyRate(double newRate) {
    _hourlyRate = newRate;
    _rateTitle = 'Taux Personnalisé'; 
    _savePreferences();
    notifyListeners();
  }
  
  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    _savePreferences();
    notifyListeners();
  }

  void setRateTitle(String title) {
    _rateTitle = title;
    _savePreferences();
    notifyListeners();
  }

  // NOUVEAU : Méthode pour mettre à jour le taux Net
  void setNetRatePercentage(double percentage) {
    _netRatePercentage = percentage.clamp(0.0, 100.0); // Assure que la valeur reste entre 0 et 100
    _savePreferences();
    notifyListeners();
  }

  // --- Gestion du Chronomètre ---
  
  void startTimer() {
    if (_isRunning) return;
    
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedDuration = _elapsedDuration + const Duration(seconds: 1);
      
      // Calcul des gains
      _currentGains += _hourlyRate / 3600.0;
      
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetSession() {
    stopTimer();
    _elapsedDuration = Duration.zero;
    _currentGains = 0.0;
    notifyListeners();
  }
}