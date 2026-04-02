import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'client_model.g.dart';

abstract class ClientModel implements Built<ClientModel, ClientModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  String? get id;

  @BuiltValueField(wireName: 'FirstName')
  String? get firstName;

  @BuiltValueField(wireName: 'LastName')
  String? get lastName;

  @BuiltValueField(wireName: 'Notes')
  String? get notes;

  @BuiltValueField(wireName: 'UniqueId')
  int? get uniqueId;

  @BuiltValueField(wireName: 'Email')
  String? get email;

  @BuiltValueField(wireName: 'MobilePhone')
  String? get mobilePhone;

  @BuiltValueField(wireName: 'City')
  String? get city;

  @BuiltValueField(wireName: 'PhotoUrl')
  String? get photoUrl;

  @BuiltValueField(wireName: 'Gender')
  String? get gender;

  @BuiltValueField(wireName: 'HomeLocation')
  LocationModel? get homeLocation;

  @BuiltValueField(wireName: 'LockerNumber')
  String? get lockerNumber;

  @BuiltValueField(wireName: 'Active')
  bool? get active;

  factory ClientModel([void Function(ClientModelBuilder) updates]) =
      _$ClientModel;

  ClientModel._();

  static Serializer<ClientModel> get serializer => _$clientModelSerializer;

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(ClientModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ClientModel.serializer, this)
        as Map<String, dynamic>;
  }
}
