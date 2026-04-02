import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:fitness_training/data/models/fitness/fitness.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';

part 'trainee_model.g.dart';

abstract class TraineeModel
    implements Built<TraineeModel, TraineeModelBuilder> {
  static Serializer<TraineeModel> get serializer => _$traineeModelSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'first_name')
  String? get firstName;

  @BuiltValueField(wireName: 'last_name')
  String? get lastName;

  @BuiltValueField(wireName: 'email')
  String? get email;

  @BuiltValueField(wireName: 'mobile_phone')
  String? get mobilePhone;

  @BuiltValueField(wireName: 'home_phone')
  String? get homePhone;

  @BuiltValueField(wireName: 'work_phone')
  String? get workPhone;

  @BuiltValueField(wireName: 'address1')
  String? get address1;

  @BuiltValueField(wireName: 'address2')
  String? get address2;

  @BuiltValueField(wireName: 'city')
  String? get city;

  @BuiltValueField(wireName: 'state')
  String? get state;

  @BuiltValueField(wireName: 'postal_code')
  String? get postalCode;

  @BuiltValueField(wireName: 'country')
  String? get country;

  @BuiltValueField(wireName: 'birth_date')
  DateTime? get birthDate;

  @BuiltValueField(wireName: 'gender')
  String? get gender;

  @BuiltValueField(wireName: 'notes')
  String? get notes;

  @BuiltValueField(wireName: 'photo_url')
  String? get photoUrl;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  double? get weight;

  double? get height;

  @BuiltValueField(wireName: 'programs')
  BuiltList<ProgramFitnessModel>? get programs;

  TraineeModel._();

  factory TraineeModel([void Function(TraineeModelBuilder) updates]) =
      _$TraineeModel;

  static TraineeModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(TraineeModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(TraineeModel.serializer, this)
        as Map<String, dynamic>;
  }
}

extension TraineeModelExtension on TraineeModel {
  TraineeEntity get entity => TraineeEntity(
    (b) => b
      ..id = id
      ..firstName = firstName
      ..lastName = lastName
      ..email = email
      ..mobilePhone = mobilePhone
      ..homePhone = homePhone
      ..workPhone = workPhone
      ..address1 = address1
      ..address2 = address2
      ..city = city
      ..state = state
      ..postalCode = postalCode
      ..country = country
      ..birthDate = birthDate
      ..gender = gender
      ..notes = notes
      ..photoUrl = photoUrl
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..height = height
      ..weight = weight
      ..programs = programs?.map((p0) => p0.entity).toBuiltList().toBuilder(),
  );
}

extension TraineeEntityExtension on TraineeEntity {
  TraineeModel get model => TraineeModel(
    (b) => b
      ..id = id
      ..firstName = firstName
      ..lastName = lastName
      ..email = email
      ..mobilePhone = mobilePhone
      ..homePhone = homePhone
      ..workPhone = workPhone
      ..address1 = address1
      ..address2 = address2
      ..city = city
      ..state = state
      ..postalCode = postalCode
      ..country = country
      ..birthDate = birthDate
      ..gender = gender
      ..notes = notes
      ..photoUrl = photoUrl
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..height = height
      ..weight = weight
      ..programs = programs?.map((p0) => p0.model).toBuiltList().toBuilder(),
  );
}
