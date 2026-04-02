import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'fitness/fitness.dart';
import 'mindbody/mindbody.dart';

part 'models.g.dart';

@SerializersFor([
  TokenModel,
  UserModel,
  ClientModel,
  ClientsModel,
  LocationModel,
  PaginationModel,
  AppointmentAddOnModel,
  AppointmentsModel,
  AppointmentModel,
  GenderPreferenceEnum,
  StatusEnum,
  ResourceSlimModel,
  AmenitiesModel,
  ScheduleTypeEnum,
  UnavailabilityModel,
  StaffSettingsModel,
  SessionTypeEnum,
  SessionTypeModel,
  ProgramModel,
  AvailabilityModel,
  StaffModel,
  PricingModel,
  GenderEnum,
  ClientServiceModel,
  VisitModel,
  LevelModel,
  ClassDescriptionModel,
  BookingWindowModel,
  BookingStatusEnum,
  CourseModel,
  FrequencyTypeEnum,
  ClassScheduleModel,
  AppointmentStatusEnum,
  CoachModel,
  MachineModel,
  ProgramFitnessModel,
  ProgramMachineModel,
  SessionStatusEnum,
  TraineeModel,
  UserFitnessModel,
  WorkoutAppointmentModel,
  WorkoutSessionModel,
  ProgramCreateModel,
  TraineeOutModel,
  WorkoutAppointmentFilterModel,
  UpdateWorkoutDateModel,
  ProgramUpdateMachinesModel,
  WorkoutAppointmentResultModel,
])
final Serializers dataSerializers = (_$dataSerializers.toBuilder()
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
