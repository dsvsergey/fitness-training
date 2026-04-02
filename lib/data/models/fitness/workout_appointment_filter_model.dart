import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/workout_appointment_filter_entity.dart';
import '../models.dart';

part 'workout_appointment_filter_model.g.dart';

abstract class WorkoutAppointmentFilterModel
    implements
        Built<
          WorkoutAppointmentFilterModel,
          WorkoutAppointmentFilterModelBuilder
        > {
  static Serializer<WorkoutAppointmentFilterModel> get serializer =>
      _$workoutAppointmentFilterModelSerializer;

  @BuiltValueField(wireName: 'start_date')
  String get startDate;

  @BuiltValueField(wireName: 'end_date')
  String? get endDate;

  @BuiltValueField(wireName: 'coach_ids')
  BuiltList<int>? get coachIds;

  WorkoutAppointmentFilterModel._();

  factory WorkoutAppointmentFilterModel([
    void Function(WorkoutAppointmentFilterModelBuilder) updates,
  ]) = _$WorkoutAppointmentFilterModel;

  static WorkoutAppointmentFilterModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
      WorkoutAppointmentFilterModel.serializer,
      json,
    )!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(
          WorkoutAppointmentFilterModel.serializer,
          this,
        )
        as Map<String, dynamic>;
  }
}

extension WorkoutAppointmentFilterModelExtension
    on WorkoutAppointmentFilterModel {
  WorkoutAppointmentFilterEntity get entity => WorkoutAppointmentFilterEntity(
    (b) => b
      ..startDate = startDate
      ..endDate = endDate
      ..coachIds = coachIds?.map((p0) => p0).toBuiltList().toBuilder(),
  );
}

extension WorkoutAppointmentFilterEntityExtension
    on WorkoutAppointmentFilterEntity {
  WorkoutAppointmentFilterModel get model => WorkoutAppointmentFilterModel(
    (b) => b
      ..startDate = startDate
      ..endDate = endDate
      ..coachIds = coachIds?.map((p0) => p0).toBuiltList().toBuilder(),
  );
}
