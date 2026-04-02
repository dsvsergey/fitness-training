import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'client_service_model.g.dart';

abstract class ClientServiceModel
    implements Built<ClientServiceModel, ClientServiceModelBuilder> {
  @BuiltValueField(wireName: 'ActiveDate')
  DateTime? get activeDate;

  @BuiltValueField(wireName: 'Count')
  int? get count;

  @BuiltValueField(wireName: 'Current')
  bool? get current;

  @BuiltValueField(wireName: 'ExpirationDate')
  DateTime? get expirationDate;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'ProductId')
  int? get productId;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'PaymentDate')
  DateTime? get paymentDate;

  @BuiltValueField(wireName: 'Program')
  ProgramModel? get program;

  @BuiltValueField(wireName: 'Remaining')
  int? get remaining;

  @BuiltValueField(wireName: 'SiteId')
  int? get siteId;

  @BuiltValueField(wireName: 'Action')
  GenderEnum? get action;

  @BuiltValueField(wireName: 'ClientID')
  String? get clientID;

  ClientServiceModel._();
  factory ClientServiceModel(
          [void Function(ClientServiceModelBuilder) updates]) =
      _$ClientServiceModel;

  static Serializer<ClientServiceModel> get serializer =>
      _$clientServiceModelSerializer;

  factory ClientServiceModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        ClientServiceModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ClientServiceModel.serializer, this)
        as Map<String, dynamic>;
  }
}
