import 'package:hive/hive.dart';

import '../../domain/entities/program_entity.dart';
import '../models/program_model.dart' as hive;

class HiveRepository {
  // static initHive() async {
  //   final applicationDocumentDir =
  //       await path_provider.getApplicationDocumentsDirectory();

  //   Hive
  //     ..init(applicationDocumentDir.path)
  //     ..registerAdapter(hive.ProgramModelAdapter());

  //   Hive.openBox<hive.ProgramModel>('program');
  // }

  Future<int> addProgram(ProgramEntity program) {
    return Hive.box<hive.ProgramModel>('program')
        .add(hive.ProgramModel(name: program.name));
  }

  Future<void> deleteProgram(int id) async {
    await Hive.box<hive.ProgramModel>('program').delete(id);
  }

  Future<hive.ProgramModel?> updateProgram(hive.ProgramModel program) async {
    await Hive.box<hive.ProgramModel>('program').put(program.id, program);
    return program;
  }

  Future<hive.ProgramModel?> getProgram(int id) async {
    return Hive.box<hive.ProgramModel>('program').get(id);
  }

  Future<List<hive.ProgramModel>> getAllPrograms() async {
    return Hive.box<hive.ProgramModel>('program').values.toList();
  }
}
