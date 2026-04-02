import 'package:injectable/injectable.dart';

import '../../../data/models/fitness/fitness.dart';
import '../../../data/repositories/fitness/fitness.dart';
import '../../entities/fitness/fitness.dart';

abstract class MachineUsecase {
  Future<List<MachineEntity>> getMachines({
    int skip = 0,
    int limit = 100,
  });
  Future<MachineEntity> getMachine(int machineId);
  Future<MachineEntity> createMachine(MachineEntity machine);
  Future<MachineEntity> updateMachine(int machineId, MachineEntity machine);
  Future<void> deleteMachine(int machineId);
}

@LazySingleton(as: MachineUsecase)
class MachineUsecaseImpl implements MachineUsecase {
  final MachineRepository _api;

  MachineUsecaseImpl({required MachineRepository api}) : _api = api;

  @override
  Future<MachineEntity> createMachine(MachineEntity machine) =>
      _api.createMachine(machine.model).then((value) => value.entity);

  @override
  Future<void> deleteMachine(int machineId) => _api.deleteMachine(machineId);

  @override
  Future<MachineEntity> getMachine(int machineId) =>
      _api.getMachine(machineId).then((value) => value.entity);

  @override
  Future<List<MachineEntity>> getMachines({int skip = 0, int limit = 100}) =>
      _api
          .getMachines(skip: skip, limit: limit)
          .then((value) => value.map((e) => e.entity).toList());

  @override
  Future<MachineEntity> updateMachine(int machineId, MachineEntity machine) =>
      _api
          .updateMachine(machineId, machine.model)
          .then((value) => value.entity);
}
