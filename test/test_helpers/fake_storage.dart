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
}
