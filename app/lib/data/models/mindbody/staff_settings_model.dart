import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'staff_settings_model.g.dart';

abstract class StaffSettingsModel
    implements Built<StaffSettingsModel, StaffSettingsModelBuilder> {
  @BuiltValueField(wireName: 'UseStaffNicknames')
  bool? get useStaffNicknames;

  @BuiltValueField(wireName: 'ShowStaffLastNamesOnSchedules')
  bool? get showStaffLastNamesOnSchedules;

  StaffSettingsModel._();
  factory StaffSettingsModel(
          [void Function(StaffSettingsModelBuilder) updates]) =
      _$StaffSettingsModel;

  static Serializer<StaffSettingsModel> get serializer =>
      _$staffSettingsModelSerializer;

  factory StaffSettingsModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        StaffSettingsModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(StaffSettingsModel.serializer, this)
        as Map<String, dynamic>;
  }
}
