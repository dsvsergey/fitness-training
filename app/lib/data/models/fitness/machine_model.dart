import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';

part 'machine_model.g.dart';

abstract class MachineModel
    implements Built<MachineModel, MachineModelBuilder> {
  static Serializer<MachineModel> get serializer => _$machineModelSerializer;

  int? get id;
  String get name;
  int? get index;

  MachineModel._();

  factory MachineModel([void Function(MachineModelBuilder) updates]) =
      _$MachineModel;

  static MachineModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(MachineModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(MachineModel.serializer, this)
        as Map<String, dynamic>;
  }
}

extension MachineModelExtension on MachineModel {
  MachineEntity get entity => MachineEntity(
        (b) => b
          ..id = id
          ..name = name
          ..index = index,
      );
}

extension MachineEntityExtension on MachineEntity {
  MachineModel get model => MachineModel(
        (b) => b
          ..id = id
          ..name = name
          ..index = index,
      );
}
