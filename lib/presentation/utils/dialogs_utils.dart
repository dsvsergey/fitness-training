import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../core/bloc/bloc_application/application_bloc.dart';
import '../../domain/entities/fitness/fitness.dart';
import '../widgets/settings_for_widget.dart';
import '../widgets/settings_for_widget_slider.dart';
import 'sizedbox_utils.dart';

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF1E1E1E), width: 1.5),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
        ),
      ],
    );
  }
}

class DialogUtils {
  static const double contentPaddingHorizontal = 20.0;
  static const double contentPaddingVertical = 10.0;
  static const double buttonHeight = 42;
  static const double buttonWidth = 102;

  static Future<ProgramMachineEntity?> showSettingsDialog({
    required BuildContext context,
    required MachineEntity machine,
    ProgramMachineEntity? programMachine,
  }) {
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

    final isTablet = MediaQuery.of(context).size.width > 600;
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

    for (final c in [
      controllerSeats, controllerBack, controllerHandle, controllerPin,
      controllerWeight, controllerKnees, controllerAndel, controllerChest,
      controllerLegs, controllerGrip, controllerThighs,
    ]) {
      c.addListener(checkButtonState);
    }

    return showDialog<ProgramMachineEntity>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: contentPaddingHorizontal,
          vertical: contentPaddingVertical,
        ),
        title: Text(
          '${AppLocalizations.of(context)!.settingsFor} ${machine.name}',
          textAlign: TextAlign.center,
          style: isTablet
              ? context.theme.typography.xl3
                  .copyWith(fontWeight: FontWeight.w800)
              : context.theme.typography.xl2
                  .copyWith(fontWeight: FontWeight.w800),
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
                      text: AppLocalizations.of(context)!.seats),
                  const SizedBox(width: 20),
                  SettingsForWidget(
                      text: AppLocalizations.of(context)!.back,
                      controller: controllerBack),
                ],
              ),
              10.hsb,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingsForWidget(
                      text: AppLocalizations.of(context)!.pin,
                      controller: controllerPin),
                  const SizedBox(width: 20),
                  SettingsForWidget(
                      text: AppLocalizations.of(context)!.handle,
                      controller: controllerHandle),
                ],
              ),
              10.hsb,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingsForWidget(
                      text: AppLocalizations.of(context)!.knees,
                      controller: controllerKnees),
                  const SizedBox(width: 20),
                  SettingsForWidget(
                      text: AppLocalizations.of(context)!.chest,
                      controller: controllerChest),
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
                      controller: controllerThighs),
                  20.wsb,
                  SettingsForWidget(
                      text: AppLocalizations.of(context)!.grip,
                      controller: controllerGrip),
                ],
              ),
              10.hsb,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingsForWidget(
                      text: AppLocalizations.of(context)!.angle,
                      controller: controllerAndel),
                  20.wsb,
                  SettingsForWidget(
                      text: AppLocalizations.of(context)!.weightLb,
                      controller: controllerWeight),
                ],
              ),
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
                        style: context.theme.typography.sm.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
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
                FButton(
                  onPress: () => Navigator.of(context).pop(),
                  variant: FButtonVariant.ghost,
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: buttonEnabledNotifier,
                  builder: (context, isEnabled, _) => SizedBox(
                    height: buttonHeight,
                    width: buttonWidth,
                    child: FButton(
                      onPress: isEnabled
                          ? () {
                              final currentTrainee = GetIt.I<ApplicationBloc>()
                                  .state
                                  .currentTrainee;
                              final coach = GetIt.I<ApplicationBloc>()
                                  .state
                                  .user
                                  ?.coach;
                              final settings = programMachine?.rebuild(
                                (e0) => e0
                                  ..machineId = machine.id
                                  ..seats =
                                      int.tryParse(controllerSeats.text)
                                  ..back = int.tryParse(controllerBack.text)
                                  ..handle =
                                      controllerHandle.text.isEmpty
                                          ? null
                                          : controllerHandle.text
                                  ..pin = int.tryParse(controllerPin.text)
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
                                  ..thighs = controllerThighs.text.isEmpty
                                      ? null
                                      : controllerThighs.text
                                  ..grip = controllerGrip.text.isEmpty
                                      ? null
                                      : controllerGrip.text
                                  ..workouts =
                                      programMachine.workouts.isNotEmpty
                                          ? programMachine.workouts
                                              .rebuild((wb) => wb.map((w) =>
                                                  w.dateSession == null
                                                      ? w.rebuild((p) =>
                                                          p.weight =
                                                              int.tryParse(
                                                                  controllerWeight
                                                                      .text))
                                                      : w))
                                              .toBuiltList()
                                              .toBuilder()
                                          : ListBuilder([
                                              WorkoutSessionEntity((p) => p
                                                ..coachId = coach?.id
                                                ..traineeId =
                                                    currentTrainee?.id
                                                ..programMachineId =
                                                    programMachine.id
                                                ..sessionStatus =
                                                    SessionStatusEnumEntity
                                                        .planned
                                                ..weight = int.tryParse(
                                                    controllerWeight.text))
                                            ]),
                              );
                              Navigator.of(context).pop(settings);
                            }
                          : null,
                      child: Text(AppLocalizations.of(context)!.ok),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<int?> showNextWeightDialog({
    required BuildContext context,
    required int weight,
    required MachineEntity machine,
  }) {
    final controllerWeight = TextEditingController(text: weight.toString());
    final isTablet = MediaQuery.of(context).size.width > 600;
    final buttonEnabledNotifier = ValueNotifier<bool>(true);

    controllerWeight.addListener(() {
      buttonEnabledNotifier.value = controllerWeight.text.isNotEmpty;
    });

    return showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: contentPaddingHorizontal,
          vertical: contentPaddingVertical,
        ),
        title: Text(
          '${AppLocalizations.of(context)!.settingsFor} ${machine.name}',
          textAlign: TextAlign.center,
          style: isTablet
              ? context.theme.typography.xl3
                  .copyWith(fontWeight: FontWeight.w800)
              : context.theme.typography.xl2
                  .copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            SettingsForWidget(
              text: AppLocalizations.of(context)!.weightLb,
              controller: controllerWeight,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.weightNextDescription,
              softWrap: true,
              textAlign: TextAlign.center,
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
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
                FButton(
                  onPress: () => Navigator.of(context).pop(),
                  variant: FButtonVariant.ghost,
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: buttonEnabledNotifier,
                  builder: (context, isEnabled, _) => SizedBox(
                    height: buttonHeight,
                    width: buttonWidth,
                    child: FButton(
                      onPress: isEnabled
                          ? () => Navigator.of(context)
                              .pop(int.tryParse(controllerWeight.text))
                          : null,
                      child: Text(AppLocalizations.of(context)!.ok),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String question,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style: const TextStyle(color: Colors.black54)),
        content: Text(question,
            style: const TextStyle(color: Colors.black)),
        actions: [
          OverflowBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.yes,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 51, 146, 57),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  AppLocalizations.of(context)!.no,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 240, 49, 36),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>?> showEditDialog({
    required BuildContext context,
    required String title,
    int? age,
    int? weight,
    int? height,
  }) async {
    final weightController =
        TextEditingController(text: weight?.toString() ?? '');
    final heightController =
        TextEditingController(text: height?.toString() ?? '');

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
        ),
        content: Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: AppLocalizations.of(context)!.weight,
                hint: '70',
                controller: weightController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LabeledField(
                label: AppLocalizations.of(context)!.height,
                hint: '175',
                controller: heightController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop({
                'weight': weightController.text,
                'height': heightController.text,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10)),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>?> showEditMachineDialog({
    required BuildContext context,
    String? name,
  }) async {
    final nameController = TextEditingController(text: name ?? '');

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final isEdit = name != null && name.isNotEmpty;
        final title = isEdit
            ? AppLocalizations.of(context)!.editMachine
            : AppLocalizations.of(context)!.newMachine;

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
          content: _LabeledField(
            label: AppLocalizations.of(context)!.machineName,
            hint: 'e.g. Chest Press',
            controller: nameController,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .pop({'name': nameController.text}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
