import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:fitness_training/core/bloc/bloc_application/application_bloc.dart";
import "package:fitness_training/core/resources/themes/app_colors.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:get_it/get_it.dart";
import "../../../core/resources/resources.dart";
import "../../../core/utils/device_info.dart";
import "../../utils/dialogs_utils.dart";
import "../../widgets/fixed_width_text.dart";

@RoutePage<double>()
class StopwatchTimerScreens extends StatefulWidget {
  final String trainerName;
  final int weight;
  const StopwatchTimerScreens(
      {super.key, required this.trainerName, required this.weight});
  @override
  State<StopwatchTimerScreens> createState() => _StopwatchTimerScreensState();
}

class _StopwatchTimerScreensState extends State<StopwatchTimerScreens> {
  void onSaveButtonPressed() {
    timer!.cancel();
    double value = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    ).inSeconds.toDouble();
    context.router.pop<double>(value);
  }

  int seconds = 0;
  int minutes = 0;
  int hours = 0;
  int milliseconds = 0;
  String digitSeconds = "00";
  String digitMinutes = "00";
  String digitHours = "00";
  String digitMilliseconds = "00";
  Timer? timer;
  bool started = false;
  List laps = [];

  ValueNotifier<String> timeNotifier = ValueNotifier<String>("00:00");
  ValueNotifier<String> millisecondsNotifier = ValueNotifier<String>("00");

  void stop() {
    timer!.cancel();

    setState(() {
      started = false;
    });
  }

  void reset() {
    timer?.cancel();
    setState(() {
      seconds = 0;
      minutes = 0;
      hours = 0;

      digitSeconds = "00";
      digitMinutes = "00";
      digitHours = "00";
      digitMilliseconds = "00";

      started = false;
    });

    timeNotifier.value = "$digitMinutes:$digitSeconds";
    millisecondsNotifier.value = digitMilliseconds;
  }

  void addLaps() {
    final String lap = "$digitHours:$digitMinutes:$digitSeconds";

    setState(() {
      laps.add(lap);
    });
  }

  void start() {
    setState(() {
      started = true;
    });
    int localMilliseconds = 0;
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      localMilliseconds += 100;
      int localSeconds = seconds;
      int localMinutes = minutes;
      int localHours = hours;

      if (localMilliseconds >= 10000) {
        localMilliseconds = 0;
        localSeconds++;
      }

      if (localSeconds > 59) {
        if (localMinutes > 59) {
          localHours++;
          localMinutes = 0;
        } else {
          localMinutes++;
          localSeconds = 0;
        }
      }

      milliseconds = localMilliseconds;
      seconds = localSeconds;
      minutes = localMinutes;
      hours = localHours;
      digitMilliseconds = (milliseconds ~/ 100 >= 10)
          ? "${milliseconds ~/ 100}"
          : "0${milliseconds ~/ 100}";
      digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
      digitHours = (hours >= 10) ? "$hours" : "0$hours";
      digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";

      timeNotifier.value = "$digitMinutes:$digitSeconds";
      millisecondsNotifier.value = digitMilliseconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final appBloc = GetIt.I<ApplicationBloc>();
    final traineeName = appBloc.state.currentTrainee?.fullName;
    final traineeNameStr = traineeName ?? '';
    return Scaffold(
      backgroundColor: AppColors.colorMain,
      appBar: AppBar(
        backgroundColor: AppColors.colorMain,
        leadingWidth: 70,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            AppPngs.back,
            color: Colors.black,
            height: (screenWidth > 600) ? 400 : 150,
            width: (screenWidth > 600) ? 400 : 250,
          ),
          onPressed: () {
            AutoRouter.of(context).pop();
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "$traineeNameStr, \nTrainer: ${widget.trainerName}, Weight: ${widget.weight} lb",
            style: TextStyle(
              color: Colors.black,
              fontSize: (screenWidth > 600) ? 28 : 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: (screenWidth > 600) ? 40.h : 20.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: timeNotifier,
                  builder: (context, value, child) {
                    return Text(
                      value,
                      style: TextStyle(
                        fontFamily: "SpaceMono",
                        color: Colors.black,
                        //fontSize: 70,
                        fontSize: (screenWidth > 600) ? 80 : 50,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: millisecondsNotifier,
                  builder: (context, value, child) {
                    return FixedWidthText(
                      data: ".$value",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: DeviceInfo.isTablet(context) ? 80 : 50,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => started || seconds == 0
                    ? null
                    : DialogUtils.showConfirmationDialog(context, 'Confirm',
                            'Do you want to reset the timer?')
                        .then((value) {
                        if (value == true) {
                          setState(() => reset()); //reset();
                        }
                      }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 47, 46, 46),
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(
                    (screenWidth > 600) ? 54 : 30,
                  ),
                ),
                child: Text(
                  "Reset",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth > 600) ? 20 : 15,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => started || seconds == 0
                    ? null
                    : DialogUtils.showConfirmationDialog(context, 'Confirm',
                            'End the exercise with the customer?')
                        .then((value) {
                        if (value == true) {
                          onSaveButtonPressed();
                        }
                      }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(
                    (screenWidth > 600) ? 54 : 30,
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth > 600) ? 20 : 15,
                  ),
                ),
              ),
            ],
          ),

          ElevatedButton(
            onPressed: () {
              (!started) ? start() : stop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (!started)
                  ? const Color.fromARGB(255, 47, 112, 49)
                  : const Color.fromARGB(255, 119, 46, 41),
              shape: const CircleBorder(),
              padding: EdgeInsets.all(
                (screenWidth > 600) ? 54 : 30,
              ),
            ),
            child: Text(
              (!started) ? "Start" : "Pause",
              style: TextStyle(
                color: Colors.white,
                fontSize: (screenWidth > 600) ? 20 : 15,
              ),
            ),
          ),

          // const SizedBox(height: 20),
          // const SizedBox(height: 200),
          //  const SizedBox(height: 50),
        ],
      ),
    );
  }
}
