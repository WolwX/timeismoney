// lib/models/single_timer.dart

import 'dart:async';

class SingleTimer {
  final int id;
  String name;
  bool isActive;
  bool isRunning;
  
  Duration elapsedDuration;
  Duration pausedDuration;
  DateTime? sessionStartTime;
  
  double hourlyRate;
  String currency;
  double currentGains;
  String rateTitle;
  double netRatePercentage;
  double weeklyHours;
  
  Timer? internalTimer;

  SingleTimer({
    required this.id,
    required this.name,
    this.isActive = true,
    this.isRunning = false,
    this.elapsedDuration = Duration.zero,
    this.pausedDuration = Duration.zero,
    this.sessionStartTime,
    this.hourlyRate = 15.00,
    this.currency = '€',
    this.currentGains = 0.0,
    this.rateTitle = 'Taux Personnalisé',
    this.netRatePercentage = 77.0,
    this.weeklyHours = 35.0,
  });

  double get hoursPerMonth => (weeklyHours * 52) / 12;
  double get netConversionFactor => netRatePercentage / 100.0;

  void calculateGains() {
    final double totalSeconds = elapsedDuration.inSeconds.toDouble();
    final double gainPerSecond = hourlyRate / 3600.0;
    currentGains = totalSeconds * gainPerSecond;
  }

  void recalculateTime() {
    if (sessionStartTime == null) return;
    final timeSinceStart = DateTime.now().difference(sessionStartTime!);
    elapsedDuration = pausedDuration + timeSinceStart;
    calculateGains();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'isRunning': isRunning,
      'elapsedDurationSeconds': elapsedDuration.inSeconds,
      'pausedDurationSeconds': pausedDuration.inSeconds,
      'sessionStartTime': sessionStartTime?.toIso8601String(),
      'hourlyRate': hourlyRate,
      'currency': currency,
      'currentGains': currentGains,
      'rateTitle': rateTitle,
      'netRatePercentage': netRatePercentage,
      'weeklyHours': weeklyHours,
    };
  }

  factory SingleTimer.fromJson(Map<String, dynamic> json) {
    return SingleTimer(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
      isRunning: json['isRunning'] as bool? ?? false,
      elapsedDuration: Duration(seconds: json['elapsedDurationSeconds'] as int? ?? 0),
      pausedDuration: Duration(seconds: json['pausedDurationSeconds'] as int? ?? 0),
      sessionStartTime: json['sessionStartTime'] != null 
          ? DateTime.tryParse(json['sessionStartTime'] as String)
          : null,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 15.00,
      currency: json['currency'] as String? ?? '€',
      currentGains: (json['currentGains'] as num?)?.toDouble() ?? 0.0,
      rateTitle: json['rateTitle'] as String? ?? 'Taux Personnalisé',
      netRatePercentage: (json['netRatePercentage'] as num?)?.toDouble() ?? 77.0,
      weeklyHours: (json['weeklyHours'] as num?)?.toDouble() ?? 35.0,
    );
  }
}
