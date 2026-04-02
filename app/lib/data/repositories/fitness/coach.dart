import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class CoachRepository {
  Future<List<CoachModel>> getCoaches({
    int skip,
    int limit,
    String? authorization,
  });
  Future<CoachModel> getCoach(int coachId);
  Future<CoachModel> createCoach(CoachModel coach);
  Future<CoachModel> updateCoach(int coachId, CoachModel coach);
  Future<void> deleteCoach(int coachId);
}

@Singleton(as: CoachRepository)
class CoachRepositoryImpl with FitnessRepository implements CoachRepository {
  final DioSettingsBackend fitness;

  CoachRepositoryImpl({required this.fitness});

  @override
  Future<List<CoachModel>> getCoaches({
    int skip = 0,
    int limit = 100,
    String? authorization,
  }) => fitness.dio
      .get(
        "/coaches/",
        queryParameters: {"skip": skip, "limit": limit},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                authorization ??
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .then((value) {
        if (value.data is! List) {
          throw FormatException(
            'Expected List but got ${value.data.runtimeType}',
          );
        }
        return (value.data as List)
            .map((item) => CoachModel.fromJson(item as Map<String, dynamic>))
            .toList();
      })
      .catchError(onException);

  @override
  Future<CoachModel> getCoach(int coachId) => fitness.dio
      .get(
        "/coaches/$coachId",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .then((value) {
        if (value.data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected Map but got ${value.data.runtimeType}',
          );
        }
        return CoachModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<CoachModel> createCoach(CoachModel coach) => fitness.dio
      .post(
        "/coaches/",
        data: coach.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .then((value) {
        if (value.data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected Map but got ${value.data.runtimeType}',
          );
        }
        return CoachModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<CoachModel> updateCoach(int coachId, CoachModel coach) => fitness.dio
      .put(
        "/coaches/$coachId",
        data: coach.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .then((value) {
        if (value.data is! Map<String, dynamic>) {
          throw FormatException(
            'Expected Map but got ${value.data.runtimeType}',
          );
        }
        return CoachModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<void> deleteCoach(int coachId) => fitness.dio
      .delete(
        "/coaches/$coachId",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .catchError(onException);
}
