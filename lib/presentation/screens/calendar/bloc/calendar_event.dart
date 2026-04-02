part of 'calendar_bloc.dart';

sealed class CalendarEvent extends Equatable {}

class FilterListAppointments extends CalendarEvent {
  final DateTime? selectedDay;

  FilterListAppointments({required this.selectedDay});

  @override
  List<Object?> get props => [selectedDay];
}
