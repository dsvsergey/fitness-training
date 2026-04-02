import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../../../domain/entities/fitness/fitness.dart';

part 'session_status_enum.g.dart';

class SessionStatusEnum extends EnumClass {
  static Serializer<SessionStatusEnum> get serializer =>
      _$sessionStatusEnumSerializer;

  @BuiltValueEnumConst(wireName: 'Planned')
  static const SessionStatusEnum planned = _$planned;

  @BuiltValueEnumConst(wireName: 'InProgress')
  static const SessionStatusEnum inProgress = _$inProgress;

  @BuiltValueEnumConst(wireName: 'Completed')
  static const SessionStatusEnum completed = _$completed;

  const SessionStatusEnum._(super.name);

  static BuiltSet<SessionStatusEnum> get values => _$values;
  static SessionStatusEnum valueOf(String name) => _$valueOf(name);
}

extension SessionStatusEnumExtension on SessionStatusEnum {
  SessionStatusEnumEntity get entity => switch (this) {
        SessionStatusEnum.planned => SessionStatusEnumEntity.planned,
        SessionStatusEnum.inProgress => SessionStatusEnumEntity.inProgress,
        SessionStatusEnum.completed => SessionStatusEnumEntity.completed,
        _ => throw Exception('Invalid SessionStatusEnum')
      };
}

extension SessionStatusEnumEntityExtension on SessionStatusEnumEntity {
  SessionStatusEnum get model => switch (this) {
        SessionStatusEnumEntity.planned => SessionStatusEnum.planned,
        SessionStatusEnumEntity.inProgress => SessionStatusEnum.inProgress,
        SessionStatusEnumEntity.completed => SessionStatusEnum.completed,
        _ => throw Exception('Invalid SessionStatusEnumEntity')
      };
}
