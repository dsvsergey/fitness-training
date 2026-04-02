import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gender_preference_enum.g.dart';

class GenderPreferenceEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: 'None')
  static const GenderPreferenceEnum none = _$none;

  @BuiltValueEnumConst(wireName: 'Female')
  static const GenderPreferenceEnum female = _$female;

  @BuiltValueEnumConst(wireName: 'Male')
  static const GenderPreferenceEnum male = _$male;

  const GenderPreferenceEnum._(super.name);

  static BuiltSet<GenderPreferenceEnum> get values =>
      _$valuesGenderPreferenceEnum;
  static GenderPreferenceEnum valueOf(String name) =>
      _$valueOfGenderPreferenceEnum(name);

  static Serializer<GenderPreferenceEnum> get serializer =>
      _$genderPreferenceEnumSerializer;
}
