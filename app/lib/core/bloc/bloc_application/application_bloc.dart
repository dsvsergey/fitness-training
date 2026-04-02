import "package:equatable/equatable.dart";
import "package:fitness_training/domain/entities/fitness/coach_entity.dart";
import "package:fitness_training/domain/entities/fitness/trainee_entity.dart";
import "package:fitness_training/domain/entities/fitness/user_fitness_entity.dart";
import "package:fitness_training/domain/entities/fitness/workout_appointment_entity.dart";
import "package:fitness_training/domain/exception/application_exception.dart";
import "package:fitness_training/domain/exception/auth_exception.dart";
import "package:fitness_training/domain/exception/connection_exception.dart";
import "package:fitness_training/domain/usecases/fitness/auth_usecase.dart";
import "package:fitness_training/domain/usecases/fitness/coach_usecase.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:get_it/get_it.dart";
import "package:injectable/injectable.dart";

part "application_event.dart";
part "application_state.dart";

@singleton
class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  ApplicationBloc() : super(ApplicationInitial()) {
    on<LoginEvent>(
      (event, emit) async {
        try {
          emit(AuthLoading());
          final user = await GetIt.I<AuthUsecase>()
              .login(username: event.login, password: event.password);
          final coaches = await GetIt.I<CoachUsecase>()
              .getCoaches(authorization: user.authorization);
          emit(AuthSucces(user: user, isAuth: true, coaches: coaches));
        } catch (e) {
          if (e is AuthException) {
            emit(
              ApplicationError(
                state,
                error: e.massage,
              ),
            );
          } else if (e is ApplicationException) {
            emit(
              ApplicationError(
                state,
                error: e.massage,
              ),
            );
          } else if (e is ConnectionException) {
            emit(
              ApplicationError(
                state,
                error: e.massage,
              ),
            );
          } else {
            emit(
              ApplicationError(
                state,
                error: e.toString(),
              ),
            );
          }
        }
      },
    );

    on<LogoutEvent>((event, emit) async {
      emit(AuthLogout());
    });

    on<SelectTraineeEvent>((event, emit) => emit(SelectedCurrentTrainee(state,
        currentTrainee: event.selectedTrainee,
        currentAppointment: event.selectedAppointment)));

    on<UpdateCoachInfoEvent>((event, emit) => emit(UpdatedCoachInfo(state,
        user:
            state.user?.rebuild((p0) => p0..coach = event.coach.toBuilder()))));
  }
}
