import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/router/router.dart';
import '../../../domain/entities/fitness/fitness.dart';
import '../../widgets/appointment_card_widget.dart';
import '../programs/program_screen/bloc/program_screen_bloc.dart';
import 'bloc/calendar_bloc.dart';

@RoutePage()
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    // Make sure today's appointments are loaded each time the screen mounts.
    // The bloc is provided at the app root and may have errored before login
    // completed, so we re-dispatch on mount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final today = DateTime.now();
      BlocProvider.of<CalendarBloc>(context).add(
        FilterListAppointments(
          selectedDay: DateTime(today.year, today.month, today.day),
        ),
      );
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
          child: Column(
            children: [
              // ── Day header with date picker shortcut ─────────────────────
              BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  final selected = state.selectedDay ?? DateTime.now();
                  final today = DateTime.now();
                  final isToday =
                      selected.year == today.year &&
                      selected.month == today.month &&
                      selected.day == today.day;
                  final headline = isToday
                      ? 'Today'
                      : DateFormat.EEEE().format(selected);
                  final subtitle = DateFormat.yMMMMd().format(selected);

                  final appointments = state is CalendarFilteredSuccess
                      ? state.appointmentsFilteredList
                      : const <WorkoutAppointmentEntity>[];
                  final done = appointments
                      .where((a) =>
                          a.status == AppointmentStatusEnumEntity.completed)
                      .length;
                  final summary = state is CalendarFilteredSuccess ||
                          state is CalendarEmptySuccess
                      ? '${appointments.length} '
                          '${appointments.length == 1 ? 'session' : 'sessions'}'
                          '${appointments.isEmpty ? '' : ' · $done done'}'
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headline,
                                style: context.theme.typography.xl2.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.theme.colors.foreground,
                                ),
                              ),
                              Text(
                                summary == null
                                    ? subtitle
                                    : '$subtitle  ·  $summary',
                                style: context.theme.typography.sm.copyWith(
                                  color: context.theme.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isToday)
                          TextButton(
                            onPressed: () => _selectDay(context, today),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                color: context.theme.colors.foreground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        IconButton(
                          tooltip: 'Previous day',
                          icon: const Icon(FIcons.chevronLeft),
                          onPressed: () => _selectDay(
                            context,
                            selected.subtract(const Duration(days: 1)),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Next day',
                          icon: const Icon(FIcons.chevronRight),
                          onPressed: () => _selectDay(
                            context,
                            selected.add(const Duration(days: 1)),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Pick a date',
                          icon: Icon(
                            FIcons.calendar,
                            size: isTablet ? 26 : 22,
                            color: context.theme.colors.foreground,
                          ),
                          onPressed: () {
                            AutoRouter.of(context)
                                .push(
                                  TableCalendarRoute(
                                    currentDate: selected,
                                    workDays: state.workDays ?? [],
                                  ),
                                )
                                .then((value) {
                                  if (value is DateTime && context.mounted) {
                                    _selectDay(context, value);
                                  }
                                });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ── List / Grid of appointments ──────────────────────────────
              Expanded(
                child: BlocBuilder<CalendarBloc, CalendarState>(
                  builder: (context, state) {
                    if (state is CalendarFilteredSuccess) {
                      final items = [...state.appointmentsFilteredList]
                        ..sort((a, b) => a.startAt.compareTo(b.startAt));
                      Widget card(BuildContext context, int index) =>
                          AppointmentCardWidget(
                            appointment: items[index],
                            onTap: () => _openAppointment(
                              context,
                              items[index],
                              isGrid: isTablet,
                            ),
                          );

                      return isTablet
                          ? GridView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isPortrait ? 2 : 3,
                                    mainAxisExtent: 104,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                  ),
                              itemBuilder: card,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: card,
                            );
                    }

                    if (state is CalendarEmptySuccess) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FIcons.history,
                              size: 64,
                              color: context.theme.colors.mutedForeground,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No trainings on this day',
                              style: context.theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.theme.colors.foreground,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use the arrows or calendar to pick another day',
                              style: context.theme.typography.sm.copyWith(
                                color: context.theme.colors.mutedForeground,
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
                              onPress: () => _selectDay(
                                context,
                                state.selectedDay ?? DateTime.now(),
                              ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDay(BuildContext context, DateTime day) {
    BlocProvider.of<CalendarBloc>(context).add(
      FilterListAppointments(
        selectedDay: DateTime(day.year, day.month, day.day),
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
      BlocProvider.of<ProgramScreenBloc>(
        context,
      ).add(UpdateTraineeEvent(trainee: trainee));
    } else {
      BlocProvider.of<ProgramScreenBloc>(
        context,
      ).add(SetTraineeEvent(trainee: trainee));
    }
    AutoRouter.of(context).push(const ProgramRoute());
  }
}
