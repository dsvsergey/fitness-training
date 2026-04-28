import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../utils/dialogs_utils.dart';
import '../../widgets/fixed_width_text.dart';

@RoutePage()
class StopwatchTimerScreens extends StatefulWidget {
  final String trainerName;
  final int weight;
  const StopwatchTimerScreens(
      {super.key, required this.trainerName, required this.weight});

  @override
  State<StopwatchTimerScreens> createState() => _StopwatchTimerScreensState();
}

class _StopwatchTimerScreensState extends State<StopwatchTimerScreens> {
  int seconds = 0;
  int minutes = 0;
  int hours = 0;
  int milliseconds = 0;
  String digitSeconds = '00';
  String digitMinutes = '00';
  String digitHours = '00';
  String digitMilliseconds = '00';
  Timer? timer;
  bool started = false;
  List laps = [];

  final ValueNotifier<String> timeNotifier = ValueNotifier<String>('00:00');
  final ValueNotifier<String> millisecondsNotifier =
      ValueNotifier<String>('00');

  @override
  void dispose() {
    timer?.cancel();
    timeNotifier.dispose();
    millisecondsNotifier.dispose();
    super.dispose();
  }

  void onSaveButtonPressed() {
    timer?.cancel();
    final value = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    ).inSeconds.toDouble();
    context.router.pop<double>(value);
  }

  void stop() {
    timer?.cancel();
    setState(() => started = false);
  }

  void reset() {
    timer?.cancel();
    setState(() {
      seconds = 0;
      minutes = 0;
      hours = 0;
      digitSeconds = '00';
      digitMinutes = '00';
      digitHours = '00';
      digitMilliseconds = '00';
      started = false;
    });
    timeNotifier.value = '$digitMinutes:$digitSeconds';
    millisecondsNotifier.value = digitMilliseconds;
  }

  void addLaps() {
    setState(() => laps.add('$digitHours:$digitMinutes:$digitSeconds'));
  }

  void start() {
    setState(() => started = true);
    int localMilliseconds = 0;
    timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
      localMilliseconds += 100;
      int s = seconds, m = minutes, h = hours;

      if (localMilliseconds >= 10000) {
        localMilliseconds = 0;
        s++;
      }
      if (s > 59) {
        if (m > 59) {
          h++;
          m = 0;
        } else {
          m++;
          s = 0;
        }
      }

      milliseconds = localMilliseconds;
      seconds = s;
      minutes = m;
      hours = h;
      digitMilliseconds = (milliseconds ~/ 100 >= 10)
          ? '${milliseconds ~/ 100}'
          : '0${milliseconds ~/ 100}';
      digitSeconds = s >= 10 ? '$s' : '0$s';
      digitHours = h >= 10 ? '$h' : '0$h';
      digitMinutes = m >= 10 ? '$m' : '0$m';

      timeNotifier.value = '$digitMinutes:$digitSeconds';
      millisecondsNotifier.value = digitMilliseconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final traineeNameStr =
        GetIt.I<ApplicationBloc>().state.currentTrainee?.fullName ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Stopwatch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FIcons.arrowLeft, color: Color(0xFF1E1E1E)),
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
                traineeName: traineeNameStr,
                trainerName: widget.trainerName,
                weight: widget.weight,
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
                        color: const Color(0xFF1E1E1E),
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
                          color: const Color(0xFF6E6E6E),
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
                  onPress: () => started ? stop() : start(),
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
                      onPress: started || seconds == 0
                          ? null
                          : () => DialogUtils.showConfirmationDialog(
                                context,
                                'Reset stopwatch',
                                'Do you want to reset the timer?',
                              ).then((v) {
                                if (v == true) reset();
                              }),
                      variant: FButtonVariant.outline,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FButton(
                      onPress: started || seconds == 0
                          ? null
                          : () => DialogUtils.showConfirmationDialog(
                                context,
                                'Save session',
                                'End the exercise with the customer?',
                              ).then((v) {
                                if (v == true) onSaveButtonPressed();
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
  final int weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (traineeName.isNotEmpty)
            Text(
              traineeName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(FIcons.user, size: 14, color: Color(0xFF6E6E6E)),
              const SizedBox(width: 6),
              Text(
                trainerName,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF6E6E6E)),
              ),
              const SizedBox(width: 14),
              const Icon(FIcons.dumbbell,
                  size: 14, color: Color(0xFF6E6E6E)),
              const SizedBox(width: 6),
              Text(
                '$weight lb',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF6E6E6E)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
