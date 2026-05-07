import 'package:built_collection/built_collection.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/fitness/fitness.dart';
import '../../../data/repositories/fitness/fitness.dart';
import '../../entities/fitness/fitness.dart';

abstract class ProgramFitnessUsecase {
  Future<List<ProgramFitnessEntity>> getPrograms(
    int traineeId, {
    int skip = 0,
    int limit = 100,
  });
  Future<List<ProgramFitnessEntity>> getArchives(
    int traineeId, {
    int skip = 0,
    int limit = 100,
  });
  Future<ProgramFitnessEntity> getProgram(int programId);
  Future<ProgramFitnessEntity> createProgram(ProgramFitnessEntity program);
  Future<ProgramFitnessEntity> createProgramWithMachines(
      CoachEntity coach, TraineeEntity trainee, List<MachineEntity> machines);
  Future<ProgramFitnessEntity> updateProgram(
      int programId, ProgramFitnessEntity program);
  Future<ProgramFitnessEntity> setArchiveProgram(int programId, bool isArchive);
  Future<void> deleteProgram(int programId);
  Future<ProgramFitnessEntity> updateProgramMachines(
      ProgramUpdateMachinesEntity updateEntity);
  Future<ProgramFitnessEntity> reorderMachines(
      int programId, List<int> orderedIds);
}

@LazySingleton(as: ProgramFitnessUsecase)
class ProgramFitnessUsecaseImpl implements ProgramFitnessUsecase {
  final ProgramFitnessRepository _api;

  ProgramFitnessUsecaseImpl({required ProgramFitnessRepository api})
      : _api = api;

  @override
  Future<ProgramFitnessEntity> createProgram(ProgramFitnessEntity program) =>
      _api.createProgram(program.model).then((value) => value.entity);

  @override
  Future<void> deleteProgram(int programId) => _api.deleteProgram(programId);

  @override
  Future<ProgramFitnessEntity> getProgram(int programId) =>
      _api.getProgram(programId).then((value) => value.entity);

  @override
  Future<List<ProgramFitnessEntity>> getPrograms(int traineeId,
          {int skip = 0, int limit = 100}) =>
      _api
          .getPrograms(traineeId, skip: skip, limit: limit)
          .then((value) => value.map((e) => e.entity).toList());

  @override
  Future<ProgramFitnessEntity> updateProgram(
          int programId, ProgramFitnessEntity program) =>
      _api
          .updateProgram(programId, program.model)
          .then((value) => value.entity);

  @override
  Future<ProgramFitnessEntity> createProgramWithMachines(CoachEntity coach,
          TraineeEntity trainee, List<MachineEntity> machines) =>
      _api
          .createProgramWithMachines(ProgramCreateModel((b) => b
            ..coachId = coach.id
            ..traineeId = trainee.id
            ..machineIds = ListBuilder(machines.map((e) => e.id).toList())))
          .then((value) => value.entity);

  @override
  Future<List<ProgramFitnessEntity>> getArchives(int traineeId,
          {int skip = 0, int limit = 100}) =>
      _api
          .getArchives(traineeId, skip: skip, limit: limit)
          .then((value) => value.map((e) => e.entity).toList());

  @override
  Future<ProgramFitnessEntity> setArchiveProgram(
          int programId, bool isArchive) =>
      _api
          .setArchiveProgram(programId, isArchive)
          .then((value) => value.entity);

  @override
  Future<ProgramFitnessEntity> updateProgramMachines(
          ProgramUpdateMachinesEntity updateEntity) =>
      _api
          .updateProgramMachines(updateEntity.model)
          .then((value) => value.entity);

  @override
  Future<ProgramFitnessEntity> reorderMachines(
          int programId, List<int> orderedIds) =>
      _api
          .reorderProgramMachines(programId, orderedIds)
          .then((value) => value.entity);
}
