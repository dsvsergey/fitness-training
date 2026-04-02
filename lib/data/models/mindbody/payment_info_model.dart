import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

import '../models.dart';

part 'payment_info_model.g.dart';

abstract class PaymentInfoModel
    implements Built<PaymentInfoModel, PaymentInfoModelBuilder> {
  @BuiltValueField(wireName: 'PaysFor')
  BuiltList<int>? get paysFor;

  @BuiltValueField(wireName: 'PaidBy')
  BuiltList<int>? get paidBy;

  PaymentInfoModel._();
  factory PaymentInfoModel([void Function(PaymentInfoModelBuilder) updates]) =
      _$PaymentInfoModel;

  static Serializer<PaymentInfoModel> get serializer =>
      _$paymentInfoModelSerializer;

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(PaymentInfoModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(PaymentInfoModel.serializer, this)
        as Map<String, dynamic>;
  }
}
