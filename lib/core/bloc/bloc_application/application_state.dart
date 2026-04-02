part of "application_bloc.dart";

abstract base class ApplicationState extends Equatable {
  UserFitnessEntity? get user;
  bool get isAuth;
  TraineeEntity? get currentTrainee;
  WorkoutAppointmentEntity? get currentAppointment;
  List<CoachEntity>? get coaches;

  @override
  List<Object> get props => [
        if (user != null) user!,
        isAuth,
        if (currentTrainee != null) currentTrainee!,
        if (coaches != null) coaches!,
        if (currentAppointment != null) currentAppointment!,
      ];
}

final class ApplicationInitial extends ApplicationState {
  @override
  UserFitnessEntity? get user => null;

  @override
  bool get isAuth => false;

  @override
  TraineeEntity? get currentTrainee => null;

  @override
  List<CoachEntity>? get coaches => null;

  @override
  WorkoutAppointmentEntity? get currentAppointment => null;
}

final class AuthLoading extends ApplicationState {
  @override
  UserFitnessEntity? get user => null;

  @override
  bool get isAuth => false;

  @override
  TraineeEntity? get currentTrainee => null;

  @override
  List<CoachEntity>? get coaches => null;

  @override
  WorkoutAppointmentEntity? get currentAppointment => null;
}

final class ApplicationError extends ApplicationState {
  ApplicationError(ApplicationState state, {required this.error})
      : user = state.user,
        isAuth = state.isAuth,
        currentTrainee = state.currentTrainee,
        coaches = state.coaches,
        currentAppointment = state.currentAppointment;
  final String error;

  @override
  final UserFitnessEntity? user;

  @override
  final bool isAuth;

  @override
  final TraineeEntity? currentTrainee;

  @override
  final List<CoachEntity>? coaches;

  @override
  final WorkoutAppointmentEntity? currentAppointment;
}

final class AuthSucces extends ApplicationState {
  AuthSucces({required this.user, required this.isAuth, required this.coaches});

  @override
  final UserFitnessEntity user;

  @override
  final bool isAuth;

  @override
  TraineeEntity? get currentTrainee => null;

  @override
  final List<CoachEntity> coaches;

  @override
  WorkoutAppointmentEntity? get currentAppointment => null;
}

final class AuthLogout extends ApplicationState {
  @override
  bool get isAuth => false;

  @override
  UserFitnessEntity? get user => null;

  @override
  TraineeEntity? get currentTrainee => null;

  @override
  List<CoachEntity>? get coaches => null;

  @override
  WorkoutAppointmentEntity? get currentAppointment => null;
}

final class SelectedCurrentTrainee extends ApplicationState {
  @override
  final TraineeEntity? currentTrainee;

  @override
  final bool isAuth;

  @override
  final UserFitnessEntity? user;

  @override
  final List<CoachEntity>? coaches;

  @override
  final WorkoutAppointmentEntity? currentAppointment;

  SelectedCurrentTrainee(ApplicationState state,
      {required this.currentTrainee, this.currentAppointment})
      : isAuth = state.isAuth,
        user = state.user,
        coaches = state.coaches;
}

final class UpdatedCoachInfo extends ApplicationState {
  @override
  final UserFitnessEntity? user;

  @override
  final bool isAuth;

  @override
  final TraineeEntity? currentTrainee;

  @override
  final List<CoachEntity>? coaches;

  @override
  final WorkoutAppointmentEntity? currentAppointment;

  UpdatedCoachInfo(ApplicationState state, {required this.user})
      : isAuth = state.isAuth,
        currentTrainee = state.currentTrainee,
        coaches = state.coaches,
        currentAppointment = state.currentAppointment;
}
