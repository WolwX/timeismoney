// lib/providers/multi_timer_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:timeismoney/models/single_timer.dart';
import 'package:timeismoney/services/storage_service.dart';
import 'package:timeismoney/services/notification_service.dart';
import 'package:timeismoney/services/celebration_manager.dart';

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
  final NotificationService notificationService;
  final CelebrationManager celebrationManager;

  List<SingleTimer> _timers = [];
  int _selectedTimerIndex = 0;

  // Suivi des paliers de gain atteints pour éviter les notifications répétées
  final Map<int, Set<double>> _notifiedMilestones = {};
  // Suivi des heures notifiées pour éviter les doublons
  final Map<int, Set<int>> _notifiedHours = {};

  // Préférences de notifications
  bool _notificationsEnabled = true;
  bool _timerFinishedNotificationsEnabled = true;
  bool _gainMilestoneNotificationsEnabled = true;
  bool _hourlyNotificationsEnabled = false;
  bool _celebrationAnimationEnabled = true;

  // Getters pour les préférences de notifications
  bool get notificationsEnabled => _notificationsEnabled;
  bool get timerFinishedNotificationsEnabled => _timerFinishedNotificationsEnabled;
  bool get gainMilestoneNotificationsEnabled => _gainMilestoneNotificationsEnabled;
  bool get hourlyNotificationsEnabled => _hourlyNotificationsEnabled;
  bool get celebrationAnimationEnabled => _celebrationAnimationEnabled;

  MultiTimerController({
    required this.storage,
    required this.notificationService,
    required this.celebrationManager,
  }) {
    // Initialiser avec 2 timers par défaut
    _timers = [
      SingleTimer(id: 1, name: 'Timer 1', isActive: true),
      SingleTimer(id: 2, name: 'Timer 2', isActive: false),
    ];
    _loadPreferredCurrency();
  }

  Future<void> init() async {
    await loadTimers();
    await _loadNotificationPreferences();
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

  Future<void> _loadNotificationPreferences() async {
    _notificationsEnabled = await storage.getNotificationsEnabled() ?? true;
    _timerFinishedNotificationsEnabled = await storage.getTimerFinishedNotificationsEnabled() ?? true;
    _gainMilestoneNotificationsEnabled = await storage.getGainMilestoneNotificationsEnabled() ?? true;
    _hourlyNotificationsEnabled = await storage.getHourlyNotificationsEnabled() ?? false;
    _celebrationAnimationEnabled = await storage.getCelebrationAnimationEnabled() ?? true;
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

  // Setters pour les préférences de notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await storage.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<void> setTimerFinishedNotificationsEnabled(bool enabled) async {
    _timerFinishedNotificationsEnabled = enabled;
    await storage.setTimerFinishedNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<void> setGainMilestoneNotificationsEnabled(bool enabled) async {
    _gainMilestoneNotificationsEnabled = enabled;
    await storage.setGainMilestoneNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<void> setHourlyNotificationsEnabled(bool enabled) async {
    _hourlyNotificationsEnabled = enabled;
    await storage.setHourlyNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<void> setCelebrationAnimationEnabled(bool enabled) async {
    _celebrationAnimationEnabled = enabled;
    await storage.setCelebrationAnimationEnabled(enabled);
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
    
    // Nettoyer les paliers notifiés pour ce timer
    _notifiedMilestones.remove(_timers[index].id);
    _notifiedHours.remove(_timers[index].id);
    
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
    if (index < 0 || index >= _timers.length) {
      debugPrint('stopTimer called with invalid index: $index, timers length: ${_timers.length}');
      return;
    }
    final timer = _timers[index];
    if (!timer.isRunning) {
      debugPrint('stopTimer called but timer ${timer.name} is not running');
      return;
    }

    debugPrint('Stopping timer ${timer.name} at index $index');
    timer.internalTimer?.cancel();
    timer.isRunning = false;
    timer.recalculateTime();
    timer.pausedDuration = timer.elapsedDuration;
    timer.sessionStartTime = null;
    saveTimers();
    notifyListeners();
    debugPrint('Timer ${timer.name} stopped successfully, isRunning: ${timer.isRunning}');
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

    // Réinitialiser les paliers notifiés pour ce timer
    _notifiedMilestones[timer.id]?.clear();
    _notifiedHours[timer.id]?.clear();

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

  // Vérifier les paliers de gain atteints pour les notifications
  void _checkGainMilestones(SingleTimer timer) {
    if (!_notificationsEnabled) return;

    final timerId = timer.id;
    final currentGains = timer.currentGains;
    final elapsedHours = timer.elapsedDuration.inHours;

    // Initialiser les ensembles des paliers notifiés pour ce timer s'il n'existe pas
    _notifiedMilestones.putIfAbsent(timerId, () => {});
    _notifiedHours.putIfAbsent(timerId, () => {});

    // Vérifier les paliers de gain si activés
    if (_gainMilestoneNotificationsEnabled) {
      // Définir les paliers de gain (10€, 25€, 50€, 100€, 250€, 500€, 1000€, etc.)
      final milestones = [10.0, 25.0, 50.0, 100.0, 250.0, 500.0, 1000.0, 2500.0, 5000.0, 10000.0];

      for (final milestone in milestones) {
        if (currentGains >= milestone && !_notifiedMilestones[timerId]!.contains(milestone)) {
          // Marquer ce palier comme notifié
          _notifiedMilestones[timerId]!.add(milestone);

          // Envoyer la notification
          notificationService.showGainMilestoneNotification(
            timerName: timer.name,
            milestoneAmount: milestone,
            currency: timer.currency,
            elapsedTime: timer.elapsedDuration,
          );
          break; // Ne notifier qu'un palier à la fois
        }
      }
    }

    // Vérifier les heures écoulées si activées
    if (_hourlyNotificationsEnabled && elapsedHours > 0) {
      // Notifier chaque heure complète (1h, 2h, 3h, etc.)
      if (!_notifiedHours[timerId]!.contains(elapsedHours)) {
        _notifiedHours[timerId]!.add(elapsedHours);

        // Envoyer la notification horaire
        notificationService.showPeriodicReminderNotification(
          timerName: timer.name,
          currentGains: currentGains,
          currency: timer.currency,
          elapsedTime: timer.elapsedDuration,
        );
      }
    }
  }

  void _startInternalTimer(SingleTimer timer) {
    timer.internalTimer?.cancel();
    timer.internalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      timer.recalculateTime();

      // Vérifier si en mode minuteur, le temps restant est écoulé
      if (timer.isReverseMode) {
        final remainingTime = timer.getRemainingTime();
        // Condition plus robuste : soit le temps restant est null (calcul impossible), 
        // soit il est <= 0, soit le montant cible est atteint
        final shouldStop = remainingTime == null || 
                          remainingTime.inSeconds <= 0 || 
                          (timer.targetAmount != null && timer.currentGains >= timer.targetAmount!);
        
        if (shouldStop) {
          debugPrint('Timer ${timer.name} reached 0 - remainingTime: $remainingTime, currentGains: ${timer.currentGains}, targetAmount: ${timer.targetAmount}, isRunning: ${timer.isRunning}');
          final timerIndex = _timers.indexOf(timer);
          debugPrint('Timer index: $timerIndex, timers length: ${_timers.length}');
          stopTimer(timerIndex);
          debugPrint('After stopTimer - isRunning: ${timer.isRunning}');
          // Notification pour la fin du timer si activée
          if (_notificationsEnabled && _timerFinishedNotificationsEnabled) {
            notificationService.showTimerFinishedNotification(
              timerName: timer.name,
              targetAmount: timer.targetAmount ?? 0.0,
              currency: timer.currency,
            );
          }
          // Enregistrer l'animation de fête si activée
          if (_celebrationAnimationEnabled) {
            celebrationManager.addPendingCelebration(PendingCelebration(
              timerName: timer.name,
              triggeredAt: DateTime.now(),
              targetAmount: timer.targetAmount,
              currency: timer.currency,
              achievedTime: timer.elapsedDuration, // Temps réellement passé
            ));
          }
        }
      } else {
        // Vérifier les paliers de gain en mode normal
        _checkGainMilestones(timer);
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
