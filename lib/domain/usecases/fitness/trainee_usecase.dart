import 'package:fitness_training/data/models/fitness/fitness.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/fitness/fitness.dart';
import '../../entities/fitness/fitness.dart';

abstract class TraineeUsecase {
  Future<TraineeOutEntity> getTrainees({
    int skip = 0,
    int limit = 100,
    String? q,
  });
  Future<TraineeEntity> getTrainee(int traineeId);
  Future<TraineeEntity> createTrainee(TraineeEntity trainee, {String? password});
  Future<TraineeEntity> updateTrainee(int traineeId, TraineeEntity trainee);
  Future<void> deleteTrainee(int traineeId);
}

@LazySingleton(as: TraineeUsecase)
class TraineeUsecaseImpl implements TraineeUsecase {
  final TraineeRepository _api;

  TraineeUsecaseImpl({required TraineeRepository api}) : _api = api;

  @override
  Future<TraineeEntity> createTrainee(TraineeEntity trainee, {String? password}) =>
      _api.createTrainee(trainee.model, password: password).then((value) => value.entity);

  @override
  Future<void> deleteTrainee(int traineeId) => _api.deleteTrainee(traineeId);

  @override
  Future<TraineeEntity> getTrainee(int traineeId) =>
      _api.getTrainee(traineeId).then((value) => value.entity);

  @override
  Future<TraineeOutEntity> getTrainees({
    int skip = 0,
    int limit = 100,
    String? q,
  }) =>
      _api
          .getTrainees(skip: skip, limit: limit, q: q)
          .then((value) => value.entity);

  @override
  Future<TraineeEntity> updateTrainee(int traineeId, TraineeEntity trainee) =>
      _api
          .updateTrainee(traineeId, trainee.model)
          .then((value) => value.entity);
}
