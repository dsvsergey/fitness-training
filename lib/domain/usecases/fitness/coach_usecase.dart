import 'package:fitness_training/data/models/fitness/fitness.dart';
import 'package:fitness_training/data/repositories/fitness/fitness.dart';
import 'package:injectable/injectable.dart';

import '../../entities/fitness/fitness.dart';

abstract class CoachUsecase {
  Future<List<CoachEntity>> getCoaches({
    String? authorization,
    int skip,
    int limit,
  });
  Future<CoachEntity> getCoach(int coachId);
  Future<CoachEntity> createCoach(CoachEntity coach);
  Future<CoachEntity> updateCoach(int coachId, CoachEntity coach);
  Future<void> deleteCoach(int coachId);
}

@LazySingleton(as: CoachUsecase)
class CoachUsecaseImpl implements CoachUsecase {
  final CoachRepository _api;

  CoachUsecaseImpl({required CoachRepository api}) : _api = api;

  @override
  Future<CoachEntity> createCoach(CoachEntity coach) =>
      _api.createCoach(coach.model).then((value) => value.entity);

  @override
  Future<void> deleteCoach(int coachId) => _api.deleteCoach(coachId);

  @override
  Future<CoachEntity> getCoach(int coachId) =>
      _api.getCoach(coachId).then((value) => value.entity);

  @override
  Future<List<CoachEntity>> getCoaches(
          {String? authorization, int skip = 0, int limit = 100}) =>
      _api
          .getCoaches(skip: skip, limit: limit, authorization: authorization)
          .then((value) => value.map((e) => e.entity).toList());

  @override
  Future<CoachEntity> updateCoach(int coachId, CoachEntity coach) =>
      _api.updateCoach(coachId, coach.model).then((value) => value.entity);
}
