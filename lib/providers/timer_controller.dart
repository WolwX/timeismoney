// lib/providers/timer_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:timeismoney/services/storage_service.dart';

class TimerController extends ChangeNotifier {
  final IStorageService storage;

  Timer? _timer;
  bool _isRunning = false;

  // Etat chronometre
  Duration _elapsedDuration = Duration.zero;
  Duration _pausedDuration = Duration.zero;
  DateTime? _sessionStartTime;

  // Parametres
  double _hourlyRate = 15.00;
  String _currency = '€';
  double _currentGains = 0.0;
  String _rateTitle = 'Taux Personnalisé';
  double _netRatePercentage = 77.0;
  double _weeklyHours = 35.0;

  // Getters
  bool get isRunning => _isRunning;
  Duration get elapsedDuration => _elapsedDuration;
  double get hourlyRate => _hourlyRate;
  String get currency => _currency;
  double get currentGains => _currentGains;
  String get rateTitle => _rateTitle;
  double get netRatePercentage => _netRatePercentage;
  double get weeklyHours => _weeklyHours;

  double get hoursPerMonth => (_weeklyHours * 52) / 12;
  double get netConversionFactor => _netRatePercentage / 100.0;

  // Constructor
  TimerController({required this.storage});

  // Async init to load persisted preferences
  Future<void> init() async {
    await loadPreferences();
  }

  // Persistence helpers
  Future<void> _saveTimerState() async {
    await storage.setIsRunning(_isRunning);
    await storage.setSessionStartTime(_sessionStartTime?.toIso8601String());
    await storage.setPausedDurationSeconds(_pausedDuration.inSeconds);
  }

  Future<void> _saveRatesPreferences() async {
    await storage.setHourlyRate(_hourlyRate);
    await storage.setCurrency(_currency);
    await storage.setRateTitle(_rateTitle);
    await storage.setNetRatePercentage(_netRatePercentage);
    await storage.setWeeklyHours(_weeklyHours);
  }

  Future<void> loadPreferences() async {
    _hourlyRate = await storage.getHourlyRate() ?? 15.00;
    _currency = await storage.getCurrency() ?? '€';
    _rateTitle = await storage.getRateTitle() ?? 'Taux Personnalisé';
    _netRatePercentage = await storage.getNetRatePercentage() ?? 77.0;
    _weeklyHours = await storage.getWeeklyHours() ?? 35.0;

    _isRunning = await storage.getIsRunning() ?? false;
    final startIso = await storage.getSessionStartTime();
    _pausedDuration = Duration(seconds: await storage.getPausedDurationSeconds() ?? 0);

    if (startIso != null && startIso.isNotEmpty) {
      _sessionStartTime = DateTime.tryParse(startIso);
    } else {
      _sessionStartTime = null;
    }

    if (_isRunning) {
      _recalculateTimeOnStartup();
      _startInternalTimer();
    } else {
      _elapsedDuration = _pausedDuration;
      _calculateGains();
    }

    notifyListeners();
  }

  void _recalculateTimeOnStartup() {
    if (_sessionStartTime == null) return;
    final timeSinceStart = DateTime.now().difference(_sessionStartTime!);
    _elapsedDuration = _pausedDuration + timeSinceStart;
    _calculateGains();
  }

  void _calculateGains() {
    final double totalSeconds = _elapsedDuration.inSeconds.toDouble();
    final double gainPerSecond = _hourlyRate / 3600.0;
    _currentGains = totalSeconds * gainPerSecond;
  }

  void _startInternalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recalculateTimeOnStartup();
      notifyListeners();
    });
  }

  // User actions
  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _sessionStartTime = DateTime.now();
    _saveTimerState();
    _startInternalTimer();
    notifyListeners();
  }

  void stopTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    _isRunning = false;
    _recalculateTimeOnStartup();
    _pausedDuration = _elapsedDuration;
    _sessionStartTime = null;
    _saveTimerState();
    notifyListeners();
  }

  void resetSession() {
    _timer?.cancel();
    _isRunning = false;
    _elapsedDuration = Duration.zero;
    _pausedDuration = Duration.zero;
    _currentGains = 0.0;
    _sessionStartTime = null;
    _saveTimerState();
    notifyListeners();
  }

  // Rate setters
  void setHourlyRate(double newRate) {
    _hourlyRate = newRate;
    _rateTitle = 'Taux Personnalisé';
    _saveRatesPreferences();
    _calculateGains();
    notifyListeners();
  }

  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    _saveRatesPreferences();
    notifyListeners();
  }

  void setRateTitle(String title) {
    _rateTitle = title;
    _saveRatesPreferences();
    notifyListeners();
  }

  void setNetRatePercentage(double percentage) {
    _netRatePercentage = percentage.clamp(0.0, 100.0);
    _saveRatesPreferences();
    _calculateGains();
    notifyListeners();
  }

  void setWeeklyHours(double newHours) {
    _weeklyHours = newHours;
    _saveRatesPreferences();
    notifyListeners();
  }
}
