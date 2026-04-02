import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';
import 'fitness.dart';

part 'workout_appointment_result_model.g.dart';

abstract class WorkoutAppointmentResultModel
    implements
        Built<WorkoutAppointmentResultModel,
            WorkoutAppointmentResultModelBuilder> {
  static Serializer<WorkoutAppointmentResultModel> get serializer =>
      _$workoutAppointmentResultModelSerializer;

  BuiltList<WorkoutAppointmentModel>? get appointments;

  @BuiltValueField(wireName: 'work_days')
  BuiltList<DateTime>? get workDays;

  WorkoutAppointmentResultModel._();

  factory WorkoutAppointmentResultModel(
          [void Function(WorkoutAppointmentResultModelBuilder) updates]) =
      _$WorkoutAppointmentResultModel;

  static WorkoutAppointmentResultModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        WorkoutAppointmentResultModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(
        WorkoutAppointmentModel.serializer, this) as Map<String, dynamic>;
  }
}

extension WorkoutAppointmentResultModelExtension
    on WorkoutAppointmentResultModel {
  WorkoutAppointmentResultEntity get entity => WorkoutAppointmentResultEntity(
        (b) => b
          ..appointments =
              appointments?.map((e) => e.entity).toBuiltList().toBuilder()
          ..workDays = workDays?.toBuiltList().toBuilder(),
      );
}

extension WorkoutAppointmentResultEntityExtension
    on WorkoutAppointmentResultEntity {
  WorkoutAppointmentResultModel get model => WorkoutAppointmentResultModel(
        (b) => b
          ..appointments =
              appointments?.map((e) => e.model).toBuiltList().toBuilder()
          ..workDays = workDays?.toBuiltList().toBuilder(),
      );
}
