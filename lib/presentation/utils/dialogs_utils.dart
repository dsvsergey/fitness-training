import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/bloc/bloc_application/application_bloc.dart';
import '../../core/resources/themes/app_colors.dart';
import '../../core/resources/themes/app_fonts.dart';
import '../../domain/entities/fitness/fitness.dart';
import '../widgets/settings_for_widget.dart';
import '../widgets/settings_for_widget_slider.dart';
import 'sizedbox_utils.dart';

class DialogUtils {
  static const double contentPaddingHorizontal = 20.0;
  static const double contentPaddingVertical = 10.0;
  static const double buttonHeight = 42;
  static const double buttonWidth = 102;

  static Future<ProgramMachineEntity?> showSettingsDialog(
      {required BuildContext context,
      required MachineEntity machine,
      ProgramMachineEntity? programMachine}) {
    final controllerSeats = TextEditingController();
    final controllerBack = TextEditingController();
    final controllerHandle = TextEditingController();
    final controllerPin = TextEditingController();
    final controllerWeight = TextEditingController();
    final controllerKnees = TextEditingController();
    final controllerLegs = TextEditingController();
    final controllerAndel = TextEditingController();
    final controllerChest = TextEditingController();
    final sliderValueNotifier = ValueNotifier<int?>(0);
    final controllerThighs = TextEditingController();
    final controllerGrip = TextEditingController();

    if (programMachine != null) {
      controllerSeats.text = programMachine.seats?.toString() ?? '';
      controllerBack.text = programMachine.back?.toString() ?? '';
      controllerHandle.text = programMachine.handle?.toString() ?? '';
      controllerPin.text = programMachine.pin?.toString() ?? '';
      controllerWeight.text = programMachine.workouts.isNotEmpty
          ? programMachine.workouts.last.weight?.toString() ?? ''
          : '';
      controllerKnees.text = programMachine.knees?.toString() ?? '';
      controllerAndel.text = programMachine.angal?.toString() ?? '';
      controllerChest.text = programMachine.chest?.toString() ?? '';
      controllerLegs.text = programMachine.legs?.toString() ?? '';
      sliderValueNotifier.value = (programMachine.forTwoLegs ?? false) ? 1 : 0;
      controllerGrip.text = programMachine.grip?.toString() ?? '';
      controllerThighs.text = programMachine.thighs?.toString() ?? '';
    }

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final buttonEnabledNotifier = ValueNotifier<bool>(false);

    void checkButtonState() {
      buttonEnabledNotifier.value = (controllerSeats.text.isNotEmpty ||
              controllerBack.text.isNotEmpty ||
              controllerHandle.text.isNotEmpty ||
              controllerPin.text.isNotEmpty ||
              controllerKnees.text.isNotEmpty ||
              controllerAndel.text.isNotEmpty ||
              controllerChest.text.isNotEmpty ||
              controllerLegs.text.isNotEmpty ||
              controllerGrip.text.isNotEmpty ||
              controllerThighs.text.isNotEmpty) &&
          controllerWeight.text.isNotEmpty;
    }

    controllerSeats.addListener(checkButtonState);
    controllerBack.addListener(checkButtonState);
    controllerHandle.addListener(checkButtonState);
    controllerPin.addListener(checkButtonState);
    controllerWeight.addListener(checkButtonState);
    controllerKnees.addListener(checkButtonState);
    controllerAndel.addListener(checkButtonState);
    controllerChest.addListener(checkButtonState);
    controllerLegs.addListener(checkButtonState);
    controllerGrip.addListener(checkButtonState);
    controllerThighs.addListener(checkButtonState);

    return showDialog<ProgramMachineEntity>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentTextStyle: const TextStyle(),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: contentPaddingHorizontal,
            vertical: contentPaddingVertical,
          ),
          title: Text(
            "${AppLocalizations.of(context)!.settingsFor} ${machine.name}",
            textAlign: TextAlign.center,
            style: screenWidth > 600 ? AppFonts.w800s30 : AppFonts.w800s24,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsForWidget(
                      controller: controllerSeats,
                      text: AppLocalizations.of(context)!.seats,
                    ),
                    const SizedBox(width: 20),
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.back,
                      controller: controllerBack,
                    ),
                  ],
                ),
                10.hsb,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.pin,
                      controller: controllerPin,
                    ),
                    const SizedBox(width: 20),
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.handle,
                      controller: controllerHandle,
                    ),
                  ],
                ),
                10.hsb,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.knees,
                      controller: controllerKnees,
                    ),
                    const SizedBox(width: 20),
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.chest,
                      controller: controllerChest,
                    ),
                  ],
                ),
                10.hsb,
                SettingsForWidgetSlider(
                  text: AppLocalizations.of(context)!.feet,
                  controller: controllerLegs,
                  sliderValueNotifier: sliderValueNotifier,
                ),
                10.hsb,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.thighs,
                      controller: controllerThighs,
                    ),
                    20.wsb,
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.grip,
                      controller: controllerGrip,
                    ),
                    // const SizedBox(width: 20),
                  ],
                ),
                10.hsb,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.angle,
                      controller: controllerAndel,
                    ),
                    20.wsb,
                    SettingsForWidget(
                      text: AppLocalizations.of(context)!.weightLb,
                      controller: controllerWeight,
                    ),
                    // const SizedBox(width: 20),
                  ],
                ),
                // const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Column(
                      children: [
                        5.hsb,
                        Text(
                            AppLocalizations.of(context)!
                                .weightCurrentDescription,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: contentPaddingHorizontal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: screenWidth > 600
                          ? AppFonts.w800s24.copyWith(
                              color: AppColors.colorMain,
                            )
                          : AppFonts.w800s18,
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                      valueListenable: buttonEnabledNotifier,
                      builder: (context, isEnabled, _) {
                        return SizedBox(
                          height: buttonHeight,
                          width: buttonWidth,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.colorMain,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(39),
                              ),
                            ),
                            onPressed: isEnabled
                                ? () {
                                    final TraineeEntity? currentTrainee =
                                        GetIt.I<ApplicationBloc>()
                                            .state
                                            .currentTrainee;
                                    final CoachEntity? coach =
                                        GetIt.I<ApplicationBloc>()
                                            .state
                                            .user
                                            ?.coach;
                                    final settings = programMachine?.rebuild(
                                        (e0) => e0
                                          ..machineId = machine.id
                                          ..seats =
                                              int.tryParse(controllerSeats.text)
                                          ..back =
                                              int.tryParse(controllerBack.text)
                                          ..handle =
                                              controllerHandle.text.isEmpty
                                                  ? null
                                                  : controllerHandle.text
                                          ..pin =
                                              int.tryParse(controllerPin.text)
                                          ..forTwoLegs =
                                              sliderValueNotifier.value == 1
                                          ..knees = controllerKnees.text.isEmpty
                                              ? null
                                              : controllerKnees.text
                                          ..legs = controllerLegs.text.isEmpty
                                              ? null
                                              : controllerLegs.text
                                          ..angal = controllerAndel.text.isEmpty
                                              ? null
                                              : controllerAndel.text
                                          ..chest = controllerChest.text.isEmpty
                                              ? null
                                              : controllerChest.text
                                          ..thighs =
                                              controllerThighs.text.isEmpty
                                                  ? null
                                                  : controllerThighs.text
                                          ..grip = controllerGrip.text.isEmpty
                                              ? null
                                              : controllerGrip.text
                                          ..workouts = programMachine
                                                  .workouts.isNotEmpty
                                              ? programMachine.workouts
                                                  .rebuild((workouts) => workouts
                                                      .map((p0) => p0.dateSession ==
                                                              null
                                                          ? p0.rebuild((p0) => p0
                                                                  .weight =
                                                              int.tryParse(
                                                                  controllerWeight
                                                                      .text))
                                                          : p0))
                                                  .toBuiltList()
                                                  .toBuilder()
                                              : ListBuilder([
                                                  WorkoutSessionEntity((p0) =>
                                                      p0
                                                        ..coachId = coach?.id
                                                        ..traineeId =
                                                            currentTrainee?.id
                                                        ..programMachineId =
                                                            programMachine.id
                                                        ..sessionStatus =
                                                            SessionStatusEnumEntity
                                                                .planned
                                                        ..weight = int.tryParse(
                                                            controllerWeight
                                                                .text))
                                                ]));
                                    Navigator.of(context).pop(settings);
                                  }
                                : null,
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                              textAlign: TextAlign.center,
                              style: screenWidth > 600
                                  ? AppFonts.w700s24
                                  : AppFonts.w700s18,
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<int?> showNextWeightDialog({
    required BuildContext context,
    required int weight,
    required MachineEntity machine,
  }) {
    final controllerWeight = TextEditingController();
    controllerWeight.text = weight.toString();

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final buttonEnabledNotifier = ValueNotifier<bool>(false);

    void checkButtonState() {
      buttonEnabledNotifier.value = controllerWeight.text.isNotEmpty;
    }

    controllerWeight.addListener(checkButtonState);

    return showDialog<int?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentTextStyle: const TextStyle(),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: contentPaddingHorizontal,
            vertical: contentPaddingVertical,
          ),
          title: Text(
            "${AppLocalizations.of(context)!.settingsFor} ${machine.name}",
            textAlign: TextAlign.center,
            style: screenWidth > 600 ? AppFonts.w800s30 : AppFonts.w800s24,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              SettingsForWidget(
                text: AppLocalizations.of(context)!.weightLb,
                controller: controllerWeight,
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(AppLocalizations.of(context)!.weightNextDescription,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: contentPaddingHorizontal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: screenWidth > 600
                          ? AppFonts.w800s24.copyWith(
                              color: AppColors.colorMain,
                            )
                          : AppFonts.w800s18,
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                      valueListenable: buttonEnabledNotifier,
                      builder: (context, isEnabled, _) {
                        return SizedBox(
                          height: buttonHeight,
                          width: buttonWidth,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.colorMain,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(39),
                              ),
                            ),
                            onPressed: isEnabled
                                ? () {
                                    final weight =
                                        int.tryParse(controllerWeight.text);
                                    Navigator.of(context).pop(weight);
                                  }
                                : null,
                            child: Text(
                              AppLocalizations.of(context)!.ok,
                              textAlign: TextAlign.center,
                              style: screenWidth > 600
                                  ? AppFonts.w700s24
                                  : AppFonts.w700s18,
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  static Future<bool?> showConfirmationDialog(
      BuildContext context, String title, String question) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
          content: Text(
            question,
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.yes,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 51, 146, 57),
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.no,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 240, 49, 36),
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> showEditDialog({
    required BuildContext context,
    required String title,
    int? age,
    int? weight,
    int? height,
  }) async {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final ageController = TextEditingController();
    final weightController = TextEditingController();
    final heightController = TextEditingController();

    ageController.text = age?.toString() ?? '';
    weightController.text = weight?.toString() ?? '';
    heightController.text = height?.toString() ?? '';

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  SettingsForWidget(
                    text: AppLocalizations.of(context)!.weight,
                    controller: weightController,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SettingsForWidget(
                    text: AppLocalizations.of(context)!.height,
                    controller: heightController,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'age': ageController.text,
                      'weight': weightController.text,
                      'height': heightController.text,
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: screenWidth > 600
                        ? AppFonts.w800s24.copyWith(
                            color: AppColors.colorMain,
                          )
                        : AppFonts.w800s18,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: screenWidth > 600
                        ? AppFonts.w800s24.copyWith(
                            color: AppColors.colorMain,
                          )
                        : AppFonts.w800s18,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> showEditMachineDialog({
    required BuildContext context,
    String? name,
  }) async {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    final nameController = TextEditingController();

    nameController.text = name?.toString() ?? '';

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        final newMachineTitle = AppLocalizations.of(context)!.newMachine;
        final editMachineTitle = AppLocalizations.of(context)!.editMachine;
        return AlertDialog(
          title: Text(
            nameController.text.isEmpty ? newMachineTitle : editMachineTitle,
            style: const TextStyle(color: Colors.black54),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SettingsForWidget(
                text: AppLocalizations.of(context)!.machineName,
                controller: nameController,
              ),
            ],
          ),
          actions: [
            OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'name': nameController.text,
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: screenWidth > 600
                        ? AppFonts.w800s24.copyWith(
                            color: AppColors.colorMain,
                          )
                        : AppFonts.w800s18,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: screenWidth > 600
                        ? AppFonts.w800s24.copyWith(
                            color: AppColors.colorMain,
                          )
                        : AppFonts.w800s18,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
