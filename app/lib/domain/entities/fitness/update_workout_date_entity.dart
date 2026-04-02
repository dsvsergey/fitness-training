import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';

part 'update_workout_date_entity.g.dart';

abstract class UpdateWorkoutDateEntity
    implements Built<UpdateWorkoutDateEntity, UpdateWorkoutDateEntityBuilder> {
  static Serializer<UpdateWorkoutDateEntity> get serializer =>
      _$updateWorkoutDateEntitySerializer;

  @BuiltValueField(wireName: 'workout_date')
  DateTime? get workoutDate;

  UpdateWorkoutDateEntity._();

  factory UpdateWorkoutDateEntity(
          [void Function(UpdateWorkoutDateEntityBuilder) updates]) =
      _$UpdateWorkoutDateEntity;

  static UpdateWorkoutDateEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
        UpdateWorkoutDateEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(
        UpdateWorkoutDateEntity.serializer, this) as Map<String, dynamic>;
  }
}
