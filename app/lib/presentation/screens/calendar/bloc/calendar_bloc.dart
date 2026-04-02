import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../../domain/entities/fitness/fitness.dart';
import '../../../../domain/usecases/fitness/fitness.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  // final AppointmentUsecase appointmentUsecase;
  CalendarBloc() : super(CalendarInitial()) {
    on<FilterListAppointments>((event, emit) async {
      try {
        emit(CalendarLoading(state));
        // if (state is! CalendarSuccess) {
        //   emit(CalendarLoading(state));
        // }
        var selectedDay = DateTime(
          event.selectedDay!.year,
          event.selectedDay!.month,
          event.selectedDay!.day,
        );
        final coach = GetIt.I<ApplicationBloc>().state.user?.coach;
        final coaches = GetIt.I<ApplicationBloc>().state.coaches;
        final coachIds = coaches!
            .where((element) => element.firstName == coach?.firstName)
            .map((e) => e.id)
            .toList();

        final appointmentResult = await GetIt.I<WorkoutAppointmentUsecase>()
            .getAllWorkoutAppointments(
              filter: WorkoutAppointmentFilterEntity(
                (p) => p
                  ..startDate = selectedDay.toString()
                  ..coachIds = ListBuilder(coachIds),
              ),
            );
        // appointmentList.sort((a, b) => a.startAt.compareTo(b.startAt));

        final workDays = appointmentResult.workDays?.toList();
        final appointmentsFilteredList = appointmentResult.appointments
            ?.toList();
        appointmentsFilteredList?.sort(
          (a, b) => a.startAt.compareTo(b.startAt),
        );

        if (appointmentsFilteredList == null ||
            appointmentsFilteredList.isEmpty) {
          emit(
            CalendarEmptySuccess(
              selectedDay: event.selectedDay,
              workDays: workDays ?? [],
            ),
          );
        } else {
          emit(
            CalendarFilteredSuccess(
              workDays: workDays!,
              selectedDay: event.selectedDay,
              appointmentsFilteredList: appointmentsFilteredList,
            ),
          );
        }
      } catch (e) {
        emit(CalendarError(state, exception: e));
      }
    });
  }
}
