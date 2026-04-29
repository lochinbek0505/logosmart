class User {
  String? id;
  String? phoneNumber;
  String? status;
  List<String>? rolesList;
  String? subscriptionCode;
  String? subscriptionStartedAt;
  dynamic subscriptionExpiresAt;

  User({
    this.id, this.phoneNumber, this.status, this.rolesList, this.subscriptionCode, this.subscriptionStartedAt, this.subscriptionExpiresAt
  });

  User copyWith({
    String? id, String? phoneNumber, String? status, List<
        String>? rolesList, String? subscriptionCode, String? subscriptionStartedAt, dynamic subscriptionExpiresAt
  }) =>
      User(id: id ?? this.id,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          status: status ?? this.status,
          rolesList: rolesList ?? this.rolesList,
          subscriptionCode: subscriptionCode ?? this.subscriptionCode,
          subscriptionStartedAt: subscriptionStartedAt ??
              this.subscriptionStartedAt,
          subscriptionExpiresAt: subscriptionExpiresAt ??
              this.subscriptionExpiresAt);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["phoneNumber"] = phoneNumber;
    map["status"] = status;
    map["roles"] = rolesList;
    map["subscriptionCode"] = subscriptionCode;
    map["subscriptionStartedAt"] = subscriptionStartedAt;
    map["subscriptionExpiresAt"] = subscriptionExpiresAt;
    return map;
  }

  User.fromJson(dynamic json) {
    id = json["id"];
    phoneNumber = json["phoneNumber"];
    status = json["status"];
    rolesList = json["roles"] != null ? json["roles"].cast<String>() : [];
    subscriptionCode = json["subscriptionCode"];
    subscriptionStartedAt = json["subscriptionStartedAt"];
    subscriptionExpiresAt = json["subscriptionExpiresAt"];
  }
}

class LoginModel {
  String? accessToken;
  String? refreshToken;
  User? user;

  LoginModel({
    this.accessToken, this.refreshToken, this.user
  });

  LoginModel copyWith({
    String? accessToken, String? refreshToken, User? user
  }) =>
      LoginModel(accessToken: accessToken ?? this.accessToken,
          refreshToken: refreshToken ?? this.refreshToken,
          user: user ?? this.user);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["accessToken"] = accessToken;
    map["refreshToken"] = refreshToken;
    if (user != null) {
      map["user"] = user?.toJson();
    }
    return map;
  }

  LoginModel.fromJson(dynamic json) {
    accessToken = json["accessToken"];
    refreshToken = json["refreshToken"];
    user = json["user"] != null ? User.fromJson(json["user"]) : null;
  }
}