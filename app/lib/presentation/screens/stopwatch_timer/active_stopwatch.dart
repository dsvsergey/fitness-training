import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/fitness/fitness.dart';

/// The set a stopwatch is timing.
class StopwatchTarget {
  const StopwatchTarget({
    required this.workoutSession,
    required this.machine,
    required this.traineeName,
  });

  final WorkoutSessionEntity workoutSession;
  final MachineEntity machine;
  final String traineeName;
}

/// The app's single stopwatch. It outlives [StopwatchTimerScreens], so a
/// coach can leave the screen while a set is still being timed.
///
/// Elapsed time is derived from wall-clock timestamps instead of counted
/// ticks, so it stays correct while the app is backgrounded or the device
/// sleeps.
@lazySingleton
class ActiveStopwatch extends ChangeNotifier {
  ActiveStopwatch({@ignoreParam DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final _completed = StreamController<StopwatchTarget>.broadcast();

  StopwatchTarget? _target;
  DateTime? _startedAt;
  Duration _accumulated = Duration.zero;
  bool _screenOpen = false;

  StopwatchTarget? get target => _target;

  bool get isRunning => _startedAt != null;

  /// Whether [StopwatchTimerScreens] is showing, which hides the bar.
  bool get isScreenOpen => _screenOpen;

  set isScreenOpen(bool open) {
    if (_screenOpen == open) return;
    _screenOpen = open;
    notifyListeners();
  }

  /// Has time on it, so it must survive the screen being closed.
  bool get isActive =>
      _target != null && (isRunning || _accumulated > Duration.zero);

  Duration get elapsed => _startedAt == null
      ? _accumulated
      : _accumulated + _now().difference(_startedAt!);

  /// Emits the target each time its session is saved.
  Stream<StopwatchTarget> get completed => _completed.stream;

  bool isTiming(WorkoutSessionEntity session) =>
      _target?.workoutSession.id == session.id;

  /// Points the stopwatch at [target]. An active stopwatch keeps its own
  /// target: callers check [isActive] first.
  void open(StopwatchTarget target) {
    if (isActive) return;
    _target = target;
    reset();
  }

  void start() {
    if (_target == null || isRunning) return;
    _startedAt = _now();
    notifyListeners();
  }

  void pause() {
    if (!isRunning) return;
    _accumulated = elapsed;
    _startedAt = null;
    notifyListeners();
  }

  void reset() {
    _startedAt = null;
    _accumulated = Duration.zero;
    notifyListeners();
  }

  /// Forgets a stopwatch that was opened but never started.
  void release() {
    if (!isActive && _target != null) clear();
  }

  void clear() {
    _target = null;
    reset();
  }

  /// The set was saved: stop timing it and tell listeners.
  void complete() {
    final target = _target;
    clear();
    if (target != null) _completed.add(target);
  }
}
