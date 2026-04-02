import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'frequency_type_enum.g.dart';

class FrequencyTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: 'Daily')
  static const FrequencyTypeEnum daily = _$daily;

  @BuiltValueEnumConst(wireName: 'Weekly')
  static const FrequencyTypeEnum weekly = _$weekly;

  @BuiltValueEnumConst(wireName: 'Monthly')
  static const FrequencyTypeEnum monthly = _$monthly;

  const FrequencyTypeEnum._(super.name);

  static BuiltSet<FrequencyTypeEnum> get values => _$valuesFrequencyTypeEnum;
  static FrequencyTypeEnum valueOf(String name) =>
      _$valueOfFrequencyTypeEnum(name);

  static Serializer<FrequencyTypeEnum> get serializer =>
      _$frequencyTypeEnumSerializer;
}
