import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';
import '../models.dart';
import 'program_fitness_model.dart';

part 'coach_model.g.dart';

abstract class CoachModel implements Built<CoachModel, CoachModelBuilder> {
  static Serializer<CoachModel> get serializer => _$coachModelSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'first_name')
  String? get firstName;

  @BuiltValueField(wireName: 'last_name')
  String? get lastName;

  String? get address1;

  String? get address2;

  String? get city;

  String? get state;

  @BuiltValueField(wireName: 'postal_code')
  String? get postalCode;

  String? get country;

  String? get gender;

  String? get biography;

  @BuiltValueField(wireName: 'image_url')
  String? get imageUrl;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  ProgramFitnessModel? get programs;

  @BuiltValueField(wireName: 'mobile_phone')
  String? get mobilePhone;

  @BuiltValueField(wireName: 'home_phone')
  String? get homePhone;

  String? get note;

  String? get email;

  CoachModel._();

  factory CoachModel([void Function(CoachModelBuilder) updates]) = _$CoachModel;

  static CoachModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(CoachModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(CoachModel.serializer, this)
        as Map<String, dynamic>;
  }
}

extension CoachModelExtension on CoachModel {
  CoachEntity get entity => CoachEntity((b) => b
    ..id = id
    ..firstName = firstName
    ..lastName = lastName
    ..address1 = address1
    ..address2 = address2
    ..city = city
    ..state = state
    ..postalCode = postalCode
    ..country = country
    ..gender = gender
    ..biography = biography
    ..imageUrl = imageUrl
    ..createdAt = createdAt
    ..updatedAt = updatedAt
    ..mobilePhone = mobilePhone
    ..homePhone = homePhone
    ..note = note
    ..email = email);
}

extension CoachEntityExtension on CoachEntity {
  CoachModel get model => CoachModel((b) => b
    ..id = id
    ..firstName = firstName
    ..lastName = lastName
    ..address1 = address1
    ..address2 = address2
    ..city = city
    ..state = state
    ..postalCode = postalCode
    ..country = country
    ..gender = gender
    ..biography = biography
    ..imageUrl = imageUrl
    ..createdAt = createdAt
    ..updatedAt = updatedAt
    ..mobilePhone = mobilePhone
    ..homePhone = homePhone
    ..note = note
    ..email = email);
}
