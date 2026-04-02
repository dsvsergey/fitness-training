import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';

part 'program_update_machines_entity.g.dart';

abstract class ProgramUpdateMachinesEntity
    implements
        Built<ProgramUpdateMachinesEntity, ProgramUpdateMachinesEntityBuilder> {
  static Serializer<ProgramUpdateMachinesEntity> get serializer =>
      _$programUpdateMachinesEntitySerializer;
  int get programId;
  BuiltList<int>? get machineIds;

  ProgramUpdateMachinesEntity._();

  factory ProgramUpdateMachinesEntity(
          [void Function(ProgramUpdateMachinesEntityBuilder) updates]) =
      _$ProgramUpdateMachinesEntity;

  static ProgramUpdateMachinesEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
        ProgramUpdateMachinesEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(
        ProgramUpdateMachinesEntity.serializer, this) as Map<String, dynamic>;
  }
}
