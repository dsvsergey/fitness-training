import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';
import 'trainee_entity.dart';

part 'trainee_out_entity.g.dart';

abstract class TraineeOutEntity
    implements Built<TraineeOutEntity, TraineeOutEntityBuilder> {
  static Serializer<TraineeOutEntity> get serializer =>
      _$traineeOutEntitySerializer;

  @BuiltValueField(wireName: 'total_count')
  int? get totalCount;

  BuiltList<TraineeEntity>? get trainees;

  TraineeOutEntity._();

  factory TraineeOutEntity([void Function(TraineeOutEntityBuilder) updates]) =
      _$TraineeOutEntity;

  static TraineeOutEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
        TraineeOutEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(TraineeOutEntity.serializer, this)
        as Map<String, dynamic>;
  }
}
