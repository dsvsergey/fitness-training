import 'package:hive/hive.dart';
//part 'program_model.g.dart';

@HiveType(typeId: 0)
class ProgramModel extends HiveObject {
  ProgramModel({
    required this.name,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  late int id;
}
