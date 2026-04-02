import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_status_enum_entity.g.dart';

class SessionStatusEnumEntity extends EnumClass {
  static Serializer<SessionStatusEnumEntity> get serializer =>
      _$sessionStatusEnumEntitySerializer;

  @BuiltValueEnumConst(wireName: 'Planned')
  static const SessionStatusEnumEntity planned = _$planned;

  @BuiltValueEnumConst(wireName: 'InProgress')
  static const SessionStatusEnumEntity inProgress = _$inProgress;

  @BuiltValueEnumConst(wireName: 'Completed')
  static const SessionStatusEnumEntity completed = _$completed;

  const SessionStatusEnumEntity._(super.name);

  static BuiltSet<SessionStatusEnumEntity> get values => _$values;
  static SessionStatusEnumEntity valueOf(String name) => _$valueOf(name);
}
