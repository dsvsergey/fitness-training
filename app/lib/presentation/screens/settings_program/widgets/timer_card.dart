import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/resources/localization/l10n/app_localizations.dart';
import '../../../../core/resources/resources.dart';
import '../../../../domain/entities/fitness/fitness.dart';
import '../../../widgets/custom_timer_widget.dart';
import '../../stopwatch_timer/active_stopwatch.dart';
import '../../stopwatch_timer/stopwatch_timer_screens.dart';

/// The Timer card. While the stopwatch times [session], the card shows the
/// running time itself and the app-wide stopwatch bar steps aside for it.
class TimerCard extends StatefulWidget {
  const TimerCard({required this.session, required this.onPressed, super.key});

  final WorkoutSessionEntity? session;
  final VoidCallback? onPressed;

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  final _stopwatch = GetIt.I<ActiveStopwatch>();
  Timer? _tick;
  bool _routeIsCurrent = true;

  bool get _timing =>
      widget.session != null &&
      _stopwatch.isActive &&
      _stopwatch.isTiming(widget.session!);

  @override
  void initState() {
    super.initState();
    _stopwatch.addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rebuilt whenever a route is pushed on top of this screen or popped.
    _routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    _sync();
  }

  @override
  void didUpdateWidget(TimerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _stopwatch
      ..removeListener(_onChanged)
      ..showInline(this, false);
    super.dispose();
  }

  void _onChanged() {
    _sync();
    if (mounted) setState(() {});
  }

  void _sync() {
    final timing = _timing;
    _stopwatch.showInline(this, timing && _routeIsCurrent);

    final tick = timing && _stopwatch.isRunning;
    if (tick && _tick == null) {
      _tick = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => setState(() {}),
      );
    } else if (!tick) {
      _tick?.cancel();
      _tick = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTimerWidget(
      key: const ValueKey('timer-card'),
      title: _timing
          ? formatStopwatch(_stopwatch.elapsed)
          : AppLocalizations.of(context)!.timer,
      image: AppSvgs.timer,
      onPressed: widget.onPressed,
    );
  }
}
