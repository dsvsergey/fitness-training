import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';
import 'fitness.dart';

part 'program_machine_entity.g.dart';

abstract class ProgramMachineEntity
    implements Built<ProgramMachineEntity, ProgramMachineEntityBuilder> {
  static Serializer<ProgramMachineEntity> get serializer =>
      _$programMachineEntitySerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'machine_id')
  int get machineId;

  @BuiltValueField(wireName: 'program_id')
  int get programId;

  @BuiltValueField(wireName: 'index')
  int? get index;

  MachineEntity? get machine;

  int? get seats;

  int? get pin;

  int? get back;

  String? get handle;

  String? get knees;

  String? get legs;

  bool? get forTwoLegs;

  String? get chest;

  String? get angal;

  String? get note;

  String? get thighs;

  String? get grip;

  BuiltList<WorkoutSessionEntity> get workouts;

  ProgramMachineEntity._();

  factory ProgramMachineEntity(
          [void Function(ProgramMachineEntityBuilder) updates]) =
      _$ProgramMachineEntity;

  static ProgramMachineEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
        ProgramMachineEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(
        ProgramMachineEntity.serializer, this) as Map<String, dynamic>;
  }
}
