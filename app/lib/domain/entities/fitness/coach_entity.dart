import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../entities.dart';

part 'coach_entity.g.dart';

abstract class CoachEntity implements Built<CoachEntity, CoachEntityBuilder> {
  static Serializer<CoachEntity> get serializer => _$coachEntitySerializer;

  int? get id;
  String? get firstName;
  String? get lastName;
  String? get address1;
  String? get address2;
  String? get city;
  String? get state;
  String? get postalCode;
  String? get country;
  String? get gender;
  String? get biography;
  String? get imageUrl;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  String? get mobilePhone;
  String? get homePhone;
  String? get note;
  String? get email;

  CoachEntity._();

  factory CoachEntity([void Function(CoachEntityBuilder) updates]) =
      _$CoachEntity;

  static CoachEntity fromJson(Map<String, dynamic> json) {
    return entitySerializers.deserializeWith(CoachEntity.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return entitySerializers.serializeWith(CoachEntity.serializer, this)
        as Map<String, dynamic>;
  }

  String get fullName => [
        if (firstName != null) firstName,
        if (lastName != null) lastName
      ].join(' ');
}
