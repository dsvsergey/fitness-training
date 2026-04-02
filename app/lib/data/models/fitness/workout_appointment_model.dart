import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';
import 'fitness.dart';

part 'workout_appointment_model.g.dart';

abstract class WorkoutAppointmentModel
    implements Built<WorkoutAppointmentModel, WorkoutAppointmentModelBuilder> {
  static Serializer<WorkoutAppointmentModel> get serializer =>
      _$workoutAppointmentModelSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  TraineeModel get trainee;

  CoachModel get coach;

  @BuiltValueField(wireName: 'duration')
  int get duration;

  @BuiltValueField(wireName: 'status')
  AppointmentStatusEnum get status;

  @BuiltValueField(wireName: 'start_at')
  DateTime get startAt;

  @BuiltValueField(wireName: 'end_at')
  DateTime get endAt;

  @BuiltValueField(wireName: 'notes')
  String? get notes;

  WorkoutAppointmentModel._();

  factory WorkoutAppointmentModel(
          [void Function(WorkoutAppointmentModelBuilder) updates]) =
      _$WorkoutAppointmentModel;

  static WorkoutAppointmentModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        WorkoutAppointmentModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(
        WorkoutAppointmentModel.serializer, this) as Map<String, dynamic>;
  }
}

extension WorkoutAppointmentModelExtension on WorkoutAppointmentModel {
  WorkoutAppointmentEntity get entity => WorkoutAppointmentEntity(
        (b) => b
          ..id = id
          ..trainee = trainee.entity.toBuilder()
          ..coach = coach.entity.toBuilder()
          ..duration = duration
          ..status = status.entity
          ..startAt = startAt
          ..endAt = endAt
          ..notes = notes,
      );
}

extension WorkoutAppointmentEntityExtension on WorkoutAppointmentEntity {
  WorkoutAppointmentModel get model => WorkoutAppointmentModel(
        (b) => b
          ..id = id
          ..trainee = trainee.model.toBuilder()
          ..coach = coach.model.toBuilder()
          ..duration = duration
          ..status = status.model
          ..startAt = startAt
          ..endAt = endAt
          ..notes = notes,
      );
}
