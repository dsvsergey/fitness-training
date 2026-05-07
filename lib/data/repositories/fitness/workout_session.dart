import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class WorkoutSessionRepository {
  Future<List<WorkoutSessionModel>> getAllWorkoutSessions({
    int skip,
    int limit,
  });
  Future<List<WorkoutSessionModel>> getHistory(
    int traineeId,
    int machineSettingId,
  );
  Future<WorkoutSessionModel> getWorkoutSession(int sessionId);
  Future<WorkoutSessionModel> createWorkoutSession(
    WorkoutSessionModel session,
  );
  Future<WorkoutSessionModel> updateWorkoutSession(
    int sessionId,
    WorkoutSessionModel session,
  );
  Future<void> deleteWorkoutSession(int sessionId);
}

@Singleton(as: WorkoutSessionRepository)
class WorkoutSessionRepositoryImpl
    with FitnessRepository
    implements WorkoutSessionRepository {
  final DioSettingsBackend fitness;
  WorkoutSessionRepositoryImpl({required this.fitness});

  @override
  Future<List<WorkoutSessionModel>> getAllWorkoutSessions({
    int skip = 0,
    int limit = 100,
  }) =>
      fitness.dio
          .get(
            "/workout-sessions/",
            queryParameters: {"skip": skip, "limit": limit},
          )
          .then((value) => (value.data as List)
              .map((item) => WorkoutSessionModel.fromJson(item))
              .toList())
          .catchError(onException);

  @override
  Future<WorkoutSessionModel> getWorkoutSession(int sessionId) => fitness.dio
      .get("/workout-sessions/$sessionId")
      .then((value) => WorkoutSessionModel.fromJson(value.data))
      .catchError(onException);

  @override
  Future<WorkoutSessionModel> createWorkoutSession(
          WorkoutSessionModel session) =>
      fitness.dio
          .post("/workout-sessions/", data: session.toJson())
          .then((value) => WorkoutSessionModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<WorkoutSessionModel> updateWorkoutSession(
          int sessionId, WorkoutSessionModel session) =>
      fitness.dio
          .put("/workout-sessions/$sessionId", data: session.toJson())
          .then((value) => WorkoutSessionModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<void> deleteWorkoutSession(int sessionId) => fitness.dio
      .delete("/workout-sessions/$sessionId")
      .catchError(onException);

  @override
  Future<List<WorkoutSessionModel>> getHistory(
      int traineeId, int machineSettingId) {
    return fitness.dio
        .get("/workout-sessions/history/$traineeId/$machineSettingId/")
        .then((value) => (value.data as List)
            .map((item) => WorkoutSessionModel.fromJson(item))
            .toList())
        .catchError((onError) {
      if (onError is DioException) {
        if (onError.response?.statusCode == 404) {
          return Future.value(<WorkoutSessionModel>[]);
        } else {
          return onException(onError);
        }
      } else {
        return onException(onError);
      }
    });
  }
}
