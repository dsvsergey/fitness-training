import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  Future<TraineeModel> createTrainee(TraineeModel trainee);
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
  }) {
    return fitness.dio
        .get(
          "/trainees/",
          queryParameters: {"skip": skip, "limit": limit, 'q': q},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  GetIt.I<ApplicationBloc>().state.user?.authorization,
            },
          ),
        )
        .then((value) {
          debugPrint("TraineeRepository response: ${value.data}");
          final model = TraineeOutModel.fromJson(value.data);
          debugPrint("TraineeOutModel after conversion: $model");
          return model;
        })
        .catchError(onException);
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
  Future<TraineeModel> createTrainee(TraineeModel trainee) => fitness.dio
      .post(
        "/trainees/",
        data: trainee.toJson(),
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
  Future<TraineeModel> updateTrainee(int traineeId, TraineeModel trainee) =>
      fitness.dio
          .put(
            "/trainees/$traineeId",
            data: trainee.toJson(),
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
