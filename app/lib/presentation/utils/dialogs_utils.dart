import 'package:built_collection/built_collection.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../core/bloc/bloc_application/application_bloc.dart';
import '../../domain/entities/fitness/fitness.dart';

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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFF1E1E1E),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
        ),
      ],
    );
  }
}

class _Pair extends StatelessWidget {
  const _Pair({required this.left, required this.right});
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _FeetRow extends StatelessWidget {
  const _FeetRow({
    required this.label,
    required this.controller,
    required this.modeNotifier,
    required this.uniLabel,
    required this.biLabel,
  });

  final String label;
  final TextEditingController controller;
  final ValueNotifier<int?> modeNotifier;
  final String uniLabel;
  final String biLabel;

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
                decoration: inputDecoration,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ValueListenableBuilder<int?>(
                valueListenable: modeNotifier,
                builder: (context, value, _) =>
                    CupertinoSlidingSegmentedControl<int>(
                      groupValue: value,
                      onValueChanged: (v) => modeNotifier.value = v,
                      children: {
                        0: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            uniLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        1: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            biLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      },
                    ),
              ),
            ),
          ],
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
      buttonEnabledNotifier.value =
          (controllerSeats.text.isNotEmpty ||
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
      controllerSeats,
      controllerBack,
      controllerHandle,
      controllerPin,
      controllerWeight,
      controllerKnees,
      controllerAndel,
      controllerChest,
      controllerLegs,
      controllerGrip,
      controllerThighs,
    ]) {
      c.addListener(checkButtonState);
    }

    return showDialog<ProgramMachineEntity>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 80 : 16,
          vertical: 24,
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        title: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.settingsFor,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              machine.name,
              style: context.theme.typography.xl.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 540 : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Pair(
                  left: _LabeledField(
                    label: AppLocalizations.of(context)!.seats,
                    controller: controllerSeats,
                    keyboardType: TextInputType.number,
                  ),
                  right: _LabeledField(
                    label: AppLocalizations.of(context)!.back,
                    controller: controllerBack,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 12),
                _Pair(
                  left: _LabeledField(
                    label: AppLocalizations.of(context)!.pin,
                    controller: controllerPin,
                    keyboardType: TextInputType.number,
                  ),
                  right: _LabeledField(
                    label: AppLocalizations.of(context)!.handle,
                    controller: controllerHandle,
                  ),
                ),
                const SizedBox(height: 12),
                _Pair(
                  left: _LabeledField(
                    label: AppLocalizations.of(context)!.knees,
                    controller: controllerKnees,
                  ),
                  right: _LabeledField(
                    label: AppLocalizations.of(context)!.chest,
                    controller: controllerChest,
                  ),
                ),
                const SizedBox(height: 12),
                _FeetRow(
                  label: AppLocalizations.of(context)!.feet,
                  controller: controllerLegs,
                  modeNotifier: sliderValueNotifier,
                  uniLabel: AppLocalizations.of(context)!.uni,
                  biLabel: AppLocalizations.of(context)!.bi,
                ),
                const SizedBox(height: 12),
                _Pair(
                  left: _LabeledField(
                    label: AppLocalizations.of(context)!.thighs,
                    controller: controllerThighs,
                  ),
                  right: _LabeledField(
                    label: AppLocalizations.of(context)!.grip,
                    controller: controllerGrip,
                  ),
                ),
                const SizedBox(height: 12),
                _Pair(
                  left: _LabeledField(
                    label: AppLocalizations.of(context)!.angle,
                    controller: controllerAndel,
                  ),
                  right: _LabeledField(
                    label: AppLocalizations.of(context)!.weightLb,
                    controller: controllerWeight,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppLocalizations.of(context)!.weightCurrentDescription,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: FButton(
                  onPress: () => Navigator.of(dialogCtx).pop(),
                  variant: FButtonVariant.outline,
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: buttonEnabledNotifier,
                  builder: (context, isEnabled, _) => FButton(
                    onPress: isEnabled
                        ? () {
                            final currentTrainee =
                                GetIt.I<ApplicationBloc>().state.currentTrainee;
                            final coach =
                                GetIt.I<ApplicationBloc>().state.user?.coach;
                            final settings = programMachine?.rebuild(
                              (e0) => e0
                                ..machineId = machine.id
                                ..seats = int.tryParse(controllerSeats.text)
                                ..back = int.tryParse(controllerBack.text)
                                ..handle = controllerHandle.text.isEmpty
                                    ? null
                                    : controllerHandle.text
                                ..pin = int.tryParse(controllerPin.text)
                                ..forTwoLegs = sliderValueNotifier.value == 1
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
                                ..workouts = programMachine.workouts.isNotEmpty
                                    ? programMachine.workouts
                                          .rebuild(
                                            (wb) => wb.map(
                                              (w) => w.dateSession == null
                                                  ? w.rebuild(
                                                      (p) => p.weight =
                                                          int.tryParse(
                                                            controllerWeight
                                                                .text,
                                                          ),
                                                    )
                                                  : w,
                                            ),
                                          )
                                          .toBuiltList()
                                          .toBuilder()
                                    : ListBuilder([
                                        WorkoutSessionEntity(
                                          (p) => p
                                            ..coachId = coach?.id
                                            ..traineeId = currentTrainee?.id
                                            ..programMachineId =
                                                programMachine.id
                                            ..sessionStatus =
                                                SessionStatusEnumEntity.planned
                                            ..weight = int.tryParse(
                                              controllerWeight.text,
                                            ),
                                        ),
                                      ]),
                            );
                            Navigator.of(dialogCtx).pop(settings);
                          }
                        : null,
                    child: Text(AppLocalizations.of(context)!.ok),
                  ),
                ),
              ),
            ],
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
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 80 : 16,
          vertical: 24,
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        title: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.settingsFor,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              machine.name,
              style: context.theme.typography.xl.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledField(
              label: AppLocalizations.of(context)!.weightLb,
              controller: controllerWeight,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.weightNextDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: FButton(
                  onPress: () => Navigator.of(dialogCtx).pop(),
                  variant: FButtonVariant.outline,
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: buttonEnabledNotifier,
                  builder: (context, isEnabled, _) => FButton(
                    onPress: isEnabled
                        ? () => Navigator.of(
                            dialogCtx,
                          ).pop(int.tryParse(controllerWeight.text))
                        : null,
                    child: Text(AppLocalizations.of(context)!.ok),
                  ),
                ),
              ),
            ],
          ),
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
        title: Text(title, style: const TextStyle(color: Colors.black54)),
        content: Text(question, style: const TextStyle(color: Colors.black)),
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
    final weightController = TextEditingController(
      text: weight?.toString() ?? '',
    );
    final heightController = TextEditingController(
      text: height?.toString() ?? '',
    );

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
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
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
      ),
    );
  }

  static Future<TraineeEntity?> showEditTraineeDialog({
    required BuildContext context,
    required TraineeEntity trainee,
  }) async {
    final firstNameController = TextEditingController(
      text: trainee.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: trainee.lastName ?? '',
    );
    final phoneController = TextEditingController(
      text: trainee.mobilePhone ?? '',
    );
    final emailController = TextEditingController(text: trainee.email ?? '');
    final weightController = TextEditingController(
      text: trainee.weight != null ? trainee.weight!.toInt().toString() : '',
    );
    final heightController = TextEditingController(
      text: trainee.height != null ? trainee.height!.toInt().toString() : '',
    );
    final currentAge = trainee.birthDate != null
        ? (DateTime.now().difference(trainee.birthDate!).inDays / 365).floor()
        : null;
    final ageController = TextEditingController(
      text: currentAge?.toString() ?? '',
    );
    final notesController = TextEditingController(text: trainee.notes ?? '');

    final mediaSize = MediaQuery.of(context).size;
    final isTablet = mediaSize.width > 600;
    final dialogWidth = isTablet
        ? 640.0
        : (mediaSize.width - 24).clamp(0.0, 720.0);
    final dialogMaxHeight = mediaSize.height - 96;

    return showDialog<TraineeEntity>(
      context: context,
      builder: (dialogCtx) => FDialog(
        style: FDialogStyleDelta.delta(
          insetPadding: EdgeInsetsGeometryDelta.value(
            EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 12,
              vertical: 24,
            ),
          ),
        ),
        constraints: BoxConstraints(
          minWidth: 280,
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        title: Text(AppLocalizations.of(context)!.editProfile),
        body: SizedBox(
          width: dialogWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: firstNameController,
                  ),
                  label: const Text('First name'),
                ),
                const SizedBox(height: 12),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: lastNameController,
                  ),
                  label: const Text('Last name'),
                ),
                const SizedBox(height: 12),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: phoneController,
                  ),
                  label: const Text('Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: emailController,
                  ),
                  label: const Text('Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FTextField(
                        control: FTextFieldControl.managed(
                          controller: weightController,
                        ),
                        label: Text(AppLocalizations.of(context)!.weight),
                        hint: '70',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FTextField(
                        control: FTextFieldControl.managed(
                          controller: heightController,
                        ),
                        label: Text(AppLocalizations.of(context)!.height),
                        hint: '175',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FTextField(
                        control: FTextFieldControl.managed(
                          controller: ageController,
                        ),
                        label: const Text('Age'),
                        hint: '30',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FTextField.multiline(
                  control: FTextFieldControl.managed(
                    controller: notesController,
                  ),
                  label: const Text('Notes'),
                  minLines: 3,
                  maxLines: 6,
                ),
              ],
            ),
          ),
        ),
        actions: [
          FButton(
            onPress: () {
              final enteredAge = int.tryParse(ageController.text.trim());
              DateTime? birthDate = trainee.birthDate;
              if (enteredAge != currentAge) {
                birthDate = enteredAge == null
                    ? null
                    : DateTime(DateTime.now().year - enteredAge, 1, 1);
              }
              final updated = trainee.rebuild(
                (b) => b
                  ..firstName = firstNameController.text.trim().isEmpty
                      ? null
                      : firstNameController.text.trim()
                  ..lastName = lastNameController.text.trim().isEmpty
                      ? null
                      : lastNameController.text.trim()
                  ..mobilePhone = phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim()
                  ..email = emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim()
                  ..weight = double.tryParse(weightController.text.trim())
                  ..height = double.tryParse(heightController.text.trim())
                  ..birthDate = birthDate
                  ..notes = notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
              );
              Navigator.of(dialogCtx).pop(updated);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
          FButton(
            onPress: () => Navigator.of(dialogCtx).pop(),
            variant: FButtonVariant.outline,
            child: Text(AppLocalizations.of(context)!.cancel),
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
            borderRadius: BorderRadius.circular(16),
          ),
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
                onPressed: () =>
                    Navigator.of(context).pop({'name': nameController.text}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
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
