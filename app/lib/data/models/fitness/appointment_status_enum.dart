import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';

part 'appointment_status_enum.g.dart';

class AppointmentStatusEnum extends EnumClass {
  static Serializer<AppointmentStatusEnum> get serializer =>
      _$appointmentStatusEnumSerializer;

  @BuiltValueEnumConst(wireName: 'NONE')
  static const AppointmentStatusEnum noneStatus = _$noneStatus;

  @BuiltValueEnumConst(wireName: 'REQUESTED')
  static const AppointmentStatusEnum requested = _$requested;

  @BuiltValueEnumConst(wireName: 'BOOKED')
  static const AppointmentStatusEnum booked = _$booked;

  @BuiltValueEnumConst(wireName: 'COMPLETED')
  static const AppointmentStatusEnum completed = _$completed;

  @BuiltValueEnumConst(wireName: 'CONFIRMED')
  static const AppointmentStatusEnum confirmed = _$confirmed;

  @BuiltValueEnumConst(wireName: 'ARRIVED')
  static const AppointmentStatusEnum arrived = _$arrived;

  @BuiltValueEnumConst(wireName: 'NO_SHOW')
  static const AppointmentStatusEnum noShow = _$noShow;

  @BuiltValueEnumConst(wireName: 'CANCELLED')
  static const AppointmentStatusEnum cancelled = _$cancelled;

  @BuiltValueEnumConst(wireName: 'LATE_CANCELLED')
  static const AppointmentStatusEnum lateCancelled = _$lateCancelled;

  const AppointmentStatusEnum._(super.name);

  static BuiltSet<AppointmentStatusEnum> get values => _$values;
  static AppointmentStatusEnum valueOf(String name) => _$valueOf(name);
}

extension AppointmentStatusEnumEntityExtension on AppointmentStatusEnumEntity {
  AppointmentStatusEnum get model => switch (this) {
        AppointmentStatusEnumEntity.noneStatus =>
          AppointmentStatusEnum.noneStatus,
        AppointmentStatusEnumEntity.requested =>
          AppointmentStatusEnum.requested,
        AppointmentStatusEnumEntity.booked => AppointmentStatusEnum.booked,
        AppointmentStatusEnumEntity.completed =>
          AppointmentStatusEnum.completed,
        AppointmentStatusEnumEntity.confirmed =>
          AppointmentStatusEnum.confirmed,
        AppointmentStatusEnumEntity.arrived => AppointmentStatusEnum.arrived,
        AppointmentStatusEnumEntity.noShow => AppointmentStatusEnum.noShow,
        AppointmentStatusEnumEntity.cancelled =>
          AppointmentStatusEnum.cancelled,
        AppointmentStatusEnumEntity.lateCancelled =>
          AppointmentStatusEnum.lateCancelled,
        _ => AppointmentStatusEnum.noneStatus
      };
}

extension AppointmentStatusEnumExtension on AppointmentStatusEnum {
  AppointmentStatusEnumEntity get entity => switch (this) {
        AppointmentStatusEnum.noneStatus =>
          AppointmentStatusEnumEntity.noneStatus,
        AppointmentStatusEnum.requested =>
          AppointmentStatusEnumEntity.requested,
        AppointmentStatusEnum.booked => AppointmentStatusEnumEntity.booked,
        AppointmentStatusEnum.completed =>
          AppointmentStatusEnumEntity.completed,
        AppointmentStatusEnum.confirmed =>
          AppointmentStatusEnumEntity.confirmed,
        AppointmentStatusEnum.arrived => AppointmentStatusEnumEntity.arrived,
        AppointmentStatusEnum.noShow => AppointmentStatusEnumEntity.noShow,
        AppointmentStatusEnum.cancelled =>
          AppointmentStatusEnumEntity.cancelled,
        AppointmentStatusEnum.lateCancelled =>
          AppointmentStatusEnumEntity.lateCancelled,
        _ => AppointmentStatusEnumEntity.noneStatus
      };
}
