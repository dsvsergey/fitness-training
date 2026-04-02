import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';
import 'fitness.dart';

part 'program_fitness_entity.g.dart';

abstract class ProgramFitnessEntity
    implements Built<ProgramFitnessEntity, ProgramFitnessEntityBuilder> {
  static Serializer<ProgramFitnessEntity> get serializer =>
      _$programFitnessEntitySerializer;
  int? get id;
  String? get name;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  int? get coachId;
  int? get traineeId;
  int? get number;
  CoachEntity? get coach;
  BuiltList<ProgramMachineEntity>? get programMachines;
  bool? get isArchive;
  bool? get isDelete;
  DateTime? get workoutDate;

  ProgramFitnessEntity._();

  factory ProgramFitnessEntity([
    void Function(ProgramFitnessEntityBuilder) updates,
  ]) = _$ProgramFitnessEntity;

  static ProgramFitnessEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
      ProgramFitnessEntity.serializer,
      json,
    )!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(
          ProgramFitnessEntity.serializer,
          this,
        )
        as Map<String, dynamic>;
  }
}
