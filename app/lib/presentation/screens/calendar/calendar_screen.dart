import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animations/loading_animations.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/resources/resources.dart';
import '../../../core/resources/themes/app_colors.dart';
import '../../../core/resources/themes/app_fonts.dart';
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
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        // _filteredAppointments.clear();
        // _filteredAppointments
        //     .addAll(_filterAppointments(_searchController.text));
      });
    });

    GetIt.I<WorkoutAppointmentUsecase>().getAllWorkoutAppointments().then((
      value,
    ) {
      _workDays.clear();
      _workDays.addAll(value.workDays?.toList() ?? []);
      _filteredAppointments.clear();
      _filteredAppointments.addAll(value.appointments?.toList() ?? []);
    });
  }

  // List<WorkoutAppointmentEntity> _filterAppointments(String query) {
  //   if (query.isEmpty) {
  //     return List.from(_workDays);
  //   } else {
  //     return _workDays.where((appointment) {
  //       final name = appointment.coach.fullName;
  //       return name.toLowerCase().contains(query.toLowerCase());
  //     }).toList();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final double width = screenWidth > 600 ? 50 : 34;
    final double height = screenWidth > 600 ? 50 : 34;
    final size = screenWidth > 600;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  if (state is CalendarFilteredSuccess) {
                    return size
                        ? GridView.builder(
                            padding: const EdgeInsets.only(top: 100),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            shrinkWrap: true,
                            itemCount: state.appointmentsFilteredList.length,
                            itemBuilder: (context, index) => GridCalendarWidget(
                              onTap: () {
                                final selectedAppointment =
                                    state.appointmentsFilteredList[index];
                                final selectedTrainee =
                                    selectedAppointment.trainee;
                                context.read<ApplicationBloc>().add(
                                  SelectTraineeEvent(
                                    selectedTrainee: selectedTrainee,
                                    selectedAppointment: selectedAppointment,
                                  ),
                                );
                                BlocProvider.of<ProgramScreenBloc>(context).add(
                                  UpdateTraineeEvent(trainee: selectedTrainee),
                                );
                                AutoRouter.of(
                                  context,
                                ).push(const ProgramRoute());
                              },
                              appointment:
                                  state.appointmentsFilteredList[index],
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isPortrait ? 3 : 4,
                                  mainAxisSpacing: 0.0,
                                  crossAxisSpacing: 0.0,
                                ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 50),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: state.appointmentsFilteredList.length,
                            //  _filteredAppointments.length,
                            itemBuilder: (context, index) => ListCalendarWidget(
                              onTap: () {
                                final selectedAppointment =
                                    state.appointmentsFilteredList[index];
                                final selectedTrainee =
                                    selectedAppointment.trainee;
                                context.read<ApplicationBloc>().add(
                                  SelectTraineeEvent(
                                    selectedTrainee: selectedTrainee,
                                    selectedAppointment: selectedAppointment,
                                  ),
                                );
                                BlocProvider.of<ProgramScreenBloc>(context).add(
                                  SetTraineeEvent(trainee: selectedTrainee),
                                );
                                AutoRouter.of(
                                  context,
                                ).push(const ProgramRoute());
                              },
                              appointment:
                                  state.appointmentsFilteredList[index],
                            ),
                          );
                  }
                  if (state is CalendarEmptySuccess) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Image.asset(AppPngs.nothing)],
                      ),
                    );
                  }
                  if (state is CalendarError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Something went wrong',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Please try againg later',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 30),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Try agaig'),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: LoadingBouncingGrid.square(
                      borderColor: AppColors.colorMain,
                      borderSize: 3.0,
                      size: 30.0,
                      backgroundColor: AppColors.colorMain,
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
              BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, state) {
                  final coachName = context
                      .read<ApplicationBloc>()
                      .state
                      .user!
                      .coach
                      ?.firstName;

                  final filterHint = state.selectedDay == null
                      ? coachName
                      : "$coachName - ${state.selectedDay?.month}/${state.selectedDay?.day}/${state.selectedDay?.year}";

                  return TextField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          AppPngs.calendar,
                          height: height,
                          width: width,
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
                                      BlocProvider.of<CalendarBloc>(
                                        context,
                                      ).add(
                                        FilterListAppointments(
                                          selectedDay: value as DateTime?,
                                        ),
                                      ),
                                );
                          }
                        },
                      ),
                      hintText: filterHint,
                      hintStyle: screenWidth > 600
                          ? AppFonts.w700s26
                          : AppFonts.w400s18,
                      fillColor: AppColors.colotSearch.withAlpha(235),
                      filled: true,
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.white),
                      ),
                    ),
                    // controller: _searchController,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
