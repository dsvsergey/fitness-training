import 'package:fitness_training/data/repositories/hive_repository.dart';
import 'package:fitness_training/domain/entities/program_entity.dart';

class ProgramUsecase {
  final _hive = HiveRepository();
  ProgramUsecase() {
    // HiveRepository.initHive();
  }
  Future<List<ProgramEntity>> add(List<ProgramEntity> programs) async {
    final p = List<ProgramEntity>.empty(growable: true);
    for (var program in programs) {
      final id = await _hive.addProgram(program);
      p.add(
        ProgramEntity(
          id: id,
          name: program.name,
          settings: program.settings,
        ),
      );
    }

    return p;
  }

  Future<void> delete(int id) async {
    await _hive.deleteProgram(id);
  }

  // Future<ProgramModel?> update(ProgramModel program) async {
  //   final updatedProgram = await _hive.updateProgram(program);
  //   return updatedProgram;
  // }

  // Future<ProgramModel?> read(int id) async {
  //   final program = await _hive.getProgram(id);
  //   return program;
  // }

  // Future<List<ProgramModel>> readAll() async {
  //   final programs = await _hive.getAllPrograms();
  //   return programs;
  // }
}
