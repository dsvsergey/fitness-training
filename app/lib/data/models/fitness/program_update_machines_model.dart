import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';

part 'program_update_machines_model.g.dart';

abstract class ProgramUpdateMachinesModel
    implements
        Built<ProgramUpdateMachinesModel, ProgramUpdateMachinesModelBuilder> {
  static Serializer<ProgramUpdateMachinesModel> get serializer =>
      _$programUpdateMachinesModelSerializer;

  @BuiltValueField(wireName: 'id')
  int get programId;

  @BuiltValueField(wireName: 'machine_ids')
  BuiltList<int>? get machineIds;

  ProgramUpdateMachinesModel._();

  factory ProgramUpdateMachinesModel(
          [void Function(ProgramUpdateMachinesModelBuilder) updates]) =
      _$ProgramUpdateMachinesModel;

  static ProgramUpdateMachinesModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        ProgramUpdateMachinesModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(
        ProgramUpdateMachinesModel.serializer, this) as Map<String, dynamic>;
  }
}

extension ProgramUpdateMachinesModelX on ProgramUpdateMachinesModel {
  ProgramUpdateMachinesEntity get entity => ProgramUpdateMachinesEntity(
        (b) => b
          ..programId = programId
          ..machineIds = machineIds?.map((p0) => p0).toBuiltList().toBuilder(),
      );
}

extension ProgramUpdateMachinesEntityX on ProgramUpdateMachinesEntity {
  ProgramUpdateMachinesModel get model => ProgramUpdateMachinesModel(
        (b) => b
          ..programId = programId
          ..machineIds = machineIds?.map((p0) => p0).toBuiltList().toBuilder(),
      );
}
