import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';

part 'booking_window_model.g.dart';

abstract class BookingWindowModel
    implements Built<BookingWindowModel, BookingWindowModelBuilder> {
  @BuiltValueField(wireName: 'StartDateTime')
  DateTime? get startDateTime;

  @BuiltValueField(wireName: 'EndDateTime')
  DateTime? get endDateTime;

  @BuiltValueField(wireName: 'DailyStartTime')
  DateTime? get dailyStartTime;

  @BuiltValueField(wireName: 'DailyEndTime')
  DateTime? get dailyEndTime;

  BookingWindowModel._();
  factory BookingWindowModel(
          [void Function(BookingWindowModelBuilder) updates]) =
      _$BookingWindowModel;

  static Serializer<BookingWindowModel> get serializer =>
      _$bookingWindowModelSerializer;

  factory BookingWindowModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        BookingWindowModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(BookingWindowModel.serializer, this)
        as Map<String, dynamic>;
  }
}
