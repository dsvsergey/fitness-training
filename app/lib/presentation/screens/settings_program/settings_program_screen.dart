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
import "bloc/settings_program_bloc.dart";
import "widgets/program_note_card.dart";

@RoutePage()
class SettingsProgramScreen extends StatefulWidget {
  final ProgramFitnessEntity program;
  final MachineEntity machine;

  const SettingsProgramScreen({
    super.key,
    required this.program,
    required this.machine,
  });

  @override
  State<SettingsProgramScreen> createState() => _SettingsProgramScreenState();
}

class _SettingsProgramScreenState extends State<SettingsProgramScreen> {
  dynamic currentTime = DateFormat.jm().format(DateTime.now());

  HistoryTrainihgEntity historyModel = HistoryTrainihgEntity(
    weight: 20,
    time: const Duration(hours: 1),
    date: DateTime.now(),
  );

  bool isGridView = true;
  double timer = 0;

  /// The timer writes its result into an unfinished workout session, so it
  /// needs one to exist. It deliberately does not depend on a calendar
  /// appointment: a coach can start training straight from a client.
  WorkoutSessionEntity? _pendingSession(SettingsProgramState state) => state
      .programMachine
      ?.workouts
      .firstWhereOrNull((w) => w.dateSession == null);

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
        ..add(
          GetMachineSettingEvent(
            programFitness: widget.program,
            machine: widget.machine,
          ),
        ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
            buildWhen: (_, current) => current is LoadedMachineSetting,
            builder: (context, state) {
              final isEditAvailable =
                  state.programMachine != null &&
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
                  icon: Icon(
                    FIcons.arrowLeft,
                    color: context.theme.colors.foreground,
                  ),
                  onPressed: () => AutoRouter.of(context).pop(),
                ),
                actions: [
                  if (isEditAvailable)
                    TextButton(
                      onPressed: () =>
                          DialogUtils.showSettingsDialog(
                            context: context,
                            machine: widget.machine,
                            programMachine: state.programMachine,
                          ).then((value) {
                            if (value != null) {
                              GetIt.I<ProgramMachineUsecase>()
                                  .updateProgramMachine(
                                    state.programMachine!.id!,
                                    value,
                                  )
                                  .whenComplete(
                                    () =>
                                        BlocProvider.of<SettingsProgramBloc>(
                                          context,
                                        ).add(
                                          GetMachineSettingEvent(
                                            machine: widget.machine,
                                            programFitness: widget.program,
                                          ),
                                        ),
                                  );
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
            final title = Text(
              '${AppLocalizations.of(context)!.settingsFor} ${widget.machine.name}',
              textAlign: TextAlign.center,
              style: context.theme.typography.xl2.copyWith(
                fontWeight: FontWeight.w800,
              ),
            );

            if (state.programMachine?.workouts.isEmpty ?? true) {
              return Column(
                children: [
                  SizedBox(width: double.infinity, child: title),
                  SizedBox(height: isTablet ? 100 : 20),
                  GestureDetector(
                    onTap: () =>
                        DialogUtils.showSettingsDialog(
                          context: context,
                          machine: widget.machine,
                          programMachine: state.programMachine,
                        ).then((value) {
                          if (value != null) {
                            GetIt.I<ProgramMachineUsecase>()
                                .updateProgramMachine(value.id!, value)
                                .whenComplete(
                                  () =>
                                      BlocProvider.of<SettingsProgramBloc>(
                                        context,
                                      ).add(
                                        GetMachineSettingEvent(
                                          programFitness: widget.program,
                                          machine: widget.machine,
                                        ),
                                      ),
                                );
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

            final programMachine = state.programMachine!;
            final notes = ProgramNoteCard(
              savedNote: programMachine.note,
              onSave: (note) => _saveNote(context, programMachine, note),
            );
            final history = _historyCard(context, programMachine, isTablet);

            final hPad = isTablet ? 32.0 : 12.0;
            final timer =
                BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
                  builder: (context, state) => CustomTimerWidget(
                    title: AppLocalizations.of(context)!.timer,
                    image: AppSvgs.timer,
                    onPressed: _pendingSession(state) != null
                        ? () => onTimerButtonPressed(context, state)
                        : null,
                  ),
                );

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        title,
                        SizedBox(height: isTablet ? 24 : 8),
                        if (isTablet) ...[
                          _settingsCard(programMachine),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              timer,
                              const SizedBox(width: 16),
                              Expanded(child: notes),
                            ],
                          ),
                          const SizedBox(height: 16),
                          history,
                        ] else ...[
                          machineSettingEntityPanelMobile(programMachine),
                          const SizedBox(height: 16),
                          notes,
                          const SizedBox(height: 16),
                          history,
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
                  child: ButtonWidget(
                    onPressed: () => AutoRouter.of(context).pop(),
                    title: AppLocalizations.of(context)!.next,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveNote(
    BuildContext context,
    ProgramMachineEntity programMachine,
    String note,
  ) async {
    await GetIt.I<ProgramMachineUsecase>().updateProgramMachine(
      programMachine.id!,
      programMachine.rebuild((b) => b..note = note),
    );
    if (!context.mounted) return;
    context.read<SettingsProgramBloc>().add(
      GetMachineSettingEvent(
        programFitness: widget.program,
        machine: widget.machine,
      ),
    );
  }

  Widget _historyCard(
    BuildContext context,
    ProgramMachineEntity programMachine,
    bool isTablet,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.history,
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Table(
              columnWidths: const {
                0: FractionColumnWidth(.34),
                1: FractionColumnWidth(.42),
                2: FractionColumnWidth(.24),
              },
              children: [
                TableRow(
                  children: [
                    _headerCell(context, l10n.date, isTablet),
                    _headerCell(context, l10n.weight, isTablet),
                    _headerCell(context, l10n.time, isTablet),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          HistoryWidget(
            programMachine: programMachine,
            onEditWeight: (session) => _editUpcomingWeight(context, session),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(BuildContext context, String text, bool isTablet) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style:
              (isTablet
                      ? context.theme.typography.lg
                      : context.theme.typography.sm)
                  .copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.colors.mutedForeground,
                  ),
        ),
      );

  Widget machineSettingEntityPanelMobile(ProgramMachineEntity programMachine) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: isTablet ? const EdgeInsets.all(20) : const EdgeInsets.all(8),
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
            textProgramOne: programMachine.knees ?? '',
            textTwo: AppLocalizations.of(context)!.feet,
            textProgramTwo: programMachine.legs ?? '',
          ),
          const SizedBox(height: 10),
          WorkoutSettingsWidget(
            textOne: AppLocalizations.of(context)!.angle,
            textProgramOne: programMachine.angal ?? '',
            textTwo: AppLocalizations.of(context)!.chest,
            textProgramTwo: programMachine.chest ?? '',
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
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(AppSvgs.weight, height: 18, width: 20),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.weightLb,
                        style: context.theme.typography.lg.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        // The row above is guarded by `workouts.isNotEmpty`,
                        // which does not imply a *planned* session exists, so
                        // this lookup has to tolerate finding nothing.
                        programMachine.workouts
                                .firstWhereOrNull(
                                  (w) =>
                                      w.sessionStatus ==
                                      SessionStatusEnumEntity.planned,
                                )
                                ?.weightLabel ??
                            '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            child: BlocBuilder<SettingsProgramBloc, SettingsProgramState>(
              builder: (context, state) => CustomTimerWidget(
                title: AppLocalizations.of(context)!.timer,
                image: AppSvgs.timer,
                onPressed: _pendingSession(state) != null
                    ? () => onTimerButtonPressed(context, state)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(ProgramMachineEntity pm) {
    final l10n = AppLocalizations.of(context)!;
    final muted = context.theme.colors.mutedForeground;
    Widget svg(String asset, {bool tint = true}) => SvgPicture.asset(
      asset,
      height: 44,
      width: 44,
      colorFilter: tint ? ColorFilter.mode(muted, BlendMode.srcIn) : null,
    );
    Widget png(String asset) => Image.asset(asset, height: 44, width: 44);

    final items = <(String, String?, Widget)>[
      if (pm.seats != null)
        (l10n.seats, pm.seats?.toString(), svg(AppSvgs.seats, tint: false)),
      if (pm.back != null) (l10n.back, pm.back?.toString(), png(AppPngs.body)),
      if (pm.pin != null) (l10n.pin, pm.pin?.toString(), png(AppPngs.pin)),
      if (pm.handle != null) (l10n.handle, pm.handle, png(AppPngs.handle)),
      if (pm.knees != null) (l10n.knees, pm.knees, svg(AppSvgs.knees)),
      if (pm.chest != null) (l10n.chest, pm.chest, svg(AppSvgs.chest)),
      if (pm.legs != null)
        (
          '${l10n.feet} · ${(pm.forTwoLegs ?? false) ? l10n.bi : l10n.uni}',
          pm.legs,
          svg(AppSvgs.legs),
        ),
      if (pm.thighs != null) (l10n.thighs, pm.thighs, svg(AppSvgs.thighs)),
      if (pm.grip != null) (l10n.grip, pm.grip, svg(AppSvgs.grip)),
      if (pm.angal != null) (l10n.angle, pm.angal, svg(AppSvgs.angle)),
    ];

    return FCard(
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (label, value, icon) in items)
              SizedBox(
                width: 112,
                child: Column(
                  children: [
                    icon,
                    const SizedBox(height: 8),
                    Text(
                      value ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.xl2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.sm.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void onTimerButtonPressed(
    BuildContext context,
    SettingsProgramState state,
  ) async {
    final WorkoutSessionEntity? workoutSession = _pendingSession(state);
    final String? trainerName = state.programMachine?.machine?.name;
    if (workoutSession == null ||
        trainerName == null ||
        workoutSession.weight == null) {
      return;
    }

    double? value = await context.router.push<double>(
      StopwatchTimerRoutes(
        trainerName: trainerName,
        weight: workoutSession.weightLabel,
      ),
    );

    if (value != null) {
      final workoutSessionUsecase = GetIt.I<WorkoutSessionUsecase>();
      final updatedWorkoutSession = await workoutSessionUsecase
          .updateWorkoutSession(
            workoutSession.id!,
            workoutSession.rebuild(
              (p0) => p0
                ..sessionStatus = SessionStatusEnumEntity.completed
                ..sessionTime = value.toInt()
                ..dateSession = _dateWithZeroTime(DateTime.now()),
            ),
          );

      if (mounted) {
        final nextWeight = await DialogUtils.showNextWeightDialog(
          // ignore: use_build_context_synchronously
          context: context,
          machine: widget.machine,
          weight: updatedWorkoutSession.weight!,
          weight2: updatedWorkoutSession.weight2,
        );

        await workoutSessionUsecase.createWorkoutSession(
          updatedWorkoutSession.rebuild(
            (p0) => p0
              ..id = null
              ..dateSession = null
              ..sessionTime = null
              ..sessionStatus = SessionStatusEnumEntity.planned
              ..createdAt = null
              ..weight = nextWeight?.$1 ?? updatedWorkoutSession.weight!
              ..weight2 = nextWeight != null
                  ? nextWeight.$2
                  : updatedWorkoutSession.weight2,
          ),
        );

        // ignore: use_build_context_synchronously
        context.read<SettingsProgramBloc>().add(
          GetMachineSettingEvent(
            machine: widget.machine,
            programFitness: widget.program,
          ),
        );
      }
    }
  }

  /// Changes the upcoming session's weight straight from the history table.
  Future<void> _editUpcomingWeight(
    BuildContext context,
    WorkoutSessionEntity session,
  ) async {
    final bloc = context.read<SettingsProgramBloc>();
    final weights = await DialogUtils.showNextWeightDialog(
      context: context,
      machine: widget.machine,
      weight: session.weight ?? 0,
      weight2: session.weight2,
    );
    if (weights == null || session.id == null) return;

    await GetIt.I<WorkoutSessionUsecase>().updateWorkoutSession(
      session.id!,
      session.rebuild(
        (b) => b
          ..weight = weights.$1
          ..weight2 = weights.$2,
      ),
    );
    bloc.add(
      GetMachineSettingEvent(
        machine: widget.machine,
        programFitness: widget.program,
      ),
    );
  }

  DateTime _dateWithZeroTime(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
