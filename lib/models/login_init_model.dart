class LoginInitModel {
  String? message;

  LoginInitModel({
    this.message
  });

  LoginInitModel copyWith({
    String? message
  }) => LoginInitModel(message: message ?? this.message);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["message"] = message;
    return map;
  }

  LoginInitModel.fromJson(dynamic json) {
    message = json["message"];
  }
}