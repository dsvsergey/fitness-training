import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';
import 'fitness.dart';

part 'workout_session_model.g.dart';

abstract class WorkoutSessionModel
    implements Built<WorkoutSessionModel, WorkoutSessionModelBuilder> {
  static Serializer<WorkoutSessionModel> get serializer =>
      _$workoutSessionModelSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'program_machine_id')
  int get programMachineId;

  @BuiltValueField(wireName: 'trainee_id')
  int get traineeId;

  @BuiltValueField(wireName: 'coach_id')
  int get coachId;

  @BuiltValueField(wireName: 'date_session')
  DateTime? get dateSession;

  @BuiltValueField(wireName: 'session_time')
  int? get sessionTime;

  @BuiltValueField(wireName: 'weight')
  int? get weight;

  @BuiltValueField(wireName: 'session_status')
  SessionStatusEnum get sessionStatus;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  WorkoutSessionModel._();

  factory WorkoutSessionModel(
          [void Function(WorkoutSessionModelBuilder) updates]) =
      _$WorkoutSessionModel;

  static WorkoutSessionModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        WorkoutSessionModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(WorkoutSessionModel.serializer, this)
        as Map<String, dynamic>;
  }
}

extension WorkoutSessionModelExtension on WorkoutSessionModel {
  WorkoutSessionEntity get entity {
    return WorkoutSessionEntity((b) => b
      ..id = id
      ..programMachineId = programMachineId
      ..traineeId = traineeId
      ..coachId = coachId
      ..dateSession = dateSession
      ..sessionTime = sessionTime
      ..weight = weight
      ..sessionStatus = sessionStatus.entity
      ..createdAt = createdAt);
  }
}

extension WorkoutSessionEntityExtension on WorkoutSessionEntity {
  WorkoutSessionModel get model {
    return WorkoutSessionModel((b) => b
      ..id = id
      ..programMachineId = programMachineId
      ..traineeId = traineeId
      ..coachId = coachId
      ..dateSession = dateSession
      ..sessionTime = sessionTime
      ..weight = weight
      ..sessionStatus = sessionStatus.model
      ..createdAt = createdAt);
  }
}
