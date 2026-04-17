part of "application_bloc.dart";

abstract class ApplicationEvent extends Equatable {}

class LoginEvent extends ApplicationEvent {
  LoginEvent({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends ApplicationEvent {
  RegisterEvent({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String password;

  @override
  List<Object?> get props => [email, firstName, lastName];
}

class GoogleLoginEvent extends ApplicationEvent {
  GoogleLoginEvent({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
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
