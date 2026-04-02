import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'status_enum.g.dart';

class StatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: 'None')
  static const StatusEnum none = _$none;

  @BuiltValueEnumConst(wireName: 'Requested')
  static const StatusEnum requested = _$requested;

  @BuiltValueEnumConst(wireName: 'Booked')
  static const StatusEnum booked = _$booked;

  @BuiltValueEnumConst(wireName: 'Completed')
  static const StatusEnum completed = _$completed;

  @BuiltValueEnumConst(wireName: 'Confirmed')
  static const StatusEnum confirmed = _$confirmed;

  @BuiltValueEnumConst(wireName: 'Arrived')
  static const StatusEnum arrived = _$arrived;

  @BuiltValueEnumConst(wireName: 'NoShow')
  static const StatusEnum noShow = _$noShow;

  @BuiltValueEnumConst(wireName: 'Cancelled')
  static const StatusEnum cancelled = _$cancelled;

  @BuiltValueEnumConst(wireName: 'LateCancelled')
  static const StatusEnum lateCancelled = _$lateCancelled;

  const StatusEnum._(super.name);

  static BuiltSet<StatusEnum> get values => _$valuesStatusEnum;
  static StatusEnum valueOf(String name) => _$valueOfStatusEnum(name);

  static Serializer<StatusEnum> get serializer => _$statusEnumSerializer;
}
