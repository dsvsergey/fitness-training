import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class TraineeRepository {
  Future<TraineeOutModel> getTrainees({
    int skip = 0,
    int limit = 100,
    String? q,
  });
  Future<TraineeModel> getTrainee(int traineeId);
  Future<TraineeModel> createTrainee(TraineeModel trainee, {String? password});
  Future<TraineeModel> updateTrainee(int traineeId, TraineeModel trainee);
  Future<void> deleteTrainee(int traineeId);
}

@Singleton(as: TraineeRepository)
class TraineeRepositoryImpl
    with FitnessRepository
    implements TraineeRepository {
  final DioSettingsBackend fitness;
  TraineeRepositoryImpl({required this.fitness});

  @override
  Future<TraineeOutModel> getTrainees({
    int skip = 0,
    int limit = 100,
    String? q,
  }) async {
    try {
      final params = <String, dynamic>{'skip': skip, 'limit': limit};
      if (q != null && q.isNotEmpty) params['q'] = q;
      final value = await fitness.dio.get(
        "/trainees/",
        queryParameters: params,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      );
      return TraineeOutModel.fromJson(value.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return TraineeOutModel((b) => b
          ..totalCount = 0
          ..trainees = ListBuilder());
      }
      return onException(e);
    }
  }

  @override
  Future<TraineeModel> getTrainee(int traineeId) => fitness.dio
      .get(
        "/trainees/$traineeId",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      )
      .then((value) {
        return TraineeModel.fromJson(value.data);
      })
      .catchError(onException);

  @override
  Future<TraineeModel> createTrainee(
    TraineeModel trainee, {
    String? password,
  }) async {
    try {
      final body = Map<String, dynamic>.from(trainee.toJson())
        ..removeWhere((_, v) => v == null);
      if (password != null) body['password'] = password;
      final value = await fitness.dio.post(
        "/trainees/",
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      );
      return TraineeModel.fromJson(value.data);
    } on DioException catch (e) {
      return onException(e);
    }
  }

  @override
  Future<TraineeModel> updateTrainee(
    int traineeId,
    TraineeModel trainee,
  ) async {
    try {
      final body = Map<String, dynamic>.from(trainee.toJson())
        ..removeWhere((_, v) => v == null);
      final value = await fitness.dio.put(
        "/trainees/$traineeId",
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                GetIt.I<ApplicationBloc>().state.user?.authorization,
          },
        ),
      );
      return TraineeModel.fromJson(value.data);
    } on DioException catch (e) {
      return onException(e);
    }
  }

  @override
  Future<void> deleteTrainee(int traineeId) => fitness.dio
      .delete(
        "/trainees/$traineeId",
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
