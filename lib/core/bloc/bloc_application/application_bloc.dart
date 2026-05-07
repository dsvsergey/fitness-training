import "package:equatable/equatable.dart";
import "package:fitness_training/data/repositories/email_history_storage.dart";
import "package:fitness_training/data/repositories/token_storage.dart";
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
    on<RestoreSessionEvent>(_onRestoreSession);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<GoogleLoginEvent>(_onGoogleLogin);
    on<LogoutEvent>(_onLogout);
    on<SelectTraineeEvent>(
      (event, emit) => emit(SelectedCurrentTrainee(
        state,
        currentTrainee: event.selectedTrainee,
        currentAppointment: event.selectedAppointment,
      )),
    );
    on<UpdateCoachInfoEvent>(
      (event, emit) => emit(UpdatedCoachInfo(
        state,
        user: state.user
            ?.rebuild((p0) => p0..coach = event.coach.toBuilder()),
      )),
    );
  }

  Future<void> _onRestoreSession(
    RestoreSessionEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    final storage = GetIt.I<TokenStorage>();
    final token = await storage.read();
    if (token == null || token.isEmpty || TokenStorage.isExpired(token)) {
      if (token != null) await storage.clear();
      emit(AuthLogout());
      return;
    }
    try {
      emit(AuthLoading());
      final user = await GetIt.I<AuthUsecase>().loginWithToken(token);
      final coaches = await _fetchCoaches(user.authorization);
      emit(AuthSucces(user: user, isAuth: true, coaches: coaches));
    } catch (_) {
      await storage.clear();
      emit(AuthLogout());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<ApplicationState> emit) async {
    try {
      emit(AuthLoading());
      final user = await GetIt.I<AuthUsecase>()
          .login(email: event.email, password: event.password);
      await _persistToken(user.token);
      await _rememberEmail(user.coach?.email ?? event.email);
      final coaches = await _fetchCoaches(user.authorization);
      emit(AuthSucces(user: user, isAuth: true, coaches: coaches));
    } catch (e) {
      emit(ApplicationError(state, error: _errorMessage(e)));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await GetIt.I<AuthUsecase>().register(
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        password: event.password,
      );
      emit(RegisterSuccess());
    } catch (e) {
      emit(ApplicationError(state, error: _errorMessage(e)));
    }
  }

  Future<void> _onGoogleLogin(
    GoogleLoginEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await GetIt.I<AuthUsecase>().loginWithToken(event.token);
      await _persistToken(user.token);
      await _rememberEmail(user.coach?.email);
      final coaches = await _fetchCoaches(user.authorization);
      emit(AuthSucces(user: user, isAuth: true, coaches: coaches));
    } catch (e) {
      emit(ApplicationError(state, error: _errorMessage(e)));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    await GetIt.I<TokenStorage>().clear();
    emit(AuthLogout());
  }

  Future<void> _persistToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      await GetIt.I<TokenStorage>().save(token);
    }
  }

  Future<void> _rememberEmail(String? email) async {
    if (email != null && email.trim().isNotEmpty) {
      await GetIt.I<EmailHistoryStorage>().add(email);
    }
  }

  Future<List<CoachEntity>> _fetchCoaches(String? authorization) async {
    try {
      return await GetIt.I<CoachUsecase>()
          .getCoaches(authorization: authorization);
    } catch (_) {
      return [];
    }
  }

  String _errorMessage(dynamic e) {
    if (e is AuthException) return e.massage;
    if (e is ApplicationException) return e.massage;
    if (e is ConnectionException) return e.massage;
    return e.toString();
  }
}
