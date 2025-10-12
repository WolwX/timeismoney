// lib/providers/multi_timer_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:timeismoney/models/single_timer.dart';
import 'package:timeismoney/services/storage_service.dart';

class MultiTimerController extends ChangeNotifier {
  final IStorageService storage;
  
  List<SingleTimer> _timers = [];
  int _selectedTimerIndex = 0;

  MultiTimerController({required this.storage}) {
    // Initialiser avec 2 timers par défaut
    _timers = [
      SingleTimer(id: 1, name: 'Timer 1', isActive: true),
      SingleTimer(id: 2, name: 'Timer 2', isActive: false),
    ];
  }

  List<SingleTimer> get timers => _timers;
  List<SingleTimer> get activeTimers => _timers.where((t) => t.isActive).toList();
  int get selectedTimerIndex => _selectedTimerIndex;
  SingleTimer get selectedTimer => _timers[_selectedTimerIndex];

  Future<void> init() async {
    await loadTimers();
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
      _timers[index].isActive = !_timers[index].isActive;
      saveTimers();
      notifyListeners();
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

  // Contrôles globaux
  void startAllTimers() {
    for (int i = 0; i < _timers.length; i++) {
      if (_timers[i].isActive && !_timers[i].isRunning) {
        startTimer(i);
      }
    }
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
        timer.sessionStartTime = DateTime.now();
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
