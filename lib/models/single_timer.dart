// lib/models/single_timer.dart

import 'dart:async';

class SingleTimer {
  final int id;
  String name;
  bool isActive;
  bool isRunning;

  // Time tracking for normal mode (chrono)
  Duration normalElapsedDuration;
  Duration normalPausedDuration;
  
  // Time tracking for timer mode (minuteur)
  Duration timerElapsedDuration;
  Duration timerPausedDuration;

  // Current mode time (points to the appropriate mode's duration)
  Duration get elapsedDuration => isReverseMode ? timerElapsedDuration : normalElapsedDuration;
  set elapsedDuration(Duration value) {
    if (isReverseMode) {
      timerElapsedDuration = value;
    } else {
      normalElapsedDuration = value;
    }
  }

  Duration get pausedDuration => isReverseMode ? timerPausedDuration : normalPausedDuration;
  set pausedDuration(Duration value) {
    if (isReverseMode) {
      timerPausedDuration = value;
    } else {
      normalPausedDuration = value;
    }
  }

  DateTime? sessionStartTime;

  double hourlyRate;
  String currency;
  double currentGains;
  String rateTitle;
  String? rateIcon; // Icône emoji du préréglage
  String? rateSourceUrl; // URL vers la source officielle du taux
  double netRatePercentage;
  double weeklyHours;

  // Mode timer inversé
  bool isReverseMode;
  double? targetAmount;

  Timer? internalTimer;

  SingleTimer({
    required this.id,
    required this.name,
    this.isActive = true,
    this.isRunning = false,
    this.normalElapsedDuration = Duration.zero,
    this.normalPausedDuration = Duration.zero,
    this.timerElapsedDuration = Duration.zero,
    this.timerPausedDuration = Duration.zero,
    this.sessionStartTime,
    this.hourlyRate = 11.88,
    this.currency = '€',
    this.currentGains = 0.0,
    this.rateTitle = 'SMIC Français',
    this.rateIcon = '🇫🇷', // Drapeau français par défaut
    this.rateSourceUrl = 'https://www.service-public.fr/particuliers/vosdroits/F2300', // URL par défaut pour SMIC
    this.netRatePercentage = 77.6,
    this.weeklyHours = 35.0,
    this.isReverseMode = false,
    this.targetAmount,
  });

  double get hoursPerMonth => (weeklyHours * 52) / 12;
  double get netConversionFactor => netRatePercentage / 100.0;

  void calculateGains() {
    final double totalSeconds = elapsedDuration.inSeconds.toDouble();
    final double gainPerSecond = hourlyRate / 3600.0;
    currentGains = totalSeconds * gainPerSecond;
  }

  /// Pour le mode inversé : calcule le temps restant avant d'atteindre le montant cible
  Duration? getRemainingTime() {
    if (!isReverseMode || targetAmount == null || hourlyRate <= 0) return null;
    // Utilise le taux horaire net pour le calcul
    final double netHourlyRate = hourlyRate * netConversionFactor;
    final double gainPerSecond = netHourlyRate / 3600.0;
    final double secondsNeeded = targetAmount! / gainPerSecond;
    final double secondsElapsed = elapsedDuration.inSeconds.toDouble();
    final double secondsLeft = secondsNeeded - secondsElapsed;
    if (secondsLeft <= 0) return Duration.zero;
    return Duration(seconds: secondsLeft.round());
  }

  void recalculateTime() {
    if (sessionStartTime == null) return;
    final timeSinceStart = DateTime.now().difference(sessionStartTime!);
    elapsedDuration = pausedDuration + timeSinceStart;
    calculateGains();
  }

  // Permet d'éditer manuellement le temps écoulé
  void setManualTime(Duration newDuration) {
    elapsedDuration = newDuration;
    pausedDuration = newDuration;
    calculateGains();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'isRunning': isRunning,
      'normalElapsedDurationSeconds': normalElapsedDuration.inSeconds,
      'normalPausedDurationSeconds': normalPausedDuration.inSeconds,
      'timerElapsedDurationSeconds': timerElapsedDuration.inSeconds,
      'timerPausedDurationSeconds': timerPausedDuration.inSeconds,
      'sessionStartTime': sessionStartTime?.toIso8601String(),
      'hourlyRate': hourlyRate,
      'currency': currency,
      'currentGains': currentGains,
      'rateTitle': rateTitle,
      'rateIcon': rateIcon,
      'rateSourceUrl': rateSourceUrl,
      'netRatePercentage': netRatePercentage,
      'weeklyHours': weeklyHours,
      'isReverseMode': isReverseMode,
      'targetAmount': targetAmount,
    };
  }

  factory SingleTimer.fromJson(Map<String, dynamic> json) {
    return SingleTimer(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
      isRunning: json['isRunning'] as bool? ?? false,
      normalElapsedDuration: Duration(seconds: json['normalElapsedDurationSeconds'] as int? ?? json['elapsedDurationSeconds'] as int? ?? 0),
      normalPausedDuration: Duration(seconds: json['normalPausedDurationSeconds'] as int? ?? json['pausedDurationSeconds'] as int? ?? 0),
      timerElapsedDuration: Duration(seconds: json['timerElapsedDurationSeconds'] as int? ?? 0),
      timerPausedDuration: Duration(seconds: json['timerPausedDurationSeconds'] as int? ?? 0),
      sessionStartTime: json['sessionStartTime'] != null 
          ? DateTime.tryParse(json['sessionStartTime'] as String)
          : null,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 15.00,
      currency: json['currency'] as String? ?? '€',
      currentGains: (json['currentGains'] as num?)?.toDouble() ?? 0.0,
      rateTitle: json['rateTitle'] as String? ?? 'Taux Personnalisé',
      rateIcon: json['rateIcon'] as String?,
      rateSourceUrl: json['rateSourceUrl'] as String?,
      netRatePercentage: (json['netRatePercentage'] as num?)?.toDouble() ?? 77.0,
      weeklyHours: (json['weeklyHours'] as num?)?.toDouble() ?? 35.0,
      isReverseMode: json['isReverseMode'] as bool? ?? false,
      targetAmount: (json['targetAmount'] as num?)?.toDouble(),
    );
  }
}
