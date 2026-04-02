import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

import '../models.dart';

part 'pricing_model.g.dart';

abstract class PricingModel
    implements Built<PricingModel, PricingModelBuilder> {
  @BuiltValueField(wireName: 'PaysFor')
  BuiltList<int>? get paysFor;

  @BuiltValueField(wireName: 'PaidBy')
  BuiltList<int>? get paidBy;

  PricingModel._();
  factory PricingModel([void Function(PricingModelBuilder) updates]) =
      _$PricingModel;

  static Serializer<PricingModel> get serializer => _$pricingModelSerializer;

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(PricingModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(PricingModel.serializer, this)
        as Map<String, dynamic>;
  }
}
