import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../../../domain/usecases/fitness/workout_session_usecase.dart';
import '../../utils/dialogs_utils.dart';
import '../../widgets/fixed_width_text.dart';
import 'active_stopwatch.dart';

/// "05:07", or "1:05:07" past the hour.
String formatStopwatch(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final mmss = '${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  return d.inHours > 0 ? '${d.inHours}:$mmss' : mmss;
}

/// Shows and drives [ActiveStopwatch]. Leaving the screen does not stop it.
@RoutePage()
class StopwatchTimerScreens extends StatefulWidget {
  const StopwatchTimerScreens({super.key});

  @override
  State<StopwatchTimerScreens> createState() => _StopwatchTimerScreensState();
}

class _StopwatchTimerScreensState extends State<StopwatchTimerScreens>
    with SingleTickerProviderStateMixin {
  final _stopwatch = GetIt.I<ActiveStopwatch>();
  late final Ticker _ticker;
  bool _saving = false;

  final ValueNotifier<String> timeNotifier = ValueNotifier<String>('00:00');
  final ValueNotifier<String> millisecondsNotifier =
      ValueNotifier<String>('00');

  bool get started => _stopwatch.isRunning;

  @override
  void initState() {
    super.initState();
    _stopwatch
      ..isScreenOpen = true
      ..addListener(_onStopwatchChanged);
    _ticker = createTicker((_) => _showElapsed());
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch
      ..removeListener(_onStopwatchChanged)
      ..isScreenOpen = false
      ..release();
    timeNotifier.dispose();
    millisecondsNotifier.dispose();
    super.dispose();
  }

  void _onStopwatchChanged() {
    _syncTicker();
    setState(() {});
  }

  /// Ticks only while running, so a paused screen stays idle.
  void _syncTicker() {
    if (_stopwatch.isRunning && !_ticker.isActive) _ticker.start();
    if (!_stopwatch.isRunning && _ticker.isActive) _ticker.stop();
    _showElapsed();
  }

  void _showElapsed() {
    final elapsed = _stopwatch.elapsed;
    timeNotifier.value = formatStopwatch(elapsed);
    millisecondsNotifier.value =
        ((elapsed.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
  }

  Future<void> _saveAndEnd() async {
    final target = _stopwatch.target;
    final session = target?.workoutSession;
    if (target == null || session?.id == null || _saving) return;
    setState(() => _saving = true);
    try {
      final usecase = GetIt.I<WorkoutSessionUsecase>();
      final updated = await usecase.updateWorkoutSession(
        session!.id!,
        session.rebuild(
          (b) => b
            ..sessionStatus = SessionStatusEnumEntity.completed
            ..sessionTime = _stopwatch.elapsed.inSeconds
            ..dateSession = _dateWithZeroTime(DateTime.now()),
        ),
      );

      final nextWeight = mounted
          ? await DialogUtils.showNextWeightDialog(
              // ignore: use_build_context_synchronously
              context: context,
              machine: target.machine,
              weight: updated.weight!,
              weight2: updated.weight2,
            )
          : null;

      await usecase.createWorkoutSession(
        updated.rebuild(
          (b) => b
            ..id = null
            ..dateSession = null
            ..sessionTime = null
            ..sessionStatus = SessionStatusEnumEntity.planned
            ..createdAt = null
            ..weight = nextWeight?.$1 ?? updated.weight!
            ..weight2 =
                nextWeight != null ? nextWeight.$2 : updated.weight2,
        ),
      );

      _stopwatch.complete();
      if (mounted) await context.router.maybePop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  DateTime _dateWithZeroTime(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final target = _stopwatch.target;
    final hasTime = _stopwatch.elapsed > Duration.zero;

    return Scaffold(
      backgroundColor: context.theme.colors.background,
      appBar: AppBar(
        backgroundColor: context.theme.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: context.theme.colors.foreground,
        title: Text(
          'Stopwatch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.theme.colors.foreground,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(FIcons.arrowLeft, color: context.theme.colors.foreground),
          onPressed: () => AutoRouter.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _SessionHeaderCard(
                traineeName: target?.traineeName ?? '',
                trainerName: target?.machine.name ?? '',
                weight: target?.workoutSession.weightLabel ?? '',
              ),
              const Spacer(flex: 2),
              // ── Timer display ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: timeNotifier,
                    builder: (_, value, __) => Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        color: context.theme.colors.foreground,
                        fontSize: isTablet ? 96 : 64,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: isTablet ? 14 : 10),
                    child: ValueListenableBuilder<String>(
                      valueListenable: millisecondsNotifier,
                      builder: (_, value, __) => FixedWidthText(
                        data: '.$value',
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          color: context.theme.colors.mutedForeground,
                          fontSize: isTablet ? 32 : 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 3),
              // ── Primary control: Start / Pause ──────────────────────────
              SizedBox(
                width: double.infinity,
                child: FButton(
                  onPress: () => started ? _stopwatch.pause() : _stopwatch.start(),
                  variant: started
                      ? FButtonVariant.outline
                      : FButtonVariant.primary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      started ? 'Pause' : 'Start',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // ── Secondary controls ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      onPress: started || !hasTime || _saving
                          ? null
                          : () => DialogUtils.showConfirmationDialog(
                                context,
                                'Reset stopwatch',
                                'Do you want to reset the timer?',
                              ).then((v) {
                                if (v == true) _stopwatch.reset();
                              }),
                      variant: FButtonVariant.outline,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FButton(
                      onPress: started || !hasTime || _saving
                          ? null
                          : () => DialogUtils.showConfirmationDialog(
                                context,
                                'Save session',
                                'End the exercise with the customer?',
                              ).then((v) {
                                if (v == true) _saveAndEnd();
                              }),
                      variant: FButtonVariant.destructive,
                      child: const Text('Save & end'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionHeaderCard extends StatelessWidget {
  const _SessionHeaderCard({
    required this.traineeName,
    required this.trainerName,
    required this.weight,
  });

  final String traineeName;
  final String trainerName;
  final String weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.theme.colors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.theme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (traineeName.isNotEmpty)
            Text(
              traineeName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.theme.colors.foreground,
              ),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FIcons.user,
                  size: 16, color: context.theme.colors.mutedForeground),
              const SizedBox(width: 6),
              Text(
                trainerName,
                style: TextStyle(
                    fontSize: 16, color: context.theme.colors.mutedForeground),
              ),
              const SizedBox(width: 16),
              Icon(FIcons.dumbbell,
                  size: 16, color: context.theme.colors.mutedForeground),
              const SizedBox(width: 6),
              Text(
                '$weight lb',
                style: TextStyle(
                    fontSize: 16, color: context.theme.colors.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
