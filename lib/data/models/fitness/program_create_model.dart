import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'fitness.dart';

part 'program_create_model.g.dart';

abstract class ProgramCreateModel
    implements Built<ProgramCreateModel, ProgramCreateModelBuilder> {
  static Serializer<ProgramCreateModel> get serializer =>
      _$programCreateModelSerializer;

  @BuiltValueField(wireName: 'coach_id')
  int get coachId;

  @BuiltValueField(wireName: 'trainee_id')
  int get traineeId;

  @BuiltValueField(wireName: 'machine_ids')
  BuiltList<int>? get machineIds;

  CoachModel? get coach;

  ProgramCreateModel._();

  factory ProgramCreateModel(
          [void Function(ProgramCreateModelBuilder) updates]) =
      _$ProgramCreateModel;

  static ProgramCreateModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        ProgramCreateModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ProgramCreateModel.serializer, this)
        as Map<String, dynamic>;
  }
}
