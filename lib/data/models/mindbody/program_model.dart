import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'program_model.g.dart';

abstract class ProgramModel
    implements Built<ProgramModel, ProgramModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int get id;

  @BuiltValueField(wireName: 'Name')
  String get name;

  @BuiltValueField(wireName: 'ScheduleType')
  ScheduleTypeEnum get scheduleType;

  @BuiltValueField(wireName: 'CancelOffset')
  int get cancelOffset;

  @BuiltValueField(wireName: 'ContentFormats')
  BuiltList<String> get contentFormats;

  // Assuming PricingRelationships is a defined model or enum, if not, adjust accordingly
  // @BuiltValueField(wireName: 'PricingRelationships')
  // PricingRelationships get pricingRelationships;

  ProgramModel._();
  factory ProgramModel([void Function(ProgramModelBuilder) updates]) =
      _$ProgramModel;

  static Serializer<ProgramModel> get serializer => _$programModelSerializer;

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(ProgramModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ProgramModel.serializer, this)
        as Map<String, dynamic>;
  }
}
