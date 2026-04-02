import 'package:fitness_training/data/models/mindbody/pagination_model.dart';

class VisitsModel {
  PaginationModel? paginationResponse;
  List<VisitModel>? visits;

  VisitsModel({this.paginationResponse, this.visits});

  VisitsModel.fromJson(Map<String, dynamic> json) {
    paginationResponse = json['PaginationResponse'] != null
        ? PaginationModel.fromJson(json['PaginationResponse'])
        : null;
    if (json['Visits'] != null) {
      visits = <VisitModel>[];
      json['Visits'].forEach((v) {
        visits!.add(VisitModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (paginationResponse != null) {
      data['PaginationResponse'] = paginationResponse!.toJson();
    }
    if (visits != null) {
      data['Visits'] = visits!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VisitModel {
  int? appointmentId;
  String? appointmentGenderPreference;
  String? appointmentStatus;
  int? classId;
  String? clientId;

  VisitModel(
      {this.appointmentId,
      this.appointmentGenderPreference,
      this.appointmentStatus,
      this.classId,
      this.clientId});

  VisitModel.fromJson(Map<String, dynamic> json) {
    appointmentId = json['AppointmentId'];
    appointmentGenderPreference = json['AppointmentGenderPreference'];
    appointmentStatus = json['AppointmentStatus'];
    classId = json['ClassId'];
    clientId = json['ClientId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AppointmentId'] = appointmentId;
    data['AppointmentGenderPreference'] = appointmentGenderPreference;
    data['AppointmentStatus'] = appointmentStatus;
    data['ClassId'] = classId;
    data['ClientId'] = clientId;
    return data;
  }
}
