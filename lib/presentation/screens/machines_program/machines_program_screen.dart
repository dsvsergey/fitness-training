import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/resources/resources.dart';
import '../../../../core/resources/themes/app_colors.dart';
import '../../../../core/resources/themes/app_fonts.dart';
import '../../../../domain/entities/fitness/fitness.dart';
import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/router/router.dart';
import '../../../core/utils/device_info.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final currentAppointment =
        GetIt.I<ApplicationBloc>().state.currentAppointment;
    context
        .read<MachinesProgramScreenBloc>()
        .add(ProgramFitnessUpdateEvent(programId: widget.program.id!));
    return Scaffold(
      appBar: AppBar(
        leadingWidth: screenWidth > 600 ? 100 : 80,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            AppPngs.back,
          ),
          onPressed: () {
            AutoRouter.of(context).pop();
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                final state = context.read<MachinesProgramScreenBloc>().state;
                if (state is ProgramFitnessUpdated) {
                  final program = state.program;
                  AutoRouter.of(context).push(CreateProgramRoute(
                      model: widget.trainee, program: program));
                }
              },
              child: Text(
                AppLocalizations.of(context)!.editProgram,
                style: AppFonts.w800s18
                    .copyWith(fontSize: DeviceInfo.isTablet(context) ? 25 : 20),
              ))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: BlocBuilder<MachinesProgramScreenBloc,
              MachinesProgramScreenState>(
            buildWhen: (previous, current) => current is ProgramFitnessUpdated,
            builder: (context, state) {
              if (state is ProgramFitnessUpdated) {
                return Column(
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.machines} - ${state.program?.name ?? ''}",
                      textAlign: TextAlign.center,
                      style: AppFonts.w800s24,
                    ),
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 20.h,
                      runSpacing: 20.w,
                      children: state.program!.programMachines!.map((p0) {
                        return GestureDetector(
                          onTap: () => AutoRouter.of(context)
                              .push(
                                SettingsProgramRoute(
                                    machine: p0.machine!,
                                    program: widget.program),
                              )
                              .whenComplete(() =>
                                  BlocProvider.of<MachinesProgramScreenBloc>(
                                          context)
                                      .add(ProgramFitnessUpdateEvent(
                                          programId: widget.program.id!))),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Text(
                              p0.machine!.name.capitalizeEachWord(),
                              style: p0.workouts
                                      .where((p0) =>
                                          p0.dateSession ==
                                          DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day))
                                      .isEmpty
                                  ? AppFonts.w500s40
                                  : AppFonts.w500s40Completed,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: // LoadingButtonWidget(
                          ButtonWidget(
                        onPressed: currentAppointment == null
                            ? null
                            : () => DialogUtils.showConfirmationDialog(
                                        context,
                                        AppLocalizations.of(context)!
                                            .finishWorkout,
                                        AppLocalizations.of(context)!
                                            .finishWorkoutMessage)
                                    .then((value) {
                                  if (value ?? false) {
                                    final programId = state.program!.id!;
                                    final now = DateTime.now();
                                    final dateOnly =
                                        DateTime(now.year, now.month, now.day);
                                    final program = state.program?.rebuild(
                                        (p0) => p0..workoutDate = dateOnly);
                                    final appointmentId =
                                        GetIt.I<ApplicationBloc>()
                                            .state
                                            .currentAppointment
                                            ?.id;
                                    if (appointmentId != null) {
                                      return GetIt.I<ProgramFitnessUsecase>()
                                          .updateProgram(programId, program!)
                                          .then((value) {
                                        GetIt.I<WorkoutAppointmentUsecase>()
                                            .setWorkoutCompleted(appointmentId)
                                            .then((value) => BlocProvider.of<
                                                    CalendarBloc>(context)
                                                .add(FilterListAppointments(
                                                    selectedDay: dateOnly)));
                                        AutoRouter.of(context).popUntilRoot();
                                      });
                                    }
                                  }
                                }),
                        title: AppLocalizations.of(context)!.finishWorkout,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
