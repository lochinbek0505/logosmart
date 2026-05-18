class ProfileResponse {
  String? id;
  String? fullName;
  num? age;
  String? phoneNumber;
  String? profileImage;
  String? region;
  String? district;
  num? amount;
  String? status;
  List<String>? rolesList;
  dynamic teacherProfile;
  String? subscriptionName; // Yangi maydon
  String? subscriptionCode;
  String? subscriptionStartedAt;
  dynamic subscriptionExpiresAt;

  ProfileResponse({
    this.id,
    this.fullName,
    this.age,
    this.phoneNumber,
    this.profileImage,
    this.region,
    this.district,
    this.amount,
    this.status,
    this.rolesList,
    this.teacherProfile,
    this.subscriptionName,
    this.subscriptionCode,
    this.subscriptionStartedAt,
    this.subscriptionExpiresAt,
  });

  ProfileResponse copyWith({
    String? id,
    String? fullName,
    num? age,
    String? phoneNumber,
    String? profileImage,
    String? region,
    String? district,
    num? amount,
    String? status,
    List<String>? rolesList,
    dynamic teacherProfile,
    String? subscriptionName,
    String? subscriptionCode,
    String? subscriptionStartedAt,
    dynamic subscriptionExpiresAt,
  }) => ProfileResponse(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    age: age ?? this.age,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    profileImage: profileImage ?? this.profileImage,
    region: region ?? this.region,
    district: district ?? this.district,
    amount: amount ?? this.amount,
    status: status ?? this.status,
    rolesList: rolesList ?? this.rolesList,
    teacherProfile: teacherProfile ?? this.teacherProfile,
    subscriptionName: subscriptionName ?? this.subscriptionName,
    subscriptionCode: subscriptionCode ?? this.subscriptionCode,
    subscriptionStartedAt: subscriptionStartedAt ?? this.subscriptionStartedAt,
    subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["fullName"] = fullName;
    map["age"] = age;
    map["phoneNumber"] = phoneNumber;
    map["profileImage"] = profileImage;
    map["region"] = region;
    map["district"] = district;
    map["amount"] = amount;
    map["status"] = status;
    map["roles"] = rolesList;
    map["teacherProfile"] = teacherProfile;
    map["subscriptionName"] = subscriptionName;
    map["subscriptionCode"] = subscriptionCode;
    map["subscriptionStartedAt"] = subscriptionStartedAt;
    map["subscriptionExpiresAt"] = subscriptionExpiresAt;
    return map;
  }

  ProfileResponse.fromJson(dynamic json) {
    id = json["id"];
    fullName = json["fullName"];
    age = json["age"];
    phoneNumber = json["phoneNumber"];
    profileImage = json["profileImage"];
    region = json["region"];
    district = json["district"];
    amount = json["amount"];
    status = json["status"];
    rolesList = json["roles"] != null ? json["roles"].cast<String>() : [];
    teacherProfile = json["teacherProfile"];
    subscriptionName = json["subscriptionName"];
    subscriptionCode = json["subscriptionCode"];
    subscriptionStartedAt = json["subscriptionStartedAt"];
    subscriptionExpiresAt = json["subscriptionExpiresAt"];
  }
}
