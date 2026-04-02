import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'appointment_model.g.dart';

abstract class AppointmentModel
    implements Built<AppointmentModel, AppointmentModelBuilder> {
  @BuiltValueField(wireName: 'GenderPreference')
  GenderPreferenceEnum? get genderPreference;

  @BuiltValueField(wireName: 'Duration')
  int? get duration;

  @BuiltValueField(wireName: 'ProviderId')
  String? get providerId;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'Status')
  StatusEnum? get status;

  @BuiltValueField(wireName: 'StartDateTime')
  DateTime? get startDateTime;

  @BuiltValueField(wireName: 'EndDateTime')
  DateTime? get endDateTime;

  @BuiltValueField(wireName: 'Notes')
  String? get notes;

  @BuiltValueField(wireName: 'PartnerExternalId')
  String? get partnerExternalId;

  @BuiltValueField(wireName: 'StaffRequested')
  bool? get staffRequested;

  @BuiltValueField(wireName: 'ProgramId')
  int? get programId;

  @BuiltValueField(wireName: 'SessionTypeId')
  int? get sessionTypeId;

  @BuiltValueField(wireName: 'LocationId')
  int? get locationId;

  @BuiltValueField(wireName: 'StaffId')
  int? get staffId;

  @BuiltValueField(wireName: 'ClientId')
  String? get clientId;

  @BuiltValueField(wireName: 'FirstAppointment')
  bool? get firstAppointment;

  @BuiltValueField(wireName: 'IsWaitlist')
  bool? get isWaitlist;

  @BuiltValueField(wireName: 'WaitlistEntryId')
  int? get waitlistEntryId;

  @BuiltValueField(wireName: 'ClientServiceId')
  int? get clientServiceId;

  @BuiltValueField(wireName: 'Resources')
  BuiltList<ResourceSlimModel>? get resources;

  @BuiltValueField(wireName: 'AddOns')
  BuiltList<AppointmentAddOnModel>? get addOns;

  @BuiltValueField(wireName: 'OnlineDescription')
  String? get onlineDescription;

  AppointmentModel._();
  factory AppointmentModel([void Function(AppointmentModelBuilder) updates]) =
      _$AppointmentModel;

  static Serializer<AppointmentModel> get serializer =>
      _$appointmentModelSerializer;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(AppointmentModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(AppointmentModel.serializer, this)
        as Map<String, dynamic>;
  }
}
