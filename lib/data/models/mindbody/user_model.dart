import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'user_model.g.dart';

abstract class UserModel implements Built<UserModel, UserModelBuilder> {
  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'FirstName')
  String? get firstName;

  @BuiltValueField(wireName: 'LastName')
  String? get lastName;

  @BuiltValueField(wireName: 'Type')
  String? get type;

  UserModel._();
  factory UserModel([void Function(UserModelBuilder) updates]) = _$UserModel;
  static Serializer<UserModel> get serializer => _$userModelSerializer;

  static UserModel fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(UserModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(UserModel.serializer, this)
        as Map<String, dynamic>;
  }
}
