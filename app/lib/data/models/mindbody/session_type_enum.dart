import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_type_enum.g.dart';

class SessionTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: 'All')
  static const SessionTypeEnum all = _$all;

  @BuiltValueEnumConst(wireName: 'Class')
  static const SessionTypeEnum classType = _$classType;

  @BuiltValueEnumConst(wireName: 'Enrollment')
  static const SessionTypeEnum enrollment = _$enrollment;

  @BuiltValueEnumConst(wireName: 'Appointment')
  static const SessionTypeEnum appointment = _$appointment;

  @BuiltValueEnumConst(wireName: 'Resource')
  static const SessionTypeEnum resource = _$resource;

  @BuiltValueEnumConst(wireName: 'Media')
  static const SessionTypeEnum media = _$media;

  @BuiltValueEnumConst(wireName: 'Arrival')
  static const SessionTypeEnum arrival = _$arrival;

  const SessionTypeEnum._(super.name);

  static BuiltSet<SessionTypeEnum> get values => _$values;
  static SessionTypeEnum valueOf(String name) => _$valueOf(name);

  static Serializer<SessionTypeEnum> get serializer =>
      _$sessionTypeEnumSerializer;
}
