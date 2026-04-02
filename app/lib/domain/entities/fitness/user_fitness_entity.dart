import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fitness_training/domain/entities/fitness/coach_entity.dart';
import 'package:fitness_training/domain/entities/fitness/trainee_entity.dart';

import '../entities.dart';

part 'user_fitness_entity.g.dart';

abstract class UserFitnessEntity
    implements Built<UserFitnessEntity, UserFitnessEntityBuilder> {
  static Serializer<UserFitnessEntity> get serializer =>
      _$userFitnessEntitySerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'access_token')
  String? get token;

  CoachEntity? get coach;

  TraineeEntity? get trainee;

  UserFitnessEntity._();

  factory UserFitnessEntity([void Function(UserFitnessEntityBuilder) updates]) =
      _$UserFitnessEntity;

  static UserFitnessEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(
        UserFitnessEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(UserFitnessEntity.serializer, this)
        as Map<String, dynamic>;
  }

  String get authorization => ['Bearer', token ?? ''].join(' ');
}
