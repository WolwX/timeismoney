// lib/providers/multi_timer_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:timeismoney/models/single_timer.dart';
import 'package:timeismoney/services/storage_service.dart';

class MultiTimerController extends ChangeNotifier {
  // Définit le montant cible du minuteur et calcule la durée cible automatiquement
  void setMinuteurTargetAmount(int index, double targetAmount) {
    if (index < 0 || index >= _timers.length) return;
    final timer = _timers[index];
    timer.targetAmount = targetAmount;
    // En mode minuteur, remettre le temps écoulé à 0 pour recommencer le compte à rebours
    if (timer.isReverseMode) {
      timer.elapsedDuration = Duration.zero;
      timer.pausedDuration = Duration.zero;
      timer.currentGains = 0.0;
      timer.sessionStartTime = null;
      if (timer.isRunning) {
        timer.internalTimer?.cancel();
        timer.isRunning = false;
      }
    }
    saveTimers();
    notifyListeners();
  }
  // Définit la durée cible du minuteur pour le timer donné
  void setMinuteurTargetTime(int index, Duration targetDuration) {
    if (index < 0 || index >= _timers.length) return;
    final timer = _timers[index];
    // Calcule le montant cible à partir du temps cible et du taux horaire
    final double gainPerSecond = timer.hourlyRate / 3600.0;
    timer.targetAmount = targetDuration.inSeconds * gainPerSecond;
    saveTimers();
    notifyListeners();
  }
  // Définit le montant gagné actuel pour un timer
  void setCurrentGains(int index, double currentGains) {
    if (index < 0 || index >= _timers.length) return;
    final timer = _timers[index];
    timer.currentGains = currentGains;
    saveTimers();
    notifyListeners();
  }
  // Active/désactive le mode minuteur (timer inversé) pour le timer donné
  void toggleMinuteurMode(int index) {
    if (index < 0 || index >= _timers.length) return;
    final timer = _timers[index];
    
    // Sauvegarder l'état actuel du timer avant de changer de mode
    final wasRunning = timer.isRunning;
    if (wasRunning) {
      timer.internalTimer?.cancel();
      timer.isRunning = false;
      timer.recalculateTime();
      timer.pausedDuration = timer.elapsedDuration;
      timer.sessionStartTime = null;
    }
    
    // Changer de mode
    timer.isReverseMode = !timer.isReverseMode;
    
    // Restaurer l'état du timer dans le nouveau mode
    if (wasRunning) {
      timer.isRunning = true;
      timer.sessionStartTime = DateTime.now();
      _startInternalTimer(timer);
    }
    
    saveTimers();
    notifyListeners();
  }
  // Monnaie préférentielle (null = auto/localisation)
  // Only keep the first set of fields, getters, and methods. Remove all duplicates below this point.
  // Monnaie préférentielle (null = auto/localisation)
  String? _preferredCurrency;
  static const String _preferredCurrencyKey = 'preferred_currency';

  final StorageService storage;

  List<SingleTimer> _timers = [];
  int _selectedTimerIndex = 0;

  MultiTimerController({required this.storage}) {
    // Initialiser avec 2 timers par défaut
    _timers = [
      SingleTimer(id: 1, name: 'Timer 1', isActive: true),
      SingleTimer(id: 2, name: 'Timer 2', isActive: false),
    ];
    _loadPreferredCurrency();
  }

  Future<void> init() async {
    await loadTimers();
  }
  String? get preferredCurrency => _preferredCurrency;
  List<SingleTimer> get timers => _timers;
  List<SingleTimer> get activeTimers => _timers.where((t) => t.isActive).toList();
  int get selectedTimerIndex => _selectedTimerIndex;
  SingleTimer get selectedTimer => _timers[_selectedTimerIndex];

  Future<void> _loadPreferredCurrency() async {
    final value = await storage.getString(_preferredCurrencyKey);
    if (value != null && value.isNotEmpty) {
      _preferredCurrency = value;
    } else {
      _preferredCurrency = null;
    }
    notifyListeners();
  }

  Future<void> setPreferredCurrency(String? currency) async {
    _preferredCurrency = currency;
    if (currency == null) {
      await storage.remove(_preferredCurrencyKey);
    } else {
      await storage.setString(_preferredCurrencyKey, currency);
    }
    notifyListeners();
  }

  // Détection automatique (locale) si null
  String getEffectivePreferredCurrency([String? fallback]) {
    if (_preferredCurrency != null && _preferredCurrency!.isNotEmpty) {
      return _preferredCurrency!;
    }
    // TODO: détecter la devise locale automatiquement (ex: selon Locale ou device)
    // Pour l'instant, fallback à l'euro
    return fallback ?? '€';
  }


  // Persistence
  Future<void> saveTimers() async {
    final timersJson = _timers.map((t) => t.toJson()).toList();
    await storage.setString('timers', jsonEncode(timersJson));
  }

  Future<void> loadTimers() async {
    final timersString = await storage.getString('timers');
    if (timersString != null && timersString.isNotEmpty) {
      try {
        final List<dynamic> timersJson = jsonDecode(timersString);
        _timers = timersJson.map((json) => SingleTimer.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Error loading timers: $e');
      }
    }

    // Démarrer les timers qui étaient en cours
    for (var timer in _timers) {
      if (timer.isRunning) {
        timer.recalculateTime();
        _startInternalTimer(timer);
      } else {
        timer.elapsedDuration = timer.pausedDuration;
        timer.calculateGains();
      }
    }

    notifyListeners();
  }

  void selectTimer(int index) {
    if (index >= 0 && index < _timers.length) {
      _selectedTimerIndex = index;
      notifyListeners();
    }
  }

  void toggleTimerActive(int index) {
    if (index >= 0 && index < _timers.length) {
      final timer = _timers[index];
      if (timer.isActive) {
        // Toujours autoriser la désactivation
        timer.isActive = false;
        saveTimers();
        notifyListeners();
      } else {
        // Activer seulement si moins de 2 timers actifs
        final activeCount = _timers.where((t) => t.isActive).length;
        if (activeCount < 2) {
          timer.isActive = true;
          saveTimers();
          notifyListeners();
        }
        // Sinon, ne rien faire (ou afficher un message si besoin)
      }
    }
  }

  // Ajouter un nouveau timer
  void addTimer(String name) {
    if (_timers.length >= 2) return; // Maximum 2 timers
    
    final newId = _timers.isEmpty ? 1 : _timers.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    final newTimer = SingleTimer(
      id: newId,
      name: name,
      isActive: false, // Par défaut inactif
    );
    
    _timers.add(newTimer);
    saveTimers();
    notifyListeners();
  }

  // Supprimer un timer
  void removeTimer(int index) {
    if (_timers.length <= 1) return; // Garder au moins 1 timer
    if (index < 0 || index >= _timers.length) return;
    
    // Arrêter le timer s'il est en cours
    if (_timers[index].isRunning) {
      stopTimer(index);
    }
    
    _timers.removeAt(index);
    
    // Ajuster l'index sélectionné si nécessaire
    if (_selectedTimerIndex >= _timers.length) {
      _selectedTimerIndex = _timers.length - 1;
    }
    
    saveTimers();
    notifyListeners();
  }

  // Timer controls pour un timer spécifique
  void startTimer(int index) {
    if (index < 0 || index >= _timers.length) return;
    final timer = _timers[index];
    if (timer.isRunning) return;

    timer.isRunning = true;
    timer.sessionStartTime = DateTime.now();
    _startInternalTimer(timer);
    saveTimers();
    notifyListeners();
  }

  void stopTimer(int index) {
    if (index < 0 || index >= _timers.length) return;
    final timer = _timers[index];
    if (!timer.isRunning) return;

    timer.internalTimer?.cancel();
    timer.isRunning = false;
    timer.recalculateTime();
    timer.pausedDuration = timer.elapsedDuration;
    timer.sessionStartTime = null;
    saveTimers();
    notifyListeners();
  }

  void resetTimer(int index) {
    if (index < 0 || index >= _timers.length) return;
    final timer = _timers[index];

    timer.internalTimer?.cancel();
    timer.isRunning = false;
    timer.elapsedDuration = Duration.zero;
    timer.pausedDuration = Duration.zero;
    timer.currentGains = 0.0;
    timer.sessionStartTime = null;
    saveTimers();
    notifyListeners();
  }

  // Édition manuelle du temps d'un timer
  void editTimerTime(int index) {
    if (index < 0 || index >= _timers.length) return;
    saveTimers();
    notifyListeners();
  }

  // Contrôles globaux
  void startAllTimers() {
    // Capturer le temps exact AVANT de démarrer les timers
    final now = DateTime.now();
    
    for (int i = 0; i < _timers.length; i++) {
      if (_timers[i].isActive && !_timers[i].isRunning) {
        // Utiliser le même timestamp pour tous les timers
        _timers[i].isRunning = true;
        _timers[i].sessionStartTime = now;
        _timers[i].pausedDuration = _timers[i].elapsedDuration;
        _startInternalTimer(_timers[i]);
      }
    }
    notifyListeners();
    saveTimers();
  }

  void stopAllTimers() {
    for (int i = 0; i < _timers.length; i++) {
      if (_timers[i].isRunning) {
        stopTimer(i);
      }
    }
  }

  void resetAllTimers() {
    for (int i = 0; i < _timers.length; i++) {
      if (_timers[i].isActive) {
        resetTimer(i);
      }
    }
  }

  void synchronizeTimers() {
    if (_timers.isEmpty) return;
    
    // Synchroniser tous les timers actifs sur le temps du premier timer actif
    final firstActiveTimer = activeTimers.isNotEmpty ? activeTimers.first : null;
    if (firstActiveTimer == null) return;

    final refDuration = firstActiveTimer.elapsedDuration;
    final wasRunning = firstActiveTimer.isRunning;
    
    // Capturer le temps exact MAINTENANT pour synchronisation parfaite
    final now = DateTime.now();

    for (var timer in activeTimers) {
      if (timer.id == firstActiveTimer.id) continue;
      
      // Arrêter le timer s'il tourne
      if (timer.isRunning) {
        timer.internalTimer?.cancel();
        timer.isRunning = false;
      }

      // Synchroniser le temps
      timer.elapsedDuration = refDuration;
      timer.pausedDuration = refDuration;
      timer.sessionStartTime = null;
      timer.calculateGains();

      // Redémarrer si le timer de référence tournait
      if (wasRunning) {
        timer.isRunning = true;
        // IMPORTANT : Utiliser le même timestamp pour tous !
        timer.sessionStartTime = now;
        timer.pausedDuration = refDuration;
        _startInternalTimer(timer);
      }
    }

    saveTimers();
    notifyListeners();
  }

  void _startInternalTimer(SingleTimer timer) {
    timer.internalTimer?.cancel();
    timer.internalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      timer.recalculateTime();
      
      // Vérifier si en mode minuteur, le temps restant est écoulé
      if (timer.isReverseMode && timer.getRemainingTime() != null && timer.getRemainingTime()!.inSeconds <= 0) {
        stopTimer(timer.id);
      }
      
      notifyListeners();
    });
  }

  // Setters pour le timer sélectionné
  void setHourlyRate(double newRate) {
    selectedTimer.hourlyRate = newRate;
    selectedTimer.rateTitle = 'Taux Personnalisé';
    selectedTimer.calculateGains();
    saveTimers();
    notifyListeners();
  }

  // Mise à jour du taux horaire sans modifier le rateTitle
  void updateHourlyRateOnly(double newRate) {
    selectedTimer.hourlyRate = newRate;
    selectedTimer.calculateGains();
    saveTimers();
    notifyListeners();
  }

  void setCurrency(String newCurrency) {
    selectedTimer.currency = newCurrency;
    saveTimers();
    notifyListeners();
  }

  void setRateTitle(String title) {
    selectedTimer.rateTitle = title;
    saveTimers();
    notifyListeners();
  }

  void setRateIcon(String? icon) {
    selectedTimer.rateIcon = icon;
    saveTimers();
    notifyListeners();
  }

  void setRateSourceUrl(String? url) {
    selectedTimer.rateSourceUrl = url;
    saveTimers();
    notifyListeners();
  }

  void setNetRatePercentage(double percentage) {
    selectedTimer.netRatePercentage = percentage.clamp(0.0, 100.0);
    selectedTimer.calculateGains();
    saveTimers();
    notifyListeners();
  }

  void setWeeklyHours(double newHours) {
    selectedTimer.weeklyHours = newHours;
    saveTimers();
    notifyListeners();
  }

  void setTimerName(int index, String name) {
    if (index >= 0 && index < _timers.length) {
      _timers[index].name = name;
      saveTimers();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.internalTimer?.cancel();
    }
    super.dispose();
  }
}
