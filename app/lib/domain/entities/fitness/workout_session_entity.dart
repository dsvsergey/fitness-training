import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';
import 'fitness.dart';

part 'workout_session_entity.g.dart';

abstract class WorkoutSessionEntity
    implements Built<WorkoutSessionEntity, WorkoutSessionEntityBuilder> {
  static Serializer<WorkoutSessionEntity> get serializer =>
      _$workoutSessionEntitySerializer;

  int? get id;
  int get programMachineId;
  int get traineeId;
  int get coachId;
  DateTime? get dateSession;
  int? get sessionTime;
  int? get weight;
  SessionStatusEnumEntity get sessionStatus;
  DateTime? get createdAt;

  WorkoutSessionEntity._();

  factory WorkoutSessionEntity(
          [void Function(WorkoutSessionEntityBuilder) updates]) =
      _$WorkoutSessionEntity;

  static WorkoutSessionEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
        WorkoutSessionEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(
        WorkoutSessionEntity.serializer, this) as Map<String, dynamic>;
  }
}
