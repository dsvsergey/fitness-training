import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'resource_slim_model.g.dart';

abstract class ResourceSlimModel
    implements Built<ResourceSlimModel, ResourceSlimModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  ResourceSlimModel._();

  factory ResourceSlimModel([void Function(ResourceSlimModelBuilder) updates]) =
      _$ResourceSlimModel;

  static Serializer<ResourceSlimModel> get serializer =>
      _$resourceSlimModelSerializer;

  factory ResourceSlimModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(ResourceSlimModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ResourceSlimModel.serializer, this)
        as Map<String, dynamic>;
  }
}
