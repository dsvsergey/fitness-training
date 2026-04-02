import 'package:fitness_training/data/models/fitness/workout_session_model.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/fitness/fitness.dart';
import '../../entities/fitness/fitness.dart';

abstract class WorkoutSessionUsecase {
  Future<List<WorkoutSessionEntity>> getAllWorkoutSessions({
    int skip,
    int limit,
  });
  Future<List<WorkoutSessionEntity>> getHistory(
    int traineeId,
    int machineSettingId,
  );
  Future<WorkoutSessionEntity> getWorkoutSession(int sessionId);
  Future<WorkoutSessionEntity> createWorkoutSession(
    WorkoutSessionEntity session,
  );
  Future<WorkoutSessionEntity> updateWorkoutSession(
    int sessionId,
    WorkoutSessionEntity session,
  );
  Future<void> deleteWorkoutSession(int sessionId);
}

@LazySingleton(as: WorkoutSessionUsecase)
class WorkoutSessionUsecaseImpl implements WorkoutSessionUsecase {
  final WorkoutSessionRepository _api;

  WorkoutSessionUsecaseImpl({required WorkoutSessionRepository api})
      : _api = api;

  @override
  Future<WorkoutSessionEntity> createWorkoutSession(
          WorkoutSessionEntity session) =>
      _api.createWorkoutSession(session.model).then((value) => value.entity);

  @override
  Future<void> deleteWorkoutSession(int sessionId) =>
      _api.deleteWorkoutSession(sessionId);

  @override
  Future<List<WorkoutSessionEntity>> getAllWorkoutSessions(
          {int skip = 0, int limit = 100}) =>
      _api
          .getAllWorkoutSessions(skip: skip, limit: limit)
          .then((value) => value.map((e) => e.entity).toList());

  @override
  Future<WorkoutSessionEntity> getWorkoutSession(int sessionId) =>
      _api.getWorkoutSession(sessionId).then((value) => value.entity);

  @override
  Future<WorkoutSessionEntity> updateWorkoutSession(
          int sessionId, WorkoutSessionEntity session) =>
      _api
          .updateWorkoutSession(sessionId, session.model)
          .then((value) => value.entity);

  @override
  Future<List<WorkoutSessionEntity>> getHistory(
          int traineeId, int machineSettingId) =>
      _api
          .getHistory(traineeId, machineSettingId)
          .then((value) => value.map((e) => e.entity).toList());
}
