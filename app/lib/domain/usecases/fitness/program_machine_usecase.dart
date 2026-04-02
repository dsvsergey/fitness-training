import 'package:fitness_training/data/models/fitness/program_machine_model.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/fitness/fitness.dart';
import '../../entities/fitness/fitness.dart';

abstract class ProgramMachineUsecase {
  Future<List<ProgramMachineEntity>> getProgramMachines({
    int skip = 0,
    int limit = 100,
  });
  Future<ProgramMachineEntity?> getProgramMachine(int programMachineId);
  Future<ProgramMachineEntity?> getProgramMachineByProgramAndMachine(
      int programId, int machineId);
  Future<ProgramMachineEntity> createProgramMachine(
      ProgramMachineEntity programMachine);
  Future<ProgramMachineEntity> updateProgramMachine(
      int programMachineId, ProgramMachineEntity programMachine);
  Future<void> deleteProgramMachine(int programMachineId);
}

@LazySingleton(as: ProgramMachineUsecase)
class ProgramMachineUsecaseImpl implements ProgramMachineUsecase {
  final ProgramMachineRepository _api;

  ProgramMachineUsecaseImpl({required ProgramMachineRepository api})
      : _api = api;

  @override
  Future<ProgramMachineEntity> createProgramMachine(
          ProgramMachineEntity programMachine) =>
      _api
          .createProgramMachine(programMachine.model)
          .then((value) => value.entity);

  @override
  Future<void> deleteProgramMachine(int programMachineId) =>
      _api.deleteProgramMachine(programMachineId);

  @override
  Future<ProgramMachineEntity?> getProgramMachine(int programMachineId) =>
      _api.getProgramMachine(programMachineId).then((value) => value?.entity);

  @override
  Future<List<ProgramMachineEntity>> getProgramMachines(
          {int skip = 0, int limit = 100}) =>
      _api
          .getProgramMachines(skip: skip, limit: limit)
          .then((value) => value.map((e) => e.entity).toList());

  @override
  Future<ProgramMachineEntity> updateProgramMachine(
          int programMachineId, ProgramMachineEntity programMachine) =>
      _api
          .updateProgramMachine(programMachineId, programMachine.model)
          .then((value) => value.entity);

  @override
  Future<ProgramMachineEntity?> getProgramMachineByProgramAndMachine(
          int programId, int machineId) =>
      _api
          .getProgramMachineByProgramAndMachine(programId, machineId)
          .then((value) => value?.entity);
}
