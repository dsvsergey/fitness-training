import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'pagination_model.g.dart';

abstract class PaginationModel
    implements Built<PaginationModel, PaginationModelBuilder> {
  @BuiltValueField(wireName: 'RequestedLimit')
  int? get requestedLimit;

  @BuiltValueField(wireName: 'RequestedOffset')
  int? get requestedOffset;

  @BuiltValueField(wireName: 'PageSize')
  int? get pageSize;

  @BuiltValueField(wireName: 'TotalResults')
  int? get totalResults;

  PaginationModel._();

  factory PaginationModel([void Function(PaginationModelBuilder) updates]) =
      _$PaginationModel;

  static Serializer<PaginationModel> get serializer =>
      _$paginationModelSerializer;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(PaginationModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(PaginationModel.serializer, this)
        as Map<String, dynamic>;
  }
}
