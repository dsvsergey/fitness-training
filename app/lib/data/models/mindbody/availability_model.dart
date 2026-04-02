import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'availability_model.g.dart';

abstract class AvailabilityModel
    implements Built<AvailabilityModel, AvailabilityModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'Staff')
  StaffModel? get staff;

  @BuiltValueField(wireName: 'SessionType')
  SessionTypeModel? get sessionType;

  @BuiltValueField(wireName: 'Programs')
  BuiltList<ProgramModel>? get programs;

  @BuiltValueField(wireName: 'StartDateTime')
  DateTime? get startDateTime;

  @BuiltValueField(wireName: 'EndDateTime')
  DateTime? get endDateTime;

  @BuiltValueField(wireName: 'BookableEndDateTime')
  DateTime? get bookableEndDateTime;

  @BuiltValueField(wireName: 'Location')
  LocationModel? get location;

  @BuiltValueField(wireName: 'PrepTime')
  int? get prepTime;

  @BuiltValueField(wireName: 'FinishTime')
  int? get finishTime;

  @BuiltValueField(wireName: 'IsMasked')
  bool? get isMasked;

  @BuiltValueField(wireName: 'ShowPublic')
  bool? get showPublic;

  AvailabilityModel._();
  factory AvailabilityModel([void Function(AvailabilityModelBuilder) updates]) =
      _$AvailabilityModel;

  static Serializer<AvailabilityModel> get serializer =>
      _$availabilityModelSerializer;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(AvailabilityModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(AvailabilityModel.serializer, this)
        as Map<String, dynamic>;
  }
}
