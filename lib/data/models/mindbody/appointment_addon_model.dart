import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'appointment_addon_model.g.dart';

abstract class AppointmentAddOnModel
    implements Built<AppointmentAddOnModel, AppointmentAddOnModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'StaffId')
  int? get staffId;

  @BuiltValueField(wireName: 'TypeId')
  int? get typeId;

  AppointmentAddOnModel._();
  factory AppointmentAddOnModel(
          [void Function(AppointmentAddOnModelBuilder) updates]) =
      _$AppointmentAddOnModel;

  static Serializer<AppointmentAddOnModel> get serializer =>
      _$appointmentAddOnModelSerializer;

  factory AppointmentAddOnModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        AppointmentAddOnModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(AppointmentAddOnModel.serializer, this)
        as Map<String, dynamic>;
  }
}
