class PlanActivateResponse {
  String? planCode;
  String? startedAt;
  String? expiresAt;
  bool? activePaid;
  num? daysLeft;

  PlanActivateResponse({
    this.planCode, this.startedAt, this.expiresAt, this.activePaid, this.daysLeft
  });

  PlanActivateResponse copyWith({
    String? planCode, String? startedAt, String? expiresAt, bool? activePaid, num? daysLeft
  }) =>
      PlanActivateResponse(planCode: planCode ?? this.planCode,
          startedAt: startedAt ?? this.startedAt,
          expiresAt: expiresAt ?? this.expiresAt,
          activePaid: activePaid ?? this.activePaid,
          daysLeft: daysLeft ?? this.daysLeft);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["planCode"] = planCode;
    map["startedAt"] = startedAt;
    map["expiresAt"] = expiresAt;
    map["activePaid"] = activePaid;
    map["daysLeft"] = daysLeft;
    return map;
  }

  PlanActivateResponse.fromJson(dynamic json) {
    planCode = json["planCode"];
    startedAt = json["startedAt"];
    expiresAt = json["expiresAt"];
    activePaid = json["activePaid"];
    daysLeft = json["daysLeft"];
  }
}