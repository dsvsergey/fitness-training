import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/dio_settings/dio_settings_backend.dart';
import '../../models/fitness/fitness.dart';
import 'fitness.dart';

abstract class ProgramFitnessRepository {
  Future<List<ProgramFitnessModel>> getPrograms(
    int traineeId, {
    int skip = 0,
    int limit = 100,
  });
  Future<List<ProgramFitnessModel>> getArchives(
    int traineeId, {
    int skip = 0,
    int limit = 100,
  });
  Future<ProgramFitnessModel> getProgram(int programId);
  Future<ProgramFitnessModel> createProgram(ProgramFitnessModel program);
  Future<ProgramFitnessModel> createProgramWithMachines(
      ProgramCreateModel program);
  Future<ProgramFitnessModel> updateProgram(
      int programId, ProgramFitnessModel program);
  Future<ProgramFitnessModel> setArchiveProgram(int programId, bool isArchive);
  Future<void> deleteProgram(int programId);
  Future<ProgramFitnessModel> setWorkoutDate(
      int programId, UpdateWorkoutDateModel workoutInfo);
  Future<ProgramFitnessModel> updateProgramMachines(
      ProgramUpdateMachinesModel updateMOdel);
}

@Singleton(as: ProgramFitnessRepository)
class ProgramFitnessRepositoryImpl
    with FitnessRepository
    implements ProgramFitnessRepository {
  final DioSettingsBackend fitness;

  ProgramFitnessRepositoryImpl({required this.fitness});

  @override
  Future<List<ProgramFitnessModel>> getPrograms(
    int traineeId, {
    int skip = 0,
    int limit = 100,
  }) =>
      fitness.dio
          .get(
        "/programs/trainee/$traineeId/",
        queryParameters: {
          "skip": skip,
          "limit": limit,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return (value.data as List)
            .map((item) => ProgramFitnessModel.fromJson(item))
            .toList();
      }).catchError(onException);

  @override
  Future<ProgramFitnessModel> getProgram(int programId) => fitness.dio
          .get(
        "/programs/$programId/",
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return ProgramFitnessModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<ProgramFitnessModel> createProgram(ProgramFitnessModel program) =>
      fitness.dio
          .post(
        "/programs/",
        data: program.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return ProgramFitnessModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<ProgramFitnessModel> createProgramWithMachines(
          ProgramCreateModel program) =>
      fitness.dio
          .post(
        "/programs/create-with-machines/",
        data: program.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return ProgramFitnessModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<ProgramFitnessModel> updateProgram(
          int programId, ProgramFitnessModel program) =>
      fitness.dio
          .put(
        "/programs/$programId/",
        data: program.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return ProgramFitnessModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<void> deleteProgram(int programId) => fitness.dio
      .delete(
        "/programs/$programId/",
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
      .catchError(onException);

  @override
  Future<List<ProgramFitnessModel>> getArchives(int traineeId,
          {int skip = 0, int limit = 100}) =>
      fitness.dio
          .get(
        "/programs/archive/trainee/$traineeId/",
        queryParameters: {
          "skip": skip,
          "limit": limit,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return (value.data as List)
            .map((item) => ProgramFitnessModel.fromJson(item))
            .toList();
      }).catchError(onException);

  @override
  Future<ProgramFitnessModel> setArchiveProgram(
          int programId, bool isArchive) =>
      fitness.dio
          .put(
        "/programs/$programId/archive/",
        data: {
          'is_archive': isArchive,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': GetIt.I<ApplicationBloc>().state.user?.authorization,
        }),
      )
          .then((value) {
        return ProgramFitnessModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<ProgramFitnessModel> setWorkoutDate(
          int programId, UpdateWorkoutDateModel workoutInfo) =>
      fitness.dio
          .post('/programs/$programId/workout_date/',
              options: Options(headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    GetIt.I<ApplicationBloc>().state.user?.authorization,
              }),
              data: workoutInfo.toJson())
          .then((value) {
        return ProgramFitnessModel.fromJson(value.data);
      }).catchError(onException);

  @override
  Future<ProgramFitnessModel> updateProgramMachines(
          ProgramUpdateMachinesModel updateMOdel) =>
      fitness.dio
          .put('/programs/machines/',
              options: Options(headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    GetIt.I<ApplicationBloc>().state.user?.authorization,
              }),
              data: updateMOdel.toJson())
          .then((value) {
        return ProgramFitnessModel.fromJson(value.data);
      }).catchError(onException);
}
