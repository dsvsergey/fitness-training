import "package:auto_route/auto_route.dart";
import "package:built_collection/built_collection.dart";
import "package:fitness_training/core/resources/localization/l10n/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:forui/forui.dart";
import "package:get_it/get_it.dart";

import "../../../core/bloc/bloc_application/application_bloc.dart";
import "../../../core/router/router.dart";
import "../../../domain/entities/fitness/fitness.dart";
import "../../../domain/usecases/fitness/fitness.dart";
import "../../utils/string_utils.dart";
import "../../widgets/button_widget.dart";
import "../machines_program/bloc/machines_program_screen_bloc.dart";
import "program_screen/bloc/program_screen_bloc.dart";

@RoutePage()
class SelectTrainingScreen extends StatelessWidget {
  const SelectTrainingScreen({
    super.key,
    required this.selectedMachines,
    required this.trainee,
    this.program,
  });
  final List<MachineEntity> selectedMachines;
  final TraineeEntity trainee;
  final ProgramFitnessEntity? program;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: FHeader.nested(
          title: const SizedBox.shrink(),
          prefixes: [
            FHeaderAction.back(
              onPress: () => AutoRouter.of(context).pop(),
            ),
          ],
          suffixes: [
            FHeaderAction(
              icon: Text(
                AppLocalizations.of(context)!.archive,
                style: context.theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.theme.colors.destructive,
                ),
              ),
              onPress: () => AutoRouter.of(context).push(
                ArchieveProgramRoute(machines: selectedMachines),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Text(
                program?.name ??
                    AppLocalizations.of(context)!
                        .newProgram
                        .capitalizeEachWord(),
                textAlign: TextAlign.center,
                style: context.theme.typography.xl2
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: selectedMachines.map((machine) {
                  return GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Text(
                        machine.name,
                        style: const TextStyle(
                          fontSize: 40,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonWidget(
                  onPressed: () {
                    final coach =
                        GetIt.I<ApplicationBloc>().state.user?.coach;
                    if (coach == null) return;

                    if (program == null) {
                      if (trainee.id == null) {
                        showFToast(
                          context: context,
                          title: Text(
                              AppLocalizations.of(context)!.traineeIdIsNull),
                          variant: FToastVariant.destructive,
                        );
                        return;
                      }
                      GetIt.I<ProgramFitnessUsecase>()
                          .createProgramWithMachines(
                              coach, trainee, selectedMachines)
                          .whenComplete(
                            () => AutoRouter.of(context)
                                .popUntil((route) {
                              if (route.settings.name == 'ProgramRoute') {
                                BlocProvider.of<ProgramScreenBloc>(context)
                                    .add(UpdateTraineeEvent(
                                        trainee: trainee));
                                return true;
                              }
                              return false;
                            }),
                          );
                    } else {
                      GetIt.I<ProgramFitnessUsecase>()
                          .updateProgramMachines(
                            ProgramUpdateMachinesEntity((p0) => p0
                              ..programId = program!.id
                              ..machineIds = selectedMachines
                                  .map((e) => e.id!)
                                  .toBuiltList()
                                  .toBuilder()),
                          )
                          .whenComplete(
                            () => AutoRouter.of(context)
                                .popUntil((route) {
                              if (route.settings.name ==
                                  'MachinesProgramRoute') {
                                context
                                    .read<MachinesProgramScreenBloc>()
                                    .add(ProgramFitnessUpdateEvent(
                                        programId: program!.id!));
                                return true;
                              }
                              return false;
                            }),
                          );
                    }
                  },
                  title: AppLocalizations.of(context)!.save,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
