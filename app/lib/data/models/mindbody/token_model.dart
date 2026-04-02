import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'token_model.g.dart';

abstract class TokenModel implements Built<TokenModel, TokenModelBuilder> {
  @BuiltValueField(wireName: 'TokenType')
  String? get tokenType;

  @BuiltValueField(wireName: 'AccessToken')
  String? get accessToken;

  @BuiltValueField(wireName: 'Expires')
  DateTime? get expires;

  @BuiltValueField(wireName: 'User')
  UserModel? get user;

  TokenModel._();
  factory TokenModel([void Function(TokenModelBuilder) updates]) = _$TokenModel;

  static Serializer<TokenModel> get serializer => _$tokenModelSerializer;

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(TokenModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(TokenModel.serializer, this)
        as Map<String, dynamic>;
  }
}
