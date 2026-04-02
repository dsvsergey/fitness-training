part of "application_bloc.dart";

abstract class ApplicationEvent extends Equatable {}

class LoginEvent extends ApplicationEvent {
  LoginEvent({
    required this.login,
    required this.password,
  });
  final String login;
  final String password;

  @override
  List<Object?> get props => [login, password];
}

class LogoutEvent extends ApplicationEvent {
  @override
  List<Object?> get props => [];
}

class SelectTraineeEvent extends ApplicationEvent {
  final TraineeEntity? selectedTrainee;
  final WorkoutAppointmentEntity? selectedAppointment;

  SelectTraineeEvent({required this.selectedTrainee, this.selectedAppointment});

  @override
  List<Object?> get props => [selectedTrainee];
}

class UpdateCoachInfoEvent extends ApplicationEvent {
  final CoachEntity coach;

  UpdateCoachInfoEvent({required this.coach});

  @override
  List<Object?> get props => [coach];
}
