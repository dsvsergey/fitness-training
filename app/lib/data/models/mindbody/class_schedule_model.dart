import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'class_schedule_model.g.dart';

abstract class ClassScheduleModel
    implements Built<ClassScheduleModel, ClassScheduleModelBuilder> {
  @BuiltValueField(wireName: 'Classes')
  BuiltList<ClassModel>? get classes;

  @BuiltValueField(wireName: 'Clients')
  BuiltList<ClientModel>? get clients;

  @BuiltValueField(wireName: 'Course')
  CourseModel? get course;

  @BuiltValueField(wireName: 'SemesterId')
  int? get semesterId;

  @BuiltValueField(wireName: 'IsAvailable')
  bool? get isAvailable;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'ClassDescription')
  ClassDescriptionModel? get classDescription;

  @BuiltValueField(wireName: 'DaySunday')
  bool? get daySunday;

  @BuiltValueField(wireName: 'DayMonday')
  bool? get dayMonday;

  @BuiltValueField(wireName: 'DayTuesday')
  bool? get dayTuesday;

  @BuiltValueField(wireName: 'DayWednesday')
  bool? get dayWednesday;

  @BuiltValueField(wireName: 'DayThursday')
  bool? get dayThursday;

  @BuiltValueField(wireName: 'DayFriday')
  bool? get dayFriday;

  @BuiltValueField(wireName: 'DaySaturday')
  bool? get daySaturday;

  @BuiltValueField(wireName: 'AllowOpenEnrollment')
  bool? get allowOpenEnrollment;

  @BuiltValueField(wireName: 'AllowDateForwardEnrollment')
  bool? get allowDateForwardEnrollment;

  @BuiltValueField(wireName: 'StartTime')
  DateTime? get startTime;

  @BuiltValueField(wireName: 'EndTime')
  DateTime? get endTime;

  @BuiltValueField(wireName: 'StartDate')
  DateTime? get startDate;

  @BuiltValueField(wireName: 'EndDate')
  DateTime? get endDate;

  @BuiltValueField(wireName: 'Staff')
  StaffModel? get staff;

  @BuiltValueField(wireName: 'Location')
  LocationModel? get location;

  @BuiltValueField(wireName: 'FrequencyType')
  FrequencyTypeEnum? get frequencyType;

  @BuiltValueField(wireName: 'FrequencyInterval')
  int? get frequencyInterval;

  ClassScheduleModel._();
  factory ClassScheduleModel(
          [void Function(ClassScheduleModelBuilder) updates]) =
      _$ClassScheduleModel;

  static Serializer<ClassScheduleModel> get serializer =>
      _$classScheduleModelSerializer;

  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(
        ClassScheduleModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ClassScheduleModel.serializer, this)
        as Map<String, dynamic>;
  }
}
