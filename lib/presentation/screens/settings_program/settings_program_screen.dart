// ignore_for_file: deprecated_member_use

import "package:auto_route/auto_route.dart";
import "package:collection/collection.dart";
import "package:fitness_training/core/resources/localization/l10n/app_localizations.dart";
import "package:fitness_training/presentation/widgets/workout_settings_widget.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:forui/forui.dart";
import "package:get_it/get_it.dart";
import "package:intl/intl.dart";

import "../../../core/resources/resources.dart";
import "../../../core/router/router.dart";
import "../../../domain/entities/fitness/fitness.dart";
import "../../../domain/entities/history_training_entity.dart";
import "../../../domain/usecases/fitness/fitness.dart";
import "../../../domain/usecases/fitness/workout_session_usecase.dart";
import "../../utils/dialogs_utils.dart";
import "../../widgets/button_widget.dart";
import "../../widgets/custom_timer_widget.dart";
import "../../widgets/history_widget.dart";
import "../../widgets/machine_feature_widget.dart";
import "../metronome/metronome_controls.dart";
import "bloc/settings_program_bloc.dart";

@RoutePage()
class SettingsProgramScreen extends StatefulWidget {
  final ProgramFitnessEntity program;
  final MachineEntity machine;

  const SettingsProgramScreen(
      {super.key, required this.program, required this.machine});

  @override
  State<SettingsProgramScreen> createState() => _SettingsProgramScreenState();
}

class _SettingsProgramScreenState extends State<SettingsProgramScreen> {
  dynamic currentTime = DateFormat.jm().format(DateTime.now());
  int _currentTabIndex = 0;
  final _hasChanges = ValueNotifier<bool>(false);
  final _noteController = TextEditingController();

  HistoryTrainihgEntity historyModel = HistoryTrainihgEntity(
    weight: 20,
    time: const Duration(hours: 1),
    date: DateTime.now(),
  );

  bool isGridView = true;
  double timer = 0;

  @override
  void dispose() {
    _noteController.dispose();
    _hasChanges.dispose();
    super.dispose();
  }

  void onsive(double tim) {
    setState(() {
      timer = tim;
      historyModel = HistoryTrainihgEntity(
        weight: 20,
        time: Duration(seconds: timer.toInt()),
        date: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return BlocProvider(
      create: (context) => SettingsProgramBloc()
        ..add(GetMachineSettingEvent(
            programFitness: widget.program, machine: widget.machine)),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
            buildWhen: (_, current) => current is LoadedMachineSetting,
            builder: (context, state) {
              final isEditAvailable = state.programMachine != null &&
                  (state.programMachine?.angal != null ||
                      state.programMachine?.back != null ||
                      state.programMachine?.chest != null ||
                      state.programMachine?.handle != null ||
                      state.programMachine?.knees != null ||
                      state.programMachine?.legs != null ||
                      state.programMachine?.pin != null ||
                      (state.programMachine?.seats != null &&
                          state.programMachine!.workouts.isNotEmpty));

              return AppBar(
                backgroundColor: context.theme.colors.background,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Icon(FIcons.arrowLeft, color: context.theme.colors.foreground),
                  onPressed: () => AutoRouter.of(context).pop(),
                ),
                actions: [
                  if (isEditAvailable)
                    TextButton(
                      onPressed: () => DialogUtils.showSettingsDialog(
                        context: context,
                        machine: widget.machine,
                        programMachine: state.programMachine,
                      ).then((value) {
                        if (value != null) {
                          GetIt.I<ProgramMachineUsecase>()
                              .updateProgramMachine(
                                  state.programMachine!.id!, value)
                              .whenComplete(() =>
                                  BlocProvider.of<SettingsProgramBloc>(context)
                                      .add(GetMachineSettingEvent(
                                          machine: widget.machine,
                                          programFitness: widget.program)));
                        }
                      }),
                      child: Text(
                        AppLocalizations.of(context)!.edit,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.theme.colors.primary,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        body: BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
          buildWhen: (_, current) => current is LoadedMachineSetting,
          builder: (context, state) {
            _noteController.text = state.programMachine?.note ?? '';
            _hasChanges.value = false;

            final title = Text(
              '${AppLocalizations.of(context)!.settingsFor} ${widget.machine.name}',
              textAlign: TextAlign.center,
              style: context.theme.typography.xl2
                  .copyWith(fontWeight: FontWeight.w800),
            );

            if (state.programMachine?.workouts.isEmpty ?? true) {
              return Column(
                children: [
                  SizedBox(width: double.infinity, child: title),
                  SizedBox(height: isTablet ? 100 : 20),
                  GestureDetector(
                    onTap: () => DialogUtils.showSettingsDialog(
                      context: context,
                      machine: widget.machine,
                      programMachine: state.programMachine,
                    ).then((value) {
                      if (value != null) {
                        GetIt.I<ProgramMachineUsecase>()
                            .updateProgramMachine(value.id!, value)
                            .whenComplete(() =>
                                BlocProvider.of<SettingsProgramBloc>(context)
                                    .add(GetMachineSettingEvent(
                                        programFitness: widget.program,
                                        machine: widget.machine)));
                      }
                    }),
                    child: SvgPicture.asset(
                      'assets/svgs/settings_program.svg',
                      width: isTablet ? 250 : 200,
                      height: isTablet ? 250 : 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: isTablet ? 100 : 20),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ButtonWidget(
                      onPressed: () => AutoRouter.of(context).pop(),
                      title: AppLocalizations.of(context)!.next,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  title,
                  isTablet
                      ? LayoutBuilder(
                          builder: (context, constraints) => SizedBox(
                            width: constraints.maxWidth,
                            child: machineSettingEntityPanelTablet(
                                state.programMachine!),
                          ),
                        )
                      : machineSettingEntityPanelMobile(
                          state.programMachine!),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 30 : 10),
                    child: DefaultTabController(
                      length: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            TabBar(
                              onTap: (value) =>
                                  setState(() => _currentTabIndex = value),
                              tabAlignment: TabAlignment.start,
                              labelColor:
                                  context.theme.colors.foreground,
                              unselectedLabelColor:
                                  context.theme.colors.mutedForeground,
                              indicatorColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelPadding: const EdgeInsets.all(10),
                              dividerColor: Colors.transparent,
                              isScrollable: true,
                              tabs: [
                                Tab(
                                  height: 35,
                                  child: Text(
                                    AppLocalizations.of(context)!.history,
                                    style: context.theme.typography.xl2
                                        .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _currentTabIndex == 0
                                          ? context.theme.colors.foreground
                                          : context.theme.colors
                                              .mutedForeground,
                                    ),
                                  ),
                                ),
                                Tab(
                                  height: 35,
                                  child: Text(
                                    AppLocalizations.of(context)!.note,
                                    style: context.theme.typography.xl2
                                        .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _currentTabIndex == 1
                                          ? context.theme.colors.foreground
                                          : context.theme.colors
                                              .mutedForeground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 340,
                              child: TabBarView(
                                children: [
                                  // ── History tab ──────────────────
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Table(
                                          columnWidths: const {
                                            0: FractionColumnWidth(.33),
                                            1: FractionColumnWidth(.33),
                                            2: FractionColumnWidth(.33),
                                          },
                                          children: [
                                            TableRow(
                                              children: [
                                                _headerCell(context,
                                                    AppLocalizations.of(
                                                            context)!
                                                        .date,
                                                    isTablet),
                                                _headerCell(context,
                                                    AppLocalizations.of(
                                                            context)!
                                                        .weight,
                                                    isTablet),
                                                _headerCell(context,
                                                    AppLocalizations.of(
                                                            context)!
                                                        .time,
                                                    isTablet),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: HistoryWidget(
                                              programMachine:
                                                  state.programMachine),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // ── Notes tab ────────────────────
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _noteController,
                                            maxLines: null,
                                            expands: true,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            onChanged: (_) =>
                                                _hasChanges.value = true,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: AppLocalizations.of(
                                                      context)!
                                                  .noteHint,
                                              hintStyle: const TextStyle(
                                                  color: Color(0xFFBDBDBD)),
                                            ),
                                          ),
                                        ),
                                        ValueListenableBuilder<bool>(
                                          valueListenable: _hasChanges,
                                          builder: (context, hasChanges, _) {
                                            if (!hasChanges) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: FButton(
                                                      onPress: () {
                                                        _noteController.text =
                                                            state.programMachine
                                                                    ?.note ??
                                                                '';
                                                        _hasChanges.value =
                                                            false;
                                                      },
                                                      variant: FButtonVariant
                                                          .outline,
                                                      child: const Text(
                                                          'Cancel'),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: FButton(
                                                      onPress: () {
                                                        GetIt.I<
                                                                ProgramMachineUsecase>()
                                                            .updateProgramMachine(
                                                              state
                                                                  .programMachine!
                                                                  .id!,
                                                              state
                                                                  .programMachine!
                                                                  .rebuild((p0) =>
                                                                      p0..note =
                                                                          _noteController
                                                                              .text),
                                                            )
                                                            .then((_) {
                                                          context
                                                              .read<
                                                                  SettingsProgramBloc>()
                                                              .add(GetMachineSettingEvent(
                                                                  programFitness:
                                                                      widget
                                                                          .program,
                                                                  machine: widget
                                                                      .machine));
                                                          _hasChanges.value =
                                                              false;
                                                        });
                                                      },
                                                      child: const Text('Save'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: ButtonWidget(
                                onPressed: () =>
                                    AutoRouter.of(context).pop(),
                                title: AppLocalizations.of(context)!.next,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _headerCell(BuildContext context, String text, bool isTablet) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: isTablet
              ? context.theme.typography.xl2
                  .copyWith(fontWeight: FontWeight.w500)
              : context.theme.typography.md
                  .copyWith(fontWeight: FontWeight.w500),
        ),
      );

  Widget machineSettingEntityPanelMobile(ProgramMachineEntity programMachine) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: isTablet
          ? const EdgeInsets.all(20)
          : const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 20),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.seats,
            textProgramOne: programMachine.seats?.toString() ?? '',
            textTwo: AppLocalizations.of(context)!.back,
            textProgramTwo: programMachine.back?.toString() ?? '',
          ),
          const SizedBox(height: 10),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.pin,
            textProgramOne: programMachine.pin?.toString() ?? '',
            textTwo: AppLocalizations.of(context)!.handle,
            textProgramTwo: programMachine.handle?.toString() ?? '',
          ),
          const SizedBox(height: 10),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.knees,
            textProgramOne: programMachine.handle?.toString() ?? '',
            textTwo: AppLocalizations.of(context)!.feet,
            textProgramTwo: programMachine.pin?.toString() ?? '',
          ),
          const SizedBox(height: 10),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.angle,
            textProgramOne: programMachine.handle?.toString() ?? '',
            textTwo: AppLocalizations.of(context)!.chest,
            textProgramTwo: programMachine.pin?.toString() ?? '',
          ),
          const SizedBox(height: 10),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.thighs,
            textProgramOne: programMachine.thighs ?? '',
            textTwo: AppLocalizations.of(context)!.grip,
            textProgramTwo: programMachine.grip ?? '',
          ),
          const SizedBox(height: 10),
          if (programMachine.workouts.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppSvgs.weight,
                        height: 18,
                        width: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.weightLb,
                        style: context.theme.typography.lg.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        programMachine.workouts
                                .where((w) =>
                                    w.sessionStatus ==
                                    SessionStatusEnumEntity.planned)
                                .first
                                .weight
                                ?.toString() ??
                            '',
                        style: context.theme.typography.xl2.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Flexible(
                  child: BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
                    builder: (context, state) => CustomTimerWidget(
                      title: AppLocalizations.of(context)!.timer,
                      image: AppSvgs.timer,
                      onPressed: () =>
                          onTimerButtonPressed(context, state),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: CustomTimerWidget(
                    title: AppLocalizations.of(context)!.metronome,
                    image: AppSvgs.metronom,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MetronomeControl(),
                      ),
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

  Widget machineSettingEntityPanelTablet(ProgramMachineEntity programMachine) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 15, right: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gridHeight = MediaQuery.of(context).size.height * 0.43;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              minWidth: constraints.maxWidth,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: gridHeight,
                    child: GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(8),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      crossAxisCount: 3,
                      childAspectRatio: 1.4,
                      children: [
                        if (programMachine.seats != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.seats,
                            value: programMachine.seats?.toString(),
                            icon: SvgPicture.asset(AppSvgs.seats,
                                height: 60, width: 60),
                          ),
                        if (programMachine.back != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.back,
                            value: programMachine.back?.toString(),
                            icon: Image.asset(AppPngs.body,
                                width: 60, height: 60),
                          ),
                        if (programMachine.pin != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.pin,
                            value: programMachine.pin?.toString(),
                            icon: Image.asset(AppPngs.pin,
                                width: 60, height: 60),
                          ),
                        if (programMachine.handle != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.handle,
                            value: programMachine.handle ?? '',
                            icon: Image.asset(AppPngs.handle,
                                width: 60, height: 60),
                          ),
                        if (programMachine.knees != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.knees,
                            value: programMachine.knees ?? '',
                            icon: SvgPicture.asset(
                              AppSvgs.knees,
                              height: 60,
                              width: 60,
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        if (programMachine.chest != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.chest,
                            value: programMachine.chest ?? '',
                            icon: SvgPicture.asset(
                              AppSvgs.chest,
                              height: 60,
                              width: 60,
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        if (programMachine.legs != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.feet,
                            value: programMachine.legs ?? '',
                            icon: SvgPicture.asset(
                              AppSvgs.legs,
                              height: 60,
                              width: 60,
                              color: context.theme.colors.mutedForeground,
                            ),
                            additionalText: programMachine.forTwoLegs ?? false
                                ? AppLocalizations.of(context)!.bi
                                : AppLocalizations.of(context)!.uni,
                          ),
                        if (programMachine.thighs != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.thighs,
                            value: programMachine.thighs ?? '',
                            icon: SvgPicture.asset(
                              AppSvgs.thighs,
                              height: 60,
                              width: 60,
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        if (programMachine.grip != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.grip,
                            value: programMachine.grip?.toString(),
                            icon: SvgPicture.asset(
                              AppSvgs.grip,
                              height: 60,
                              width: 60,
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        if (programMachine.angal != null)
                          MachineFeatureWidget(
                            label: AppLocalizations.of(context)!.angle,
                            value: programMachine.angal?.toString(),
                            icon: SvgPicture.asset(
                              AppSvgs.angle,
                              height: 60,
                              width: 60,
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
                        builder: (context, state) => CustomTimerWidget(
                          title: AppLocalizations.of(context)!.timer,
                          image: AppSvgs.timer,
                          onPressed: () =>
                              onTimerButtonPressed(context, state),
                        ),
                      ),
                      const SizedBox(height: 60),
                      CustomTimerWidget(
                        title: AppLocalizations.of(context)!.metronome,
                        image: AppSvgs.metronom,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MetronomeControl(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void onTimerButtonPressed(
    BuildContext context,
    SettingsProgramState state,
  ) async {
    final WorkoutSessionEntity? workoutSession = state.programMachine?.workouts
        .firstWhereOrNull((w) => w.dateSession == null);

    double? value = await context.router.push<double>(StopwatchTimerRoutes(
        trainerName: state.programMachine!.machine!.name,
        weight: workoutSession!.weight!));

    if (value != null) {
      final workoutSessionUsecase = GetIt.I<WorkoutSessionUsecase>();
      final updatedWorkoutSession =
          await workoutSessionUsecase.updateWorkoutSession(
        workoutSession.id!,
        workoutSession.rebuild((p0) => p0
          ..sessionStatus = SessionStatusEnumEntity.completed
          ..sessionTime = value.toInt()
          ..dateSession = _dateWithZeroTime(DateTime.now())),
      );

      if (mounted) {
        final nextWeight = await DialogUtils.showNextWeightDialog(
          // ignore: use_build_context_synchronously
          context: context,
          machine: widget.machine,
          weight: updatedWorkoutSession.weight!,
        );

        await workoutSessionUsecase.createWorkoutSession(
          updatedWorkoutSession.rebuild((p0) => p0
            ..id = null
            ..dateSession = null
            ..sessionTime = null
            ..sessionStatus = SessionStatusEnumEntity.planned
            ..createdAt = null
            ..weight = nextWeight ?? updatedWorkoutSession.weight!),
        );

        // ignore: use_build_context_synchronously
        context.read<SettingsProgramBloc>().add(GetMachineSettingEvent(
            machine: widget.machine, programFitness: widget.program));
      }
    }
  }

  DateTime _dateWithZeroTime(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
