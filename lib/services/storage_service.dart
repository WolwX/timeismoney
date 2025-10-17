// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Interface de stockage (pour faciliter les tests et l'injection)
abstract class IStorageService {
  Future<void> remove(String key);
  // Timer state
  Future<bool?> getIsRunning();
  Future<void> setIsRunning(bool value);

  Future<String?> getSessionStartTime();
  Future<void> setSessionStartTime(String? isoString);

  Future<int?> getPausedDurationSeconds();
  Future<void> setPausedDurationSeconds(int seconds);

  // Rates and preferences
  Future<double?> getHourlyRate();
  Future<void> setHourlyRate(double rate);

  Future<String?> getCurrency();
  Future<void> setCurrency(String symbol);

  Future<String?> getRateTitle();
  Future<void> setRateTitle(String title);

  Future<double?> getNetRatePercentage();
  Future<void> setNetRatePercentage(double percentage);

  Future<double?> getWeeklyHours();
  Future<void> setWeeklyHours(double hours);

  // Notification preferences
  Future<bool?> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);

  Future<bool?> getTimerFinishedNotificationsEnabled();
  Future<void> setTimerFinishedNotificationsEnabled(bool enabled);

  Future<bool?> getGainMilestoneNotificationsEnabled();
  Future<void> setGainMilestoneNotificationsEnabled(bool enabled);

  Future<bool?> getHourlyNotificationsEnabled();
  Future<void> setHourlyNotificationsEnabled(bool enabled);

  Future<bool?> getCelebrationAnimationEnabled();
  Future<void> setCelebrationAnimationEnabled(bool enabled);

  // Generic string storage for complex data (JSON)
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
}

/// Implémentation qui utilise SharedPreferences
class StorageService implements IStorageService {
  @override
  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }
  static const String _kIsRunningKey = 'isRunning';
  static const String _kSessionStartTimeKey = 'sessionStartTime';
  static const String _kPausedDurationKey = 'pausedDurationSeconds';
  static const String _kHourlyRateKey = 'hourlyRate';
  static const String _kCurrencyKey = 'currencySymbol';
  static const String _kRateTitleKey = 'rateTitle';
  static const String _kNetRatePercentageKey = 'netRatePercentage';
  static const String _kWeeklyHoursKey = 'weeklyHours';
  static const String _kNotificationsEnabledKey = 'notificationsEnabled';
  static const String _kTimerFinishedNotificationsEnabledKey = 'timerFinishedNotificationsEnabled';
  static const String _kGainMilestoneNotificationsEnabledKey = 'gainMilestoneNotificationsEnabled';
  static const String _kHourlyNotificationsEnabledKey = 'hourlyNotificationsEnabled';
  static const String _kCelebrationAnimationEnabledKey = 'celebrationAnimationEnabled';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<bool?> getIsRunning() async {
    final prefs = await _prefs;
    return prefs.getBool(_kIsRunningKey);
  }

  @override
  Future<void> setIsRunning(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_kIsRunningKey, value);
  }

  @override
  Future<String?> getSessionStartTime() async {
    final prefs = await _prefs;
    return prefs.getString(_kSessionStartTimeKey);
  }

  @override
  Future<void> setSessionStartTime(String? isoString) async {
    final prefs = await _prefs;
    if (isoString == null || isoString.isEmpty) {
      await prefs.remove(_kSessionStartTimeKey);
    } else {
      await prefs.setString(_kSessionStartTimeKey, isoString);
    }
  }

  @override
  Future<int?> getPausedDurationSeconds() async {
    final prefs = await _prefs;
    return prefs.getInt(_kPausedDurationKey);
  }

  @override
  Future<void> setPausedDurationSeconds(int seconds) async {
    final prefs = await _prefs;
    await prefs.setInt(_kPausedDurationKey, seconds);
  }

  @override
  Future<double?> getHourlyRate() async {
    final prefs = await _prefs;
    return prefs.getDouble(_kHourlyRateKey);
  }

  @override
  Future<void> setHourlyRate(double rate) async {
    final prefs = await _prefs;
    await prefs.setDouble(_kHourlyRateKey, rate);
  }

  @override
  Future<String?> getCurrency() async {
    final prefs = await _prefs;
    return prefs.getString(_kCurrencyKey);
  }

  @override
  Future<void> setCurrency(String symbol) async {
    final prefs = await _prefs;
    await prefs.setString(_kCurrencyKey, symbol);
  }

  @override
  Future<String?> getRateTitle() async {
    final prefs = await _prefs;
    return prefs.getString(_kRateTitleKey);
  }

  @override
  Future<void> setRateTitle(String title) async {
    final prefs = await _prefs;
    await prefs.setString(_kRateTitleKey, title);
  }

  @override
  Future<double?> getNetRatePercentage() async {
    final prefs = await _prefs;
    return prefs.getDouble(_kNetRatePercentageKey);
  }

  @override
  Future<void> setNetRatePercentage(double percentage) async {
    final prefs = await _prefs;
    await prefs.setDouble(_kNetRatePercentageKey, percentage);
  }

  @override
  Future<double?> getWeeklyHours() async {
    final prefs = await _prefs;
    return prefs.getDouble(_kWeeklyHoursKey);
  }

  @override
  Future<void> setWeeklyHours(double hours) async {
    final prefs = await _prefs;
    await prefs.setDouble(_kWeeklyHoursKey, hours);
  }

  @override
  Future<bool?> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_kNotificationsEnabledKey) ?? true; // Activé par défaut
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_kNotificationsEnabledKey, enabled);
  }

  @override
  Future<bool?> getTimerFinishedNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_kTimerFinishedNotificationsEnabledKey) ?? true; // Activé par défaut
  }

  @override
  Future<void> setTimerFinishedNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_kTimerFinishedNotificationsEnabledKey, enabled);
  }

  @override
  Future<bool?> getGainMilestoneNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_kGainMilestoneNotificationsEnabledKey) ?? true; // Activé par défaut
  }

  @override
  Future<void> setGainMilestoneNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_kGainMilestoneNotificationsEnabledKey, enabled);
  }

  @override
  Future<bool?> getHourlyNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_kHourlyNotificationsEnabledKey) ?? false; // Désactivé par défaut
  }

  @override
  Future<void> setHourlyNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_kHourlyNotificationsEnabledKey, enabled);
  }

  @override
  Future<bool?> getCelebrationAnimationEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_kCelebrationAnimationEnabledKey) ?? true; // Activé par défaut
  }

  @override
  Future<void> setCelebrationAnimationEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_kCelebrationAnimationEnabledKey, enabled);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }
}