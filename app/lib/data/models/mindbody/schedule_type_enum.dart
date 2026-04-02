import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'schedule_type_enum.g.dart';

class ScheduleTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: 'All')
  static const ScheduleTypeEnum all = _$all;

  @BuiltValueEnumConst(wireName: 'ClassType')
  static const ScheduleTypeEnum classType = _$classType;

  @BuiltValueEnumConst(wireName: 'Enrollment')
  static const ScheduleTypeEnum enrollment = _$enrollment;

  @BuiltValueEnumConst(wireName: 'Appointment')
  static const ScheduleTypeEnum appointment = _$appointment;

  @BuiltValueEnumConst(wireName: 'Resource')
  static const ScheduleTypeEnum resource = _$resource;

  @BuiltValueEnumConst(wireName: 'Media')
  static const ScheduleTypeEnum media = _$media;

  @BuiltValueEnumConst(wireName: 'Arrival')
  static const ScheduleTypeEnum arrival = _$arrival;

  const ScheduleTypeEnum._(super.name);

  static BuiltSet<ScheduleTypeEnum> get values => _$stValues;
  static ScheduleTypeEnum valueOf(String name) => _$stValueOf(name);

  static Serializer<ScheduleTypeEnum> get serializer =>
      _$scheduleTypeEnumSerializer;
}
