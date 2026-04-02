import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'booking_status_enum.g.dart';

class BookingStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: 'PaymentRequired')
  static const BookingStatusEnum paymentRequired = _$paymentRequired;

  @BuiltValueEnumConst(wireName: 'BookAndPayLater')
  static const BookingStatusEnum bookAndPayLater = _$bookAndPayLater;

  @BuiltValueEnumConst(wireName: 'Free')
  static const BookingStatusEnum free = _$free;

  const BookingStatusEnum._(super.name);

  static BuiltSet<BookingStatusEnum> get values => _$valuesBookingStatusEnum;
  static BookingStatusEnum valueOf(String name) =>
      _$valueOfBookingStatusEnum(name);

  static Serializer<BookingStatusEnum> get serializer =>
      _$bookingStatusEnumSerializer;
}
