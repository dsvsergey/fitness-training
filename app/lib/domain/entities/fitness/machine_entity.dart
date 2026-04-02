import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';

part 'machine_entity.g.dart';

abstract class MachineEntity
    implements Built<MachineEntity, MachineEntityBuilder> {
  static Serializer<MachineEntity> get serializer => _$machineEntitySerializer;

  int? get id;
  String get name;
  int? get index;

  MachineEntity._();

  factory MachineEntity([void Function(MachineEntityBuilder) updates]) =
      _$MachineEntity;

  static MachineEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(MachineEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(MachineEntity.serializer, this)
        as Map<String, dynamic>;
  }
}
