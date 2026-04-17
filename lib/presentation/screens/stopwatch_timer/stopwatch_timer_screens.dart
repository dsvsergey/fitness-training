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
    final appBloc = GetIt.I<ApplicationBloc>();
    final traineeNameStr = appBloc.state.currentTrainee?.fullName ?? '';

    return Scaffold(
      backgroundColor: context.theme.colors.primary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: FHeader.nested(
          title: const SizedBox.shrink(),
          prefixes: [
            FHeaderAction.back(
              onPress: () => AutoRouter.of(context).pop(),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '$traineeNameStr,\nTrainer: ${widget.trainerName}, Weight: ${widget.weight} lb',
            style: TextStyle(
              color: Colors.black,
              fontSize: isTablet ? 28 : 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: EdgeInsets.only(left: isTablet ? 40 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: timeNotifier,
                  builder: (_, value, __) => Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      color: Colors.black,
                      fontSize: isTablet ? 80 : 50,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ValueListenableBuilder<String>(
                  valueListenable: millisecondsNotifier,
                  builder: (_, value, __) => FixedWidthText(
                    data: '.$value',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 80 : 50,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: started || seconds == 0
                    ? null
                    : () => DialogUtils.showConfirmationDialog(
                          context,
                          'Confirm',
                          'Do you want to reset the timer?',
                        ).then((v) {
                          if (v == true) reset();
                        }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F2E2E),
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(isTablet ? 54 : 30),
                ),
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 15,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: started || seconds == 0
                    ? null
                    : () => DialogUtils.showConfirmationDialog(
                          context,
                          'Confirm',
                          'End the exercise with the customer?',
                        ).then((v) {
                          if (v == true) onSaveButtonPressed();
                        }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(isTablet ? 54 : 30),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 15,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => started ? stop() : start(),
            style: ElevatedButton.styleFrom(
              backgroundColor: started
                  ? const Color(0xFF772E29)
                  : const Color(0xFF2F7031),
              shape: const CircleBorder(),
              padding: EdgeInsets.all(isTablet ? 54 : 30),
            ),
            child: Text(
              started ? 'Pause' : 'Start',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 20 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
