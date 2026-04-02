part of 'calendar_bloc.dart';

sealed class CalendarState extends Equatable {
  DateTime? get selectedDay;
  List<DateTime>? get workDays;
  @override
  List<Object> get props => [
        if (selectedDay != null) selectedDay!,
        if (workDays != null) workDays!,
      ];
}

final class CalendarInitial extends CalendarState {
  @override
  DateTime? get selectedDay => null;

  @override
  List<DateTime>? get workDays => null;
}

final class CalendarLoading extends CalendarState {
  @override
  final DateTime? selectedDay;

  @override
  final List<DateTime>? workDays;

  CalendarLoading(CalendarState state)
      : selectedDay = state.selectedDay,
        workDays = state.workDays;
}

final class CalendarFilteredSuccess extends CalendarState {
  CalendarFilteredSuccess({
    required this.appointmentsFilteredList,
    required this.selectedDay,
    required this.workDays,
  });
  final List<WorkoutAppointmentEntity> appointmentsFilteredList;
  @override
  final List<DateTime> workDays;

  @override
  final DateTime? selectedDay;
}

final class CalendarError extends CalendarState {
  CalendarError(CalendarState state, {required this.exception})
      : selectedDay = state.selectedDay,
        workDays = state.workDays;
  final Object? exception;

  @override
  final DateTime? selectedDay;

  @override
  final List<DateTime>? workDays;
}

final class CalendarEmptySuccess extends CalendarState {
  CalendarEmptySuccess({
    required this.selectedDay,
    required this.workDays,
  });

  @override
  final DateTime? selectedDay;

  @override
  final List<DateTime> workDays;
}
