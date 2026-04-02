import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'appointment_status_enum_entity.g.dart';

class AppointmentStatusEnumEntity extends EnumClass {
  static Serializer<AppointmentStatusEnumEntity> get serializer =>
      _$appointmentStatusEnumEntitySerializer;

  @BuiltValueEnumConst(wireName: 'NONE')
  static const AppointmentStatusEnumEntity noneStatus = _$noneStatus;

  @BuiltValueEnumConst(wireName: 'REQUESTED')
  static const AppointmentStatusEnumEntity requested = _$requested;

  @BuiltValueEnumConst(wireName: 'BOOKED')
  static const AppointmentStatusEnumEntity booked = _$booked;

  @BuiltValueEnumConst(wireName: 'COMPLETED')
  static const AppointmentStatusEnumEntity completed = _$completed;

  @BuiltValueEnumConst(wireName: 'CONFIRMED')
  static const AppointmentStatusEnumEntity confirmed = _$confirmed;

  @BuiltValueEnumConst(wireName: 'ARRIVED')
  static const AppointmentStatusEnumEntity arrived = _$arrived;

  @BuiltValueEnumConst(wireName: 'NO_SHOW')
  static const AppointmentStatusEnumEntity noShow = _$noShow;

  @BuiltValueEnumConst(wireName: 'CANCELLED')
  static const AppointmentStatusEnumEntity cancelled = _$cancelled;

  @BuiltValueEnumConst(wireName: 'LATE_CANCELLED')
  static const AppointmentStatusEnumEntity lateCancelled = _$lateCancelled;

  const AppointmentStatusEnumEntity._(super.name);

  static BuiltSet<AppointmentStatusEnumEntity> get values => _$values;
  static AppointmentStatusEnumEntity valueOf(String name) => _$valueOf(name);
}
