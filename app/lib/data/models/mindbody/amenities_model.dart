import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'amenities_model.g.dart';

abstract class AmenitiesModel
    implements Built<AmenitiesModel, AmenitiesModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  AmenitiesModel._();
  factory AmenitiesModel([void Function(AmenitiesModelBuilder) updates]) =
      _$AmenitiesModel;

  static Serializer<AmenitiesModel> get serializer =>
      _$amenitiesModelSerializer;

  factory AmenitiesModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(AmenitiesModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(AmenitiesModel.serializer, this)
        as Map<String, dynamic>;
  }
}
