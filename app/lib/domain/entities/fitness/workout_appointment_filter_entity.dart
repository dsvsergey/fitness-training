import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';

part 'workout_appointment_filter_entity.g.dart';

abstract class WorkoutAppointmentFilterEntity
    implements
        Built<
          WorkoutAppointmentFilterEntity,
          WorkoutAppointmentFilterEntityBuilder
        > {
  static Serializer<WorkoutAppointmentFilterEntity> get serializer =>
      _$workoutAppointmentFilterEntitySerializer;

  String get startDate;
  String? get endDate;
  BuiltList<int>? get coachIds;

  WorkoutAppointmentFilterEntity._();

  factory WorkoutAppointmentFilterEntity([
    void Function(WorkoutAppointmentFilterEntityBuilder) updates,
  ]) = _$WorkoutAppointmentFilterEntity;

  static WorkoutAppointmentFilterEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
      WorkoutAppointmentFilterEntity.serializer,
      json,
    )!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(
          WorkoutAppointmentFilterEntity.serializer,
          this,
        )
        as Map<String, dynamic>;
  }
}
