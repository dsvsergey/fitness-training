import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';
import 'fitness.dart';

part 'program_fitness_model.g.dart';

abstract class ProgramFitnessModel
    implements Built<ProgramFitnessModel, ProgramFitnessModelBuilder> {
  static Serializer<ProgramFitnessModel> get serializer =>
      _$programFitnessModelSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'name')
  String? get name;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'coach_id')
  int? get coachId;

  @BuiltValueField(wireName: 'trainee_id')
  int? get traineeId;

  int? get number;

  CoachModel? get coach;

  @BuiltValueField(wireName: 'is_archive')
  bool? get isArchive;

  @BuiltValueField(wireName: 'is_delete')
  bool? get isDelete;

  @BuiltValueField(wireName: 'workout_date')
  DateTime? get workoutDate;

  @BuiltValueField(wireName: 'program_machines')
  BuiltList<ProgramMachineModel>? get programMachines;

  ProgramFitnessModel._();

  factory ProgramFitnessModel([
    void Function(ProgramFitnessModelBuilder) updates,
  ]) = _$ProgramFitnessModel;

  static ProgramFitnessModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
      ProgramFitnessModel.serializer,
      json,
    )!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ProgramFitnessModel.serializer, this)
        as Map<String, dynamic>;
  }
}

extension ProgramFitnessModelExtension on ProgramFitnessModel {
  ProgramFitnessEntity get entity => ProgramFitnessEntity(
    (b) => b
      ..id = id
      ..name = name ?? ''
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..coachId = coachId
      ..traineeId = traineeId
      ..number = number
      ..coach = coach?.entity.toBuilder()
      ..programMachines = programMachines
          ?.map((p0) => p0.entity)
          .toBuiltList()
          .toBuilder()
      ..isArchive = isArchive
      ..isDelete = isDelete
      ..workoutDate = workoutDate,
  );
}

extension ProgramFitnessEntityExtension on ProgramFitnessEntity {
  ProgramFitnessModel get model => ProgramFitnessModel(
    (b) => b
      ..id = id
      ..name = name
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..coachId = coachId
      ..traineeId = traineeId
      ..number = number
      ..coach = coach?.model.toBuilder()
      ..programMachines = programMachines
          ?.map((p0) => p0.model)
          .toBuiltList()
          .toBuilder()
      ..isArchive = isArchive
      ..isDelete = isDelete
      ..workoutDate = workoutDate,
  );
}
