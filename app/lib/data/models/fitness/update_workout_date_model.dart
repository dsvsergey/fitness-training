import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'update_workout_date_model.g.dart';

abstract class UpdateWorkoutDateModel
    implements Built<UpdateWorkoutDateModel, UpdateWorkoutDateModelBuilder> {
  static Serializer<UpdateWorkoutDateModel> get serializer =>
      _$updateWorkoutDateModelSerializer;

  @BuiltValueField(wireName: 'workout_date')
  DateTime? get workoutDate;

  UpdateWorkoutDateModel._();

  factory UpdateWorkoutDateModel(
          [void Function(UpdateWorkoutDateModelBuilder) updates]) =
      _$UpdateWorkoutDateModel;

  static UpdateWorkoutDateModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        UpdateWorkoutDateModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(
        UpdateWorkoutDateModel.serializer, this) as Map<String, dynamic>;
  }
}
