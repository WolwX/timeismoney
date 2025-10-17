// lib/services/celebration_manager.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:timeismoney/services/storage_service.dart';

/// Représente une animation de fête en attente
class PendingCelebration {
  final String timerName;
  final DateTime triggeredAt;
  final double? targetAmount;
  final String currency;

  PendingCelebration({
    required this.timerName,
    required this.triggeredAt,
    this.targetAmount,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
    'timerName': timerName,
    'triggeredAt': triggeredAt.toIso8601String(),
    'targetAmount': targetAmount,
    'currency': currency,
  };

  factory PendingCelebration.fromJson(Map<String, dynamic> json) => PendingCelebration(
    timerName: json['timerName'],
    triggeredAt: DateTime.parse(json['triggeredAt']),
    targetAmount: json['targetAmount'],
    currency: json['currency'],
  );
}

/// Gestionnaire des animations de fête
class CelebrationManager extends ChangeNotifier {
  static const String _pendingCelebrationsKey = 'pending_celebrations';

  final StorageService storage;
  final List<PendingCelebration> _pendingCelebrations = [];

  CelebrationManager({required this.storage}) {
    _loadPendingCelebrations();
  }

  List<PendingCelebration> get pendingCelebrations => List.unmodifiable(_pendingCelebrations);

  /// Ajoute une animation de fête en attente
  Future<void> addPendingCelebration(PendingCelebration celebration) async {
    _pendingCelebrations.add(celebration);
    await _savePendingCelebrations();
    notifyListeners();
  }

  /// Supprime et retourne la première animation en attente
  PendingCelebration? consumeNextCelebration() {
    if (_pendingCelebrations.isEmpty) return null;

    final celebration = _pendingCelebrations.removeAt(0);
    _savePendingCelebrations();
    notifyListeners();
    return celebration;
  }

  /// Vérifie s'il y a des animations en attente
  bool get hasPendingCelebrations => _pendingCelebrations.isNotEmpty;

  /// Vide toutes les animations en attente
  Future<void> clearAllPendingCelebrations() async {
    _pendingCelebrations.clear();
    await storage.remove(_pendingCelebrationsKey);
    notifyListeners();
  }

  Future<void> _loadPendingCelebrations() async {
    try {
      final data = await storage.getString(_pendingCelebrationsKey);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(data);
        _pendingCelebrations.clear();
        _pendingCelebrations.addAll(
          jsonList.map((json) => PendingCelebration.fromJson(json)).toList()
        );
      }
    } catch (e) {
      debugPrint('Error loading pending celebrations: $e');
      _pendingCelebrations.clear();
    }
    notifyListeners();
  }

  Future<void> _savePendingCelebrations() async {
    try {
      final jsonList = _pendingCelebrations.map((c) => c.toJson()).toList();
      await storage.setString(_pendingCelebrationsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving pending celebrations: $e');
    }
  }
}