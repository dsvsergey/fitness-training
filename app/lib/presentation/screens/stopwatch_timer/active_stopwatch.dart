import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
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
  bool _notifyScheduled = false;
  final _inlineViews = <Object>{};

  StopwatchTarget? get target => _target;

  bool get isRunning => _startedAt != null;

  /// Whether [StopwatchTimerScreens] is showing, which hides the bar.
  bool get isScreenOpen => _screenOpen;

  set isScreenOpen(bool open) {
    if (_screenOpen == open) return;
    _screenOpen = open;
    _notify();
  }

  /// Whether a widget on the visible screen already shows the time, e.g. the
  /// Timer card of the machine being timed, which also hides the bar.
  bool get isShownInline => _inlineViews.isNotEmpty;

  void showInline(Object owner, bool shown) {
    final changed = shown ? _inlineViews.add(owner) : _inlineViews.remove(owner);
    if (changed) _notify();
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
    _notify();
  }

  void pause() {
    if (!isRunning) return;
    _accumulated = elapsed;
    _startedAt = null;
    _notify();
  }

  void reset() {
    _startedAt = null;
    _accumulated = Duration.zero;
    _notify();
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

  /// Widgets report themselves from initState, didChangeDependencies and
  /// dispose, while the tree is being built. Listeners react with setState,
  /// which is illegal then, so the notification waits for the frame to end.
  void _notify() {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      notifyListeners();
      return;
    }
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
  }
}
