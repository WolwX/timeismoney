import 'package:timeismoney/services/storage_service.dart';

class FakeStorage implements IStorageService {
  final Map<String, Object?> _data = {};

  @override
  Future<bool?> getIsRunning() async => _data['isRunning'] as bool?;

  @override
  Future<void> setIsRunning(bool value) async => _data['isRunning'] = value;

  @override
  Future<String?> getSessionStartTime() async => _data['sessionStartTime'] as String?;

  @override
  Future<void> setSessionStartTime(String? isoString) async => _data['sessionStartTime'] = isoString;

  @override
  Future<int?> getPausedDurationSeconds() async => _data['pausedDurationSeconds'] as int?;

  @override
  Future<void> setPausedDurationSeconds(int seconds) async => _data['pausedDurationSeconds'] = seconds;

  @override
  Future<double?> getHourlyRate() async => _data['hourlyRate'] as double?;

  @override
  Future<void> setHourlyRate(double rate) async => _data['hourlyRate'] = rate;

  @override
  Future<String?> getCurrency() async => _data['currencySymbol'] as String?;

  @override
  Future<void> setCurrency(String symbol) async => _data['currencySymbol'] = symbol;

  @override
  Future<String?> getRateTitle() async => _data['rateTitle'] as String?;

  @override
  Future<void> setRateTitle(String title) async => _data['rateTitle'] = title;

  @override
  Future<double?> getNetRatePercentage() async => _data['netRatePercentage'] as double?;

  @override
  Future<void> setNetRatePercentage(double percentage) async => _data['netRatePercentage'] = percentage;

  @override
  Future<double?> getWeeklyHours() async => _data['weeklyHours'] as double?;

  @override
  Future<void> setWeeklyHours(double hours) async => _data['weeklyHours'] = hours;

  @override
  Future<String?> getString(String key) async => _data[key] as String?;

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<bool?> getNotificationsEnabled() async => _data['notificationsEnabled'] as bool? ?? true;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async => _data['notificationsEnabled'] = enabled;

  @override
  Future<bool?> getTimerFinishedNotificationsEnabled() async => _data['timerFinishedNotificationsEnabled'] as bool? ?? true;

  @override
  Future<void> setTimerFinishedNotificationsEnabled(bool enabled) async => _data['timerFinishedNotificationsEnabled'] = enabled;

  @override
  Future<bool?> getGainMilestoneNotificationsEnabled() async => _data['gainMilestoneNotificationsEnabled'] as bool? ?? true;

  @override
  Future<void> setGainMilestoneNotificationsEnabled(bool enabled) async => _data['gainMilestoneNotificationsEnabled'] = enabled;

  @override
  Future<bool?> getHourlyNotificationsEnabled() async => _data['hourlyNotificationsEnabled'] as bool? ?? false;

  @override
  Future<void> setHourlyNotificationsEnabled(bool enabled) async => _data['hourlyNotificationsEnabled'] = enabled;

  @override
  Future<bool?> getCelebrationAnimationEnabled() async => _data['celebrationAnimationEnabled'] as bool? ?? true;

  @override
  Future<void> setCelebrationAnimationEnabled(bool enabled) async => _data['celebrationAnimationEnabled'] = enabled;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}
