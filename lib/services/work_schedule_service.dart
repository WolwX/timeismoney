// lib/services/work_schedule_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Représente une plage horaire spécifique
class TimeSlot {
  final String startTime; // Format "HH:MM"
  final String endTime;   // Format "HH:MM"

  const TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  /// Crée depuis JSON
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '17:00',
    );
  }

  /// Vérifie si l'heure actuelle est dans cette plage
  bool isCurrentlyInSlot() {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    return _isTimeBetween(currentTime, start, end);
  }

  /// Parse une string "HH:MM" en TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Vérifie si une heure est entre deux autres
  bool _isTimeBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => Object.hash(startTime, endTime);
}

/// Représente les horaires de travail pour un jour spécifique
class WorkDaySchedule {
  final bool enabled;
  final List<TimeSlot> timeSlots;

  const WorkDaySchedule({
    required this.enabled,
    required this.timeSlots,
  });

  /// Crée un horaire par défaut (9h-17h)
  factory WorkDaySchedule.defaultSchedule() {
    return const WorkDaySchedule(
      enabled: false,
      timeSlots: [TimeSlot(startTime: '09:00', endTime: '17:00')],
    );
  }

  /// Convertit en JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
    };
  }

  /// Crée depuis JSON
  factory WorkDaySchedule.fromJson(Map<String, dynamic> json) {
    final timeSlotsJson = json['timeSlots'] as List<dynamic>? ?? [];
    final timeSlots = timeSlotsJson
        .map((slotJson) => TimeSlot.fromJson(slotJson as Map<String, dynamic>))
        .toList();

    // Si pas de plages définies, créer une par défaut
    final slots = timeSlots.isEmpty
        ? [const TimeSlot(startTime: '09:00', endTime: '17:00')]
        : timeSlots;

    return WorkDaySchedule(
      enabled: json['enabled'] ?? false,
      timeSlots: slots,
    );
  }

  /// Vérifie si l'heure actuelle est dans les horaires de travail
  bool isCurrentlyInWorkHours() {
    if (!enabled || timeSlots.isEmpty) return false;

    // Vérifier si l'heure actuelle est dans au moins une plage
    return timeSlots.any((slot) => slot.isCurrentlyInSlot());
  }

  /// Ajoute une nouvelle plage horaire
  WorkDaySchedule addTimeSlot(TimeSlot slot) {
    return WorkDaySchedule(
      enabled: enabled,
      timeSlots: [...timeSlots, slot],
    );
  }

  /// Supprime une plage horaire à l'index donné
  WorkDaySchedule removeTimeSlot(int index) {
    if (index < 0 || index >= timeSlots.length) return this;

    final newSlots = List<TimeSlot>.from(timeSlots)..removeAt(index);
    return WorkDaySchedule(
      enabled: enabled,
      timeSlots: newSlots.isEmpty ? [const TimeSlot(startTime: '09:00', endTime: '17:00')] : newSlots,
    );
  }

  /// Met à jour une plage horaire à l'index donné
  WorkDaySchedule updateTimeSlot(int index, TimeSlot newSlot) {
    if (index < 0 || index >= timeSlots.length) return this;

    final newSlots = List<TimeSlot>.from(timeSlots);
    newSlots[index] = newSlot;
    return WorkDaySchedule(
      enabled: enabled,
      timeSlots: newSlots,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkDaySchedule &&
        other.enabled == enabled &&
        _listEquals(other.timeSlots, timeSlots);
  }

  @override
  int get hashCode => Object.hash(enabled, Object.hashAll(timeSlots));

  bool _listEquals(List<TimeSlot> a, List<TimeSlot> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Service de gestion des horaires de travail hebdomadaires
class WorkScheduleService extends ChangeNotifier {
  final Map<String, WorkDaySchedule> _weeklySchedule = {};
  bool _isEnabled = false; // Planning activé/désactivé globalement

  WorkScheduleService() {
    // Initialiser avec des horaires par défaut pour chaque jour
    _initializeDefaultSchedule();
  }

  void _initializeDefaultSchedule() {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    for (final day in days) {
      _weeklySchedule[day] = WorkDaySchedule.defaultSchedule();
    }
  }

  /// Récupère l'horaire pour un jour spécifique
  WorkDaySchedule getDaySchedule(String day) {
    return _weeklySchedule[day] ?? WorkDaySchedule.defaultSchedule();
  }

  /// Met à jour l'horaire pour un jour spécifique
  void updateDaySchedule(String day, WorkDaySchedule schedule) {
    _weeklySchedule[day] = schedule;
    notifyListeners();
  }

  /// Active/désactive un jour de travail
  void toggleDayEnabled(String day, bool enabled) {
    final current = getDaySchedule(day);
    updateDaySchedule(day, WorkDaySchedule(
      enabled: enabled,
      timeSlots: current.timeSlots,
    ));
  }

  /// Met à jour l'heure de début de la première plage horaire pour un jour
  void updateStartTime(String day, String startTime) {
    final current = getDaySchedule(day);
    if (current.timeSlots.isNotEmpty) {
      final updatedSlot = TimeSlot(
        startTime: startTime,
        endTime: current.timeSlots[0].endTime,
      );
      updateDaySchedule(day, WorkDaySchedule(
        enabled: current.enabled,
        timeSlots: [updatedSlot, ...current.timeSlots.sublist(1)],
      ));
    }
  }

  /// Met à jour l'heure de fin de la première plage horaire pour un jour
  void updateEndTime(String day, String endTime) {
    final current = getDaySchedule(day);
    if (current.timeSlots.isNotEmpty) {
      final updatedSlot = TimeSlot(
        startTime: current.timeSlots[0].startTime,
        endTime: endTime,
      );
      updateDaySchedule(day, WorkDaySchedule(
        enabled: current.enabled,
        timeSlots: [updatedSlot, ...current.timeSlots.sublist(1)],
      ));
    }
  }

  /// Vérifie si c'est actuellement l'heure de travail
  bool isCurrentlyWorkTime() {
    if (!_isEnabled) return false; // Planning désactivé globalement
    
    final now = DateTime.now();
    final dayName = _getCurrentDayName(now.weekday);
    final daySchedule = getDaySchedule(dayName);
    return daySchedule.isCurrentlyInWorkHours();
  }

  /// Active/désactive le planning globalement
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
  }

  /// Vérifie si le planning est activé globalement
  bool get isEnabled => _isEnabled;

  /// Obtient le nom du jour actuel (lundi=1, dimanche=7)
  String _getCurrentDayName(int weekday) {
    const dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return dayNames[weekday - 1]; // weekday commence à 1 pour lundi
  }

  /// Vérifie si au moins un jour est activé
  bool hasActiveDays() {
    return _weeklySchedule.values.any((schedule) => schedule.enabled);
  }

  /// Ajoute une nouvelle plage horaire à un jour
  void addTimeSlot(String day, TimeSlot slot) {
    final current = getDaySchedule(day);
    updateDaySchedule(day, current.addTimeSlot(slot));
  }

  /// Supprime une plage horaire d'un jour
  void removeTimeSlot(String day, int slotIndex) {
    final current = getDaySchedule(day);
    updateDaySchedule(day, current.removeTimeSlot(slotIndex));
  }

  /// Met à jour une plage horaire d'un jour
  void updateTimeSlot(String day, int slotIndex, TimeSlot newSlot) {
    final current = getDaySchedule(day);
    updateDaySchedule(day, current.updateTimeSlot(slotIndex, newSlot));
  }

  /// Charge les horaires depuis le stockage
  void loadFromStorage(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // Charger l'état global du planning
      _isEnabled = data['isEnabled'] ?? false;
      
      // Charger les horaires de chaque jour
      final scheduleData = data['schedule'] ?? data;
      if (scheduleData is Map<String, dynamic>) {
        scheduleData.forEach((day, dayScheduleData) {
          if (dayScheduleData is Map<String, dynamic> && day != 'isEnabled') {
            _weeklySchedule[day] = WorkDaySchedule.fromJson(dayScheduleData);
          }
        });
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des horaires: $e');
    }
  }

  /// Sauvegarde les horaires pour le stockage
  String saveToStorage() {
    final data = {
      'isEnabled': _isEnabled,
      'schedule': _weeklySchedule.map((day, schedule) => MapEntry(day, schedule.toJson())),
    };
    return json.encode(data);
  }

  /// Réinitialise tous les horaires aux valeurs par défaut
  void resetToDefaults() {
    _initializeDefaultSchedule();
    notifyListeners();
  }
}