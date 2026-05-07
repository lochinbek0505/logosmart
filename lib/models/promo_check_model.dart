class PromoCheckModel {
  String? id;
  String? code;
  String? type;
  num? discountPercent;
  dynamic freeDays;
  bool? active;
  String? validFrom;
  String? validTo;
  num? maxUsages;
  num? usedCount;
  bool? expired;
  bool? limitReached;
  bool? valid;
  String? message;

  PromoCheckModel({
    this.id, this.code, this.type, this.discountPercent, this.freeDays, this.active, this.validFrom, this.validTo, this.maxUsages, this.usedCount, this.expired, this.limitReached, this.valid, this.message
  });

  PromoCheckModel copyWith({
    String? id, String? code, String? type, num? discountPercent, dynamic freeDays, bool? active, String? validFrom, String? validTo, num? maxUsages, num? usedCount, bool? expired, bool? limitReached, bool? valid, String? message
  }) =>
      PromoCheckModel(id: id ?? this.id,
          code: code ?? this.code,
          type: type ?? this.type,
          discountPercent: discountPercent ?? this.discountPercent,
          freeDays: freeDays ?? this.freeDays,
          active: active ?? this.active,
          validFrom: validFrom ?? this.validFrom,
          validTo: validTo ?? this.validTo,
          maxUsages: maxUsages ?? this.maxUsages,
          usedCount: usedCount ?? this.usedCount,
          expired: expired ?? this.expired,
          limitReached: limitReached ?? this.limitReached,
          valid: valid ?? this.valid,
          message: message ?? this.message);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["code"] = code;
    map["type"] = type;
    map["discountPercent"] = discountPercent;
    map["freeDays"] = freeDays;
    map["active"] = active;
    map["validFrom"] = validFrom;
    map["validTo"] = validTo;
    map["maxUsages"] = maxUsages;
    map["usedCount"] = usedCount;
    map["expired"] = expired;
    map["limitReached"] = limitReached;
    map["valid"] = valid;
    map["message"] = message;
    return map;
  }

  PromoCheckModel.fromJson(dynamic json) {
    id = json["id"];
    code = json["code"];
    type = json["type"];
    discountPercent = json["discountPercent"];
    freeDays = json["freeDays"];
    active = json["active"];
    validFrom = json["validFrom"];
    validTo = json["validTo"];
    maxUsages = json["maxUsages"];
    usedCount = json["usedCount"];
    expired = json["expired"];
    limitReached = json["limitReached"];
    valid = json["valid"];
    message = json["message"];
  }
}