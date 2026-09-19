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

  /// Optional second weight, used when the load changes mid-exercise
  /// (e.g. a minute at 280, then 30 seconds at 380).
  int? get weight2;
  SessionStatusEnumEntity get sessionStatus;
  DateTime? get createdAt;

  /// "280" or "280 / 380"; empty when no weight is set.
  String get weightLabel => formatWeights(weight, weight2);

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

/// Formats one or two weights the way coaches write them: "280 / 380".
String formatWeights(int? weight, int? weight2) =>
    [weight, weight2].whereType<int>().join(' / ');
