import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../core/router/router.dart';
import '../screens/stopwatch_timer/active_stopwatch.dart';
import '../screens/stopwatch_timer/stopwatch_timer_screens.dart';

/// Wraps the whole app and, while a stopwatch has time on it, pins a bar
/// under every screen that leads back to it.
class ActiveStopwatchBar extends StatefulWidget {
  const ActiveStopwatchBar({
    required this.router,
    required this.child,
    super.key,
  });

  final StackRouter router;
  final Widget child;

  @override
  State<ActiveStopwatchBar> createState() => _ActiveStopwatchBarState();
}

class _ActiveStopwatchBarState extends State<ActiveStopwatchBar> {
  final _stopwatch = GetIt.I<ActiveStopwatch>();
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _stopwatch.addListener(_onChanged);
    _onChanged();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _stopwatch.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final tick = _stopwatch.isRunning && _visible;
    if (tick && _tick == null) {
      _tick = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => setState(() {}),
      );
    } else if (!tick) {
      _tick?.cancel();
      _tick = null;
    }
    if (mounted) setState(() {});
  }

  bool get _visible =>
      _stopwatch.isActive &&
      !_stopwatch.isScreenOpen &&
      !_stopwatch.isShownInline;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;
    return Column(
      children: [
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: widget.child,
          ),
        ),
        _Bar(
          stopwatch: _stopwatch,
          onTap: () => widget.router.push(const StopwatchTimerRoutes()),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.stopwatch, required this.onTap});

  final ActiveStopwatch stopwatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final target = stopwatch.target!;
    final label = [
      if (target.traineeName.isNotEmpty) target.traineeName,
      target.machine.name,
    ].join(' · ');

    return Material(
      color: colors.primary,
      child: InkWell(
        key: const ValueKey('active-stopwatch-bar'),
        onTap: onTap,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(FIcons.timer, color: colors.primaryForeground, size: 22),
                const SizedBox(width: 12),
                Text(
                  formatStopwatch(stopwatch.elapsed),
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryForeground,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: colors.primaryForeground,
                    ),
                  ),
                ),
                if (!stopwatch.isRunning)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Paused',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.primaryForeground,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  FIcons.chevronRight,
                  color: colors.primaryForeground,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
