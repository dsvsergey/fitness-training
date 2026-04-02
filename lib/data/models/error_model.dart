class ErrorModel {
  ErrorModel({this.error});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    error = json["Error"] != null ? Error.fromJson(json["Error"]) : null;
  }
  Error? error;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (error != null) {
      data["Error"] = error!.toJson();
    }
    return data;
  }
}

class Error {
  Error({this.message, this.code});

  Error.fromJson(Map<String, dynamic> json) {
    message = json["Message"];
    code = json["Code"];
  }
  String? message;
  String? code;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["Message"] = message;
    data["Code"] = code;
    return data;
  }
}
