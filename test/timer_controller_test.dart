import 'package:flutter_test/flutter_test.dart';
import 'package:timeismoney/providers/timer_controller.dart';
import 'test_helpers/fake_storage.dart';

void main() {
  group('TimerController', () {
    late FakeStorage storage;
    late TimerController controller;

    setUp(() async {
      storage = FakeStorage();
      controller = TimerController(storage: storage);
      await controller.init();
    });

    test('initial defaults', () {
      expect(controller.isRunning, isFalse);
      expect(controller.elapsedDuration, Duration.zero);
      expect(controller.hourlyRate, 15.00);
      expect(controller.currency, '€');
    });

    test('start and stop updates elapsed and persists', () async {
  controller.startTimer();

  // simulate a short wait so the timer increments
  await Future.delayed(const Duration(milliseconds: 1100));

  // After a bit of time the elapsedDuration should have increased
  final beforeStop = controller.elapsedDuration.inSeconds;
  // ignore: avoid_print
  print('DEBUG: elapsed before stop = $beforeStop');
  expect(beforeStop, greaterThanOrEqualTo(1));

  controller.stopTimer();
  expect(controller.isRunning, isFalse);

  // give time for async persistence to complete
  await Future.delayed(const Duration(milliseconds: 20));

  // check elapsed after stop and stored paused
  final afterStop = controller.elapsedDuration.inSeconds;
  // ignore: avoid_print
  print('DEBUG: elapsed after stop = $afterStop');

  final paused = await storage.getPausedDurationSeconds();
  // ignore: avoid_print
  print('DEBUG: paused in storage = $paused');
  expect(paused, isNotNull);
  expect(paused! >= 1, isTrue);
    });

    test('reset clears durations', () async {
  controller.startTimer();
  await Future.delayed(const Duration(milliseconds: 1100));
  controller.resetSession();
      expect(controller.isRunning, isFalse);
      expect(controller.elapsedDuration, Duration.zero);
      final paused = await storage.getPausedDurationSeconds();
      expect(paused == null || paused == 0, isTrue);
    });
  });
}
