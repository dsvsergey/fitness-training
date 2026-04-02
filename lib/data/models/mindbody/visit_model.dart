import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'visit_model.g.dart';

abstract class VisitModel implements Built<VisitModel, VisitModelBuilder> {
  @BuiltValueField(wireName: 'AppointmentId')
  int? get appointmentId;

  @BuiltValueField(wireName: 'AppointmentGenderPreference')
  GenderPreferenceEnum? get appointmentGenderPreference;

  @BuiltValueField(wireName: 'AppointmentStatus')
  StatusEnum? get appointmentStatus;

  @BuiltValueField(wireName: 'ClassId')
  int? get classId;

  @BuiltValueField(wireName: 'ClientId')
  String? get clientId;

  @BuiltValueField(wireName: 'ClientPhotoUrl')
  String? get clientPhotoUrl;

  @BuiltValueField(wireName: 'ClientUniqueId')
  int? get clientUniqueId;

  @BuiltValueField(wireName: 'StartDateTime')
  DateTime? get startDateTime;

  @BuiltValueField(wireName: 'EndDateTime')
  DateTime? get endDateTime;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'LastModifiedDateTime')
  DateTime? get lastModifiedDateTime;

  @BuiltValueField(wireName: 'LateCancelled')
  bool? get lateCancelled;

  @BuiltValueField(wireName: 'SiteId')
  int? get siteId;

  @BuiltValueField(wireName: 'LocationId')
  int? get locationId;

  @BuiltValueField(wireName: 'MakeUp')
  bool? get makeUp;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'ServiceId')
  int? get serviceId;

  @BuiltValueField(wireName: 'ServiceName')
  String? get serviceName;

  @BuiltValueField(wireName: 'Service')
  ClientServiceModel? get service;

  @BuiltValueField(wireName: 'ProductId')
  int? get productId;

  @BuiltValueField(wireName: 'SignedIn')
  bool? get signedIn;

  @BuiltValueField(wireName: 'StaffId')
  int? get staffId;

  @BuiltValueField(wireName: 'WebSignup')
  bool? get webSignup;

  @BuiltValueField(wireName: 'Action')
  GenderEnum? get action;

  @BuiltValueField(wireName: 'Missed')
  bool? get missed;

  @BuiltValueField(wireName: 'VisitType')
  int? get visitType;

  @BuiltValueField(wireName: 'TypeGroup')
  int? get typeGroup;

  @BuiltValueField(wireName: 'TypeTaken')
  String? get typeTaken;

  VisitModel._();
  factory VisitModel([void Function(VisitModelBuilder) updates]) = _$VisitModel;

  static Serializer<VisitModel> get serializer => _$visitModelSerializer;

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(VisitModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(VisitModel.serializer, this)
        as Map<String, dynamic>;
  }
}
