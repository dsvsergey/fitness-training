import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'fitness/fitness.dart';

part 'entities.g.dart';

@SerializersFor([
  UserFitnessEntity,
  CoachEntity,
  MachineEntity,
  ProgramFitnessEntity,
  ProgramMachineEntity,
  TraineeEntity,
  AppointmentStatusEnumEntity,
  WorkoutAppointmentEntity,
  SessionStatusEnumEntity,
  WorkoutSessionEntity,
  TraineeOutEntity,
  WorkoutAppointmentFilterEntity,
  UpdateWorkoutDateEntity,
  ProgramUpdateMachinesEntity,
  WorkoutAppointmentResultEntity,
])
final Serializers entitySerializers = (_$entitySerializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..add(_DateTimeSerializer()))
    .build();

class _DateTimeSerializer implements PrimitiveSerializer<DateTime> {
  @override
  final Iterable<Type> types = BuiltList<Type>([DateTime]);
  @override
  final String wireName = 'DateTime';

  @override
  Object serialize(Serializers serializers, DateTime dateTime,
      {FullType specifiedType = FullType.unspecified}) {
    return dateTime.toIso8601String();
  }

  @override
  DateTime deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return DateTime.parse(serialized as String);
  }
}
