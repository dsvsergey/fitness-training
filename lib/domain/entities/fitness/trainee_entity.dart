import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';
import 'fitness.dart';

part 'trainee_entity.g.dart';

abstract class TraineeEntity
    implements Built<TraineeEntity, TraineeEntityBuilder> {
  static Serializer<TraineeEntity> get serializer => _$traineeEntitySerializer;
  int? get id;
  String? get firstName;
  String? get lastName;
  String? get email;
  String? get mobilePhone;
  String? get homePhone;
  String? get workPhone;
  String? get address1;
  String? get address2;
  String? get city;
  String? get state;
  String? get postalCode;
  String? get country;
  DateTime? get birthDate;
  String? get gender;
  String? get notes;
  String? get photoUrl;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  double? get weight;
  double? get height;
  BuiltList<ProgramFitnessEntity>? get programs;

  TraineeEntity._();

  factory TraineeEntity([void Function(TraineeEntityBuilder) updates]) =
      _$TraineeEntity;

  static TraineeEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(TraineeEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(TraineeEntity.serializer, this)
        as Map<String, dynamic>;
  }

  String get fullName => [
        if (firstName != null) firstName,
        if (lastName != null) lastName
      ].join(' ');
}
