import "package:auto_route/auto_route.dart";
import "package:built_collection/built_collection.dart";
import "package:fitness_training/core/resources/localization/l10n/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:get_it/get_it.dart";

import "../../../core/bloc/bloc_application/application_bloc.dart";
import "../../../core/resources/resources.dart";
import '../../../core/resources/themes/app_colors.dart';
import '../../../core/resources/themes/app_fonts.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: screenWidth > 600 ? 100 : 80,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(AppPngs.back),
          onPressed: () {
            AutoRouter.of(context).pop();
            // AutoRouter.of(context).pop(const CreateProgramRoute());
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              AutoRouter.of(
                context,
              ).push(ArchieveProgramRoute(machines: selectedMachines));
            },
            child: Text(
              AppLocalizations.of(context)!.archive,
              style: AppFonts.w700s18.copyWith(color: AppColors.rid),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Text(
                program?.name ??
                    AppLocalizations.of(
                      context,
                    )!.newProgram.capitalizeEachWord(),
                textAlign: TextAlign.center,
                style: AppFonts.w800s24,
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 20.h,
                runSpacing: 20.w,
                children: selectedMachines.map((apparat) {
                  return GestureDetector(
                    onTap: () {
                      // AutoRouter.of(context).push(
                      //   SettingsProgramRoute(
                      //     programSettings: ProgramSettingsModel(
                      //       machine: apparat,
                      //       proporties: [],
                      //       weight: 0,
                      //     ),
                      //   ),
                      // );
                    },
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Text(apparat.name, style: AppFonts.w500s40),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonWidget(
                  onPressed: () {
                    final coach = GetIt.I<ApplicationBloc>().state.user?.coach;
                    if (coach == null) return;
                    if (program == null) {
                      if (trainee.id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.traineeIdIsNull,
                            ),
                          ),
                        );
                        return;
                      }
                      GetIt.I<ProgramFitnessUsecase>()
                          .createProgramWithMachines(
                            coach,
                            trainee,
                            selectedMachines,
                          )
                          .whenComplete(
                            () => AutoRouter.of(context).popUntil((route) {
                              if (route.settings.name == 'ProgramRoute') {
                                BlocProvider.of<ProgramScreenBloc>(
                                  context,
                                ).add(UpdateTraineeEvent(trainee: trainee));
                                return true;
                              }
                              return false;
                            }),
                          );
                    } else {
                      GetIt.I<ProgramFitnessUsecase>()
                          .updateProgramMachines(
                            ProgramUpdateMachinesEntity(
                              ((p0) => p0
                                ..programId = program!.id
                                ..machineIds = selectedMachines
                                    .map((e) => e.id!)
                                    .toBuiltList()
                                    .toBuilder()),
                            ),
                          )
                          .then((value) => null)
                          .whenComplete(
                            () => AutoRouter.of(context).popUntil((route) {
                              if (route.settings.name ==
                                  'MachinesProgramRoute') {
                                context.read<MachinesProgramScreenBloc>().add(
                                  ProgramFitnessUpdateEvent(
                                    programId: program!.id!,
                                  ),
                                );
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
