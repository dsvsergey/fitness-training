import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'fitness.dart';

part 'workout_appointment_result_entity.g.dart';

abstract class WorkoutAppointmentResultEntity
    implements
        Built<WorkoutAppointmentResultEntity,
            WorkoutAppointmentResultEntityBuilder> {
  static Serializer<WorkoutAppointmentResultEntity> get serializer =>
      _$workoutAppointmentResultEntitySerializer;

  BuiltList<WorkoutAppointmentEntity>? get appointments;

  BuiltList<DateTime>? get workDays;

  WorkoutAppointmentResultEntity._();

  factory WorkoutAppointmentResultEntity(
          [void Function(WorkoutAppointmentResultEntityBuilder) updates]) =
      _$WorkoutAppointmentResultEntity;
}
