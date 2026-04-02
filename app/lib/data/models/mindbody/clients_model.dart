import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'clients_model.g.dart';

abstract class ClientsModel
    implements Built<ClientsModel, ClientsModelBuilder> {
  @BuiltValueField(wireName: 'PaginationResponse')
  PaginationModel? get paginationResponse;

  @BuiltValueField(wireName: 'Clients')
  BuiltList<ClientModel>? get clients;

  ClientsModel._();

  factory ClientsModel([void Function(ClientsModelBuilder) updates]) =
      _$ClientsModel;

  static Serializer<ClientsModel> get serializer => _$clientsModelSerializer;

  factory ClientsModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(ClientsModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ClientsModel.serializer, this)
        as Map<String, dynamic>;
  }
}
