import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'class_model.g.dart';

abstract class ClassModel implements Built<ClassModel, ClassModelBuilder> {
  @BuiltValueField(wireName: 'ClassScheduleId')
  int? get classScheduleId;

  @BuiltValueField(wireName: 'Visits')
  BuiltList<VisitModel>? get visits;

  @BuiltValueField(wireName: 'Clients')
  BuiltList<ClientModel>? get clients;

  @BuiltValueField(wireName: 'Location')
  LocationModel? get location;

  @BuiltValueField(wireName: 'Resource')
  ResourceSlimModel? get resource;

  @BuiltValueField(wireName: 'MaxCapacity')
  int? get maxCapacity;

  @BuiltValueField(wireName: 'WebCapacity')
  int? get webCapacity;

  @BuiltValueField(wireName: 'TotalBooked')
  int? get totalBooked;

  @BuiltValueField(wireName: 'TotalSignedIn')
  int? get totalSignedIn;

  @BuiltValueField(wireName: 'TotalBookedWaitlist')
  int? get totalBookedWaitlist;

  @BuiltValueField(wireName: 'WebBooked')
  int? get webBooked;

  @BuiltValueField(wireName: 'SemesterId')
  int? get semesterId;

  @BuiltValueField(wireName: 'IsCanceled')
  bool? get isCanceled;

  @BuiltValueField(wireName: 'Substitute')
  bool? get substitute;

  @BuiltValueField(wireName: 'Active')
  bool? get active;

  @BuiltValueField(wireName: 'IsWaitlistAvailable')
  bool? get isWaitlistAvailable;

  @BuiltValueField(wireName: 'IsEnrolled')
  bool? get isEnrolled;

  @BuiltValueField(wireName: 'HideCancel')
  bool? get hideCancel;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'IsAvailable')
  bool? get isAvailable;

  @BuiltValueField(wireName: 'StartDateTime')
  DateTime? get startDateTime;

  @BuiltValueField(wireName: 'EndDateTime')
  DateTime? get endDateTime;

  @BuiltValueField(wireName: 'LastModifiedDateTime')
  DateTime? get lastModifiedDateTime;

  @BuiltValueField(wireName: 'ClassDescription')
  ClassDescriptionModel? get classDescription;

  @BuiltValueField(wireName: 'Staff')
  StaffModel? get staff;

  @BuiltValueField(wireName: 'BookingWindow')
  BookingWindowModel? get bookingWindow;

  @BuiltValueField(wireName: 'BookingStatus')
  BookingStatusEnum? get bookingStatus;

  @BuiltValueField(wireName: 'VirtualStreamLink')
  String? get virtualStreamLink;

  @BuiltValueField(wireName: 'WaitListSize')
  int? get waitListSize;

  ClassModel._();
  factory ClassModel([void Function(ClassModelBuilder) updates]) = _$ClassModel;

  static Serializer<ClassModel> get serializer => _$classModelSerializer;

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(ClassModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(ClassModel.serializer, this)
        as Map<String, dynamic>;
  }
}
