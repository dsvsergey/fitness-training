import 'package:fitness_training/domain/entities/fitness/fitness.dart';
import 'package:fitness_training/presentation/screens/stopwatch_timer/active_stopwatch.dart';
import 'package:fitness_training/presentation/screens/stopwatch_timer/stopwatch_timer_screens.dart';
import 'package:flutter_test/flutter_test.dart';

StopwatchTarget _target(int sessionId) => StopwatchTarget(
      workoutSession: WorkoutSessionEntity((b) => b
        ..id = sessionId
        ..programMachineId = 5
        ..traineeId = 2
        ..coachId = 1
        ..weight = 40
        ..sessionStatus = SessionStatusEnumEntity.planned),
      machine: MachineEntity((b) => b
        ..id = 7
        ..name = 'H2'),
      traineeName: 'Ann',
    );

void main() {
  late DateTime now;
  late ActiveStopwatch stopwatch;

  setUp(() {
    now = DateTime(2026, 9, 21, 10);
    stopwatch = ActiveStopwatch(now: () => now);
  });

  test('counts wall-clock time, so a backgrounded app loses nothing', () {
    stopwatch
      ..open(_target(1))
      ..start();
    now = now.add(const Duration(minutes: 3, seconds: 5));

    expect(stopwatch.elapsed, const Duration(minutes: 3, seconds: 5));
    expect(stopwatch.isRunning, isTrue);
  });

  test('pause keeps the time and resume continues from it', () {
    stopwatch
      ..open(_target(1))
      ..start();
    now = now.add(const Duration(seconds: 10, milliseconds: 450));
    stopwatch.pause();
    now = now.add(const Duration(minutes: 5));

    expect(stopwatch.elapsed, const Duration(seconds: 10, milliseconds: 450));

    stopwatch.start();
    now = now.add(const Duration(seconds: 2));
    expect(stopwatch.elapsed, const Duration(seconds: 12, milliseconds: 450));
  });

  test('reset zeroes the time but keeps the target', () {
    stopwatch
      ..open(_target(1))
      ..start();
    now = now.add(const Duration(seconds: 30));
    stopwatch
      ..pause()
      ..reset();

    expect(stopwatch.elapsed, Duration.zero);
    expect(stopwatch.target, isNotNull);
    expect(stopwatch.isActive, isFalse);
  });

  test('only one set is timed: an active stopwatch keeps its target', () {
    stopwatch
      ..open(_target(1))
      ..start();
    stopwatch.open(_target(2));

    expect(stopwatch.target!.workoutSession.id, 1);
    expect(stopwatch.isTiming(_target(1).workoutSession), isTrue);
  });

  test('an opened but never started stopwatch is released', () {
    stopwatch
      ..open(_target(1))
      ..release();

    expect(stopwatch.target, isNull);
  });

  test('a started stopwatch survives release, even when paused', () {
    stopwatch
      ..open(_target(1))
      ..start();
    now = now.add(const Duration(seconds: 1));
    stopwatch
      ..pause()
      ..release();

    expect(stopwatch.isActive, isTrue);
  });

  test('complete clears the stopwatch and reports the target', () async {
    stopwatch
      ..open(_target(1))
      ..start();
    final completed = stopwatch.completed.first;
    stopwatch.complete();

    expect((await completed).workoutSession.id, 1);
    expect(stopwatch.target, isNull);
    expect(stopwatch.isRunning, isFalse);
  });

  test('formats minutes and seconds, adding hours past the hour', () {
    expect(formatStopwatch(const Duration(seconds: 7)), '00:07');
    expect(formatStopwatch(const Duration(minutes: 12, seconds: 5)), '12:05');
    expect(
      formatStopwatch(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });
}
