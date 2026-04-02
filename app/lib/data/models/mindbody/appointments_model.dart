import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../models.dart';
import 'mindbody.dart';

part 'appointments_model.g.dart';

abstract class AppointmentsModel
    implements Built<AppointmentsModel, AppointmentsModelBuilder> {
  @BuiltValueField(wireName: 'PaginationResponse')
  PaginationModel? get paginationResponse;

  @BuiltValueField(wireName: 'Appointments')
  BuiltList<AppointmentModel>? get appointments;

  AppointmentsModel._();
  factory AppointmentsModel([void Function(AppointmentsModelBuilder) updates]) =
      _$AppointmentsModel;

  static Serializer<AppointmentsModel> get serializer =>
      _$appointmentsModelSerializer;

  factory AppointmentsModel.fromJson(Map<String, dynamic> json) {
    return dataSerializers.deserializeWith(AppointmentsModel.serializer, json)!;
  }

  Map<String, dynamic> toJson() {
    return dataSerializers.serializeWith(AppointmentsModel.serializer, this)
        as Map<String, dynamic>;
  }
}
