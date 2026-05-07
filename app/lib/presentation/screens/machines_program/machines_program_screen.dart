import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../../../domain/entities/fitness/fitness.dart';
import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/router/router.dart';
import '../../../domain/usecases/fitness/fitness.dart';
import '../../utils/dialogs_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/button_widget.dart';
import '../calendar/bloc/calendar_bloc.dart';
import 'bloc/machines_program_screen_bloc.dart';

@RoutePage()
class MachinesProgramScreen extends StatefulWidget {
  const MachinesProgramScreen({
    super.key,
    required this.trainee,
    required this.program,
  });
  final TraineeEntity trainee;
  final ProgramFitnessEntity program;

  @override
  State<MachinesProgramScreen> createState() => _MachinesProgramScreenState();
}

class _MachinesProgramScreenState extends State<MachinesProgramScreen> {
  @override
  Widget build(BuildContext context) {
    final currentAppointment =
        GetIt.I<ApplicationBloc>().state.currentAppointment;
    context
        .read<MachinesProgramScreenBloc>()
        .add(ProgramFitnessUpdateEvent(programId: widget.program.id!));
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: context.theme.colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(FIcons.arrowLeft, color: context.theme.colors.foreground),
            onPressed: () => AutoRouter.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final state =
                    context.read<MachinesProgramScreenBloc>().state;
                if (state is ProgramFitnessUpdated) {
                  AutoRouter.of(context).push(
                    CreateProgramRoute(
                      model: widget.trainee,
                      program: state.program,
                    ),
                  );
                }
              },
              child: Text(
                AppLocalizations.of(context)!.editProgram,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.theme.colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<MachinesProgramScreenBloc, MachinesProgramScreenState>(
        buildWhen: (_, current) => current is ProgramFitnessUpdated,
        builder: (context, state) {
          if (state is! ProgramFitnessUpdated) return const SizedBox.shrink();

          final today = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );

          return Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${AppLocalizations.of(context)!.machines} — ${state.program?.name ?? ''}',
                  textAlign: TextAlign.center,
                  style: context.theme.typography.xl2
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.program!.programMachines!.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final orderedIds = state.program!.programMachines!
                        .map((pm) => pm.id!)
                        .toList();
                    final movedId = orderedIds.removeAt(oldIndex);
                    orderedIds.insert(newIndex, movedId);
                    context.read<MachinesProgramScreenBloc>().add(
                          ReorderMachinesEvent(
                            programId: widget.program.id!,
                            orderedIds: orderedIds,
                          ),
                        );
                  },
                  itemBuilder: (context, index) {
                    final pm = state.program!.programMachines![index];
                    final isCompleted = pm.workouts
                        .where((w) => w.dateSession == today)
                        .isNotEmpty;
                    return Padding(
                      key: ValueKey(pm.id),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: FTile(
                        prefix: Icon(
                          isCompleted
                              ? FIcons.circleCheck
                              : FIcons.dumbbell,
                          color: isCompleted
                              ? context.theme.colors.primary
                              : null,
                        ),
                        title: Text(
                          pm.machine!.name.capitalizeEachWord(),
                          style: context.theme.typography.md.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? context.theme.colors.primary
                                : null,
                          ),
                        ),
                        suffix: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(FIcons.gripVertical),
                        ),
                        onPress: () => AutoRouter.of(context)
                            .push(
                              SettingsProgramRoute(
                                machine: pm.machine!,
                                program: widget.program,
                              ),
                            )
                            .whenComplete(
                              () =>
                                  BlocProvider.of<MachinesProgramScreenBloc>(
                                    context,
                                  ).add(
                                    ProgramFitnessUpdateEvent(
                                      programId: widget.program.id!,
                                    ),
                                  ),
                            ),
                      ),
                    );
                  },
                ),
              ),
              if (currentAppointment != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: ButtonWidget(
                    onPressed: () => DialogUtils.showConfirmationDialog(
                      context,
                      AppLocalizations.of(context)!.finishWorkout,
                      AppLocalizations.of(context)!.finishWorkoutMessage,
                    ).then((value) {
                      if (value ?? false) {
                        final programId = state.program!.id!;
                        final now = DateTime.now();
                        final dateOnly =
                            DateTime(now.year, now.month, now.day);
                        final program = state.program!.rebuild(
                          (p0) => p0..workoutDate = dateOnly,
                        );
                        return GetIt.I<ProgramFitnessUsecase>()
                            .updateProgram(programId, program)
                            .then((_) {
                          GetIt.I<WorkoutAppointmentUsecase>()
                              .setWorkoutCompleted(currentAppointment.id!)
                              .then(
                                (_) => BlocProvider.of<CalendarBloc>(context)
                                    .add(
                                  FilterListAppointments(
                                    selectedDay: dateOnly,
                                  ),
                                ),
                              );
                          AutoRouter.of(context).popUntilRoot();
                        });
                      }
                    }),
                    title: AppLocalizations.of(context)!.finishWorkout,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
