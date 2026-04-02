import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'unavailability_model.g.dart';

abstract class UnavailabilityModel
    implements Built<UnavailabilityModel, UnavailabilityModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'StartDateTime')
  DateTime? get startDateTime;

  @BuiltValueField(wireName: 'EndDateTime')
  DateTime? get endDateTime;

  @BuiltValueField(wireName: 'Description')
  String? get description;

  UnavailabilityModel._();
  factory UnavailabilityModel(
          [void Function(UnavailabilityModelBuilder) updates]) =
      _$UnavailabilityModel;

  static Serializer<UnavailabilityModel> get serializer =>
      _$unavailabilityModelSerializer;

  factory UnavailabilityModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        UnavailabilityModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(UnavailabilityModel.serializer, this)
        as Map<String, dynamic>;
  }
}
