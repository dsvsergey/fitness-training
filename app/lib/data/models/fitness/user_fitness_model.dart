import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fitness_training/data/models/fitness/coach_model.dart';
import 'package:fitness_training/data/models/fitness/trainee_model.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';

part 'user_fitness_model.g.dart';

abstract class UserFitnessModel
    implements Built<UserFitnessModel, UserFitnessModelBuilder> {
  static Serializer<UserFitnessModel> get serializer =>
      _$userFitnessModelSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'access_token')
  String? get token;

  CoachModel? get coach;

  TraineeModel? get trainee;

  UserFitnessModel._();

  factory UserFitnessModel([void Function(UserFitnessModelBuilder) updates]) =
      _$UserFitnessModel;

  static UserFitnessModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(UserFitnessModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(UserFitnessModel.serializer, this)
        as Map<String, dynamic>;
  }
}

extension UserFitnessModelExtension on UserFitnessModel {
  UserFitnessEntity get entity => UserFitnessEntity((b) => b
    ..id = id
    ..token = token
    ..coach = coach?.entity.toBuilder()
    ..trainee = trainee?.entity.toBuilder());
}

extension UserFitnessEntityExtension on UserFitnessEntity {
  UserFitnessModel get model => UserFitnessModel((b) => b
    ..id = id
    ..token = token
    ..coach = coach?.model.toBuilder()
    ..trainee = trainee?.model.toBuilder());
}
