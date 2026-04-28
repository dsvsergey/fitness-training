import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';
import 'fitness.dart';

part 'workout_appointment_entity.g.dart';

abstract class WorkoutAppointmentEntity
    implements
        Built<WorkoutAppointmentEntity, WorkoutAppointmentEntityBuilder> {
  static Serializer<WorkoutAppointmentEntity> get serializer =>
      _$workoutAppointmentEntitySerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  TraineeEntity get trainee;

  CoachEntity get coach;

  @BuiltValueField(wireName: 'program_id')
  int? get programId;

  @BuiltValueField(wireName: 'duration')
  int get duration;

  @BuiltValueField(wireName: 'status')
  AppointmentStatusEnumEntity get status;

  @BuiltValueField(wireName: 'start_at')
  DateTime get startAt;

  @BuiltValueField(wireName: 'end_at')
  DateTime get endAt;

  @BuiltValueField(wireName: 'notes')
  String? get notes;

  WorkoutAppointmentEntity._();

  factory WorkoutAppointmentEntity(
          [void Function(WorkoutAppointmentEntityBuilder) updates]) =
      _$WorkoutAppointmentEntity;

  static WorkoutAppointmentEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
        WorkoutAppointmentEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(
        WorkoutAppointmentEntity.serializer, this) as Map<String, dynamic>;
  }
}
