import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/resources/resources.dart';
import '../../../core/router/router.dart';
import '../../../domain/entities/fitness/fitness.dart';
import '../../../domain/usecases/fitness/fitness.dart';
import '../../widgets/grid_calendar_widget.dart';
import '../../widgets/list_calendar_widget.dart';
import '../programs/program_screen/bloc/program_screen_bloc.dart';
import 'bloc/calendar_bloc.dart';

@RoutePage()
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _workDays = List<DateTime>.empty(growable: true);
  final _filteredAppointments = List<WorkoutAppointmentEntity>.empty(
    growable: true,
  );

  @override
  void initState() {
    super.initState();
    GetIt.I<WorkoutAppointmentUsecase>().getAllWorkoutAppointments().then((
      value,
    ) {
      _workDays
        ..clear()
        ..addAll(value.workDays?.toList() ?? []);
      _filteredAppointments
        ..clear()
        ..addAll(value.appointments?.toList() ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              // ── List / Grid of appointments ──────────────────────────────
              BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  if (state is CalendarFilteredSuccess) {
                    return isTablet
                        ? GridView.builder(
                            padding: const EdgeInsets.only(top: 80),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            shrinkWrap: true,
                            itemCount: state.appointmentsFilteredList.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isPortrait ? 3 : 4,
                                  mainAxisSpacing: 0,
                                  crossAxisSpacing: 0,
                                ),
                            itemBuilder: (context, index) => GridCalendarWidget(
                              onTap: () => _openAppointment(
                                context,
                                state.appointmentsFilteredList[index],
                                isGrid: true,
                              ),
                              appointment: state.appointmentsFilteredList[index],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 80),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: state.appointmentsFilteredList.length,
                            itemBuilder: (context, index) => ListCalendarWidget(
                              onTap: () => _openAppointment(
                                context,
                                state.appointmentsFilteredList[index],
                                isGrid: false,
                              ),
                              appointment: state.appointmentsFilteredList[index],
                            ),
                          );
                  }

                  if (state is CalendarEmptySuccess) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: Color(0xFFBDBDBD),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No appointments yet',
                            style: context.theme.typography.lg.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your schedule will appear here',
                            style: context.theme.typography.sm.copyWith(
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CalendarError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Something went wrong',
                            style: context.theme.typography.md.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: context.theme.typography.sm,
                          ),
                          const SizedBox(height: 24),
                          FButton(
                            onPress: () {},
                            variant: FButtonVariant.outline,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(child: FCircularProgress());
                },
              ),

              // ── Search / filter bar ──────────────────────────────────────
              BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  final coachName = context
                      .read<ApplicationBloc>()
                      .state
                      .user!
                      .coach
                      ?.firstName;

                  final dateStr = state.selectedDay != null
                      ? '${state.selectedDay!.day}/${state.selectedDay!.month}/${state.selectedDay!.year}'
                      : null;
                  final filterHint = [
                    if (coachName != null) coachName,
                    if (dateStr != null) dateStr,
                  ].join(' - ');

                  return FTextField(
                    hint: filterHint,
                    suffixBuilder: (context, style, variants) => IconButton(
                      icon: Icon(
                        FIcons.calendar,
                        size: isTablet ? 28 : 22,
                        color: const Color(0xFF1E1E1E),
                      ),
                      onPressed: () {
                        if (state is CalendarFilteredSuccess ||
                            state is CalendarEmptySuccess) {
                          AutoRouter.of(context)
                              .push(
                                TableCalendarRoute(
                                  currentDate: state.selectedDay!,
                                  workDays: state.workDays ?? [],
                                ),
                              )
                              .then(
                                (value) =>
                                    BlocProvider.of<CalendarBloc>(context).add(
                                      FilterListAppointments(
                                        selectedDay: value as DateTime?,
                                      ),
                                    ),
                              );
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAppointment(
    BuildContext context,
    WorkoutAppointmentEntity appointment, {
    required bool isGrid,
  }) {
    final trainee = appointment.trainee;
    context.read<ApplicationBloc>().add(
      SelectTraineeEvent(
        selectedTrainee: trainee,
        selectedAppointment: appointment,
      ),
    );
    if (isGrid) {
      BlocProvider.of<ProgramScreenBloc>(context).add(
        UpdateTraineeEvent(trainee: trainee),
      );
    } else {
      BlocProvider.of<ProgramScreenBloc>(context).add(
        SetTraineeEvent(trainee: trainee),
      );
    }
    AutoRouter.of(context).push(const ProgramRoute());
  }
}
