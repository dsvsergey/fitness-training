import 'package:injectable/injectable.dart';

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
  Future<ProgramFitnessModel> reorderProgramMachines(
      int programId, List<int> orderedIds);
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
            queryParameters: {"skip": skip, "limit": limit},
          )
          .then((value) => (value.data as List)
              .map((item) => ProgramFitnessModel.fromJson(item))
              .toList())
          .catchError(onException);

  @override
  Future<ProgramFitnessModel> getProgram(int programId) => fitness.dio
      .get("/programs/$programId/")
      .then((value) => ProgramFitnessModel.fromJson(value.data))
      .catchError(onException);

  @override
  Future<ProgramFitnessModel> createProgram(ProgramFitnessModel program) =>
      fitness.dio
          .post("/programs/", data: program.toJson())
          .then((value) => ProgramFitnessModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<ProgramFitnessModel> createProgramWithMachines(
          ProgramCreateModel program) =>
      fitness.dio
          .post("/programs/create-with-machines/", data: program.toJson())
          .then((value) => ProgramFitnessModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<ProgramFitnessModel> updateProgram(
          int programId, ProgramFitnessModel program) =>
      fitness.dio
          .put("/programs/$programId/", data: program.toJson())
          .then((value) => ProgramFitnessModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<void> deleteProgram(int programId) => fitness.dio
      .delete("/programs/$programId/")
      .catchError(onException);

  @override
  Future<List<ProgramFitnessModel>> getArchives(int traineeId,
          {int skip = 0, int limit = 100}) =>
      fitness.dio
          .get(
            "/programs/archive/trainee/$traineeId/",
            queryParameters: {"skip": skip, "limit": limit},
          )
          .then((value) => (value.data as List)
              .map((item) => ProgramFitnessModel.fromJson(item))
              .toList())
          .catchError(onException);

  @override
  Future<ProgramFitnessModel> setArchiveProgram(
          int programId, bool isArchive) =>
      fitness.dio
          .put(
            "/programs/$programId/archive/",
            data: {'is_archive': isArchive},
          )
          .then((value) => ProgramFitnessModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<ProgramFitnessModel> setWorkoutDate(
          int programId, UpdateWorkoutDateModel workoutInfo) =>
      fitness.dio
          .post(
            '/programs/$programId/workout_date/',
            data: workoutInfo.toJson(),
          )
          .then((value) => ProgramFitnessModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<ProgramFitnessModel> updateProgramMachines(
          ProgramUpdateMachinesModel updateMOdel) =>
      fitness.dio
          .put('/programs/machines/', data: updateMOdel.toJson())
          .then((value) => ProgramFitnessModel.fromJson(value.data))
          .catchError(onException);

  @override
  Future<ProgramFitnessModel> reorderProgramMachines(
          int programId, List<int> orderedIds) =>
      fitness.dio
          .put(
            '/programs/$programId/machines/reorder/',
            data: {'ordered_ids': orderedIds},
          )
          .then((value) => ProgramFitnessModel.fromJson(value.data))
          .catchError(onException);
}
