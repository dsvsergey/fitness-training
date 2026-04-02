import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'staff_model.g.dart';

abstract class StaffModel implements Built<StaffModel, StaffModelBuilder> {
  @BuiltValueField(wireName: 'Address')
  String? get address;

  @BuiltValueField(wireName: 'AppointmentInstructor')
  bool? get appointmentInstructor;

  @BuiltValueField(wireName: 'AlwaysAllowDoubleBooking')
  bool? get alwaysAllowDoubleBooking;

  @BuiltValueField(wireName: 'Bio')
  String? get bio;

  @BuiltValueField(wireName: 'City')
  String? get city;

  @BuiltValueField(wireName: 'Country')
  String? get country;

  @BuiltValueField(wireName: 'Email')
  String? get email;

  @BuiltValueField(wireName: 'FirstName')
  String? get firstName;

  @BuiltValueField(wireName: 'DisplayName')
  String? get displayName;

  @BuiltValueField(wireName: 'HomePhone')
  String? get homePhone;

  @BuiltValueField(wireName: 'Id')
  int? get id;

  @BuiltValueField(wireName: 'IndependentContractor')
  bool? get independentContractor;

  @BuiltValueField(wireName: 'IsMale')
  bool? get isMale;

  @BuiltValueField(wireName: 'LastName')
  String? get lastName;

  @BuiltValueField(wireName: 'MobilePhone')
  String? get mobilePhone;

  @BuiltValueField(wireName: 'Name')
  String? get name;

  @BuiltValueField(wireName: 'PostalCode')
  String? get postalCode;

  @BuiltValueField(wireName: 'ClassTeacher')
  bool? get classTeacher;

  @BuiltValueField(wireName: 'SortOrder')
  int? get sortOrder;

  @BuiltValueField(wireName: 'State')
  String? get state;

  @BuiltValueField(wireName: 'WorkPhone')
  String? get workPhone;

  @BuiltValueField(wireName: 'ImageUrl')
  String? get imageUrl;

  @BuiltValueField(wireName: 'ClassAssistant')
  bool? get classAssistant;

  @BuiltValueField(wireName: 'EmploymentStart')
  DateTime? get employmentStart;

  @BuiltValueField(wireName: 'EmploymentEnd')
  DateTime? get employmentEnd;

  @BuiltValueField(wireName: 'ProviderIDs')
  BuiltList<String>? get providerIDs;

  @BuiltValueField(wireName: 'Rep')
  bool? get rep;

  @BuiltValueField(wireName: 'StaffSettings')
  StaffSettingsModel? get staffSettings;

  @BuiltValueField(wireName: 'Appointments')
  BuiltList<AppointmentModel>? get appointments;

  @BuiltValueField(wireName: 'Unavailabilities')
  BuiltList<UnavailabilityModel>? get unavailabilities;

  @BuiltValueField(wireName: 'Availabilities')
  BuiltList<AvailabilityModel>? get availabilities;

  @BuiltValueField(wireName: 'EmpID')
  String? get empID;

  StaffModel._();
  factory StaffModel([void Function(StaffModelBuilder) updates]) = _$StaffModel;

  static Serializer<StaffModel> get serializer => _$staffModelSerializer;

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(StaffModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(StaffModel.serializer, this)
        as Map<String, dynamic>;
  }
}
