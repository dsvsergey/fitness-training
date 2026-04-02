import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gender_enum.g.dart';

class GenderEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: 'None')
  static const GenderEnum none = _$none;

  @BuiltValueEnumConst(wireName: 'Added')
  static const GenderEnum added = _$added;

  @BuiltValueEnumConst(wireName: 'Updated')
  static const GenderEnum updated = _$updated;

  @BuiltValueEnumConst(wireName: 'Failed')
  static const GenderEnum failed = _$failed;

  @BuiltValueEnumConst(wireName: 'Removed')
  static const GenderEnum removed = _$removed;

  const GenderEnum._(super.name);

  static BuiltSet<GenderEnum> get values => _$valuesGenderEnum;
  static GenderEnum valueOf(String name) => _$valueOfGenderEnum(name);

  static Serializer<GenderEnum> get serializer => _$genderEnumSerializer;
}
