class DataList {
  String? id;
  String? phone;
  String? amount;
  String? billingStatus;
  String? description;
  num? status;
  dynamic errorNote;
  String? createdAt;
  String? completedAt;

  DataList({
    this.id, this.phone, this.amount, this.billingStatus, this.description, this.status, this.errorNote, this.createdAt, this.completedAt
  });

  DataList copyWith({
    String? id, String? phone, String? amount, String? billingStatus, String? description, num? status, dynamic errorNote, String? createdAt, String? completedAt
  }) =>
      DataList(id: id ?? this.id,
          phone: phone ?? this.phone,
          amount: amount ?? this.amount,
          billingStatus: billingStatus ?? this.billingStatus,
          description: description ?? this.description,
          status: status ?? this.status,
          errorNote: errorNote ?? this.errorNote,
          createdAt: createdAt ?? this.createdAt,
          completedAt: completedAt ?? this.completedAt);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["phone"] = phone;
    map["amount"] = amount;
    map["billingStatus"] = billingStatus;
    map["description"] = description;
    map["status"] = status;
    map["errorNote"] = errorNote;
    map["createdAt"] = createdAt;
    map["completedAt"] = completedAt;
    return map;
  }

  DataList.fromJson(dynamic json) {
    id = json["id"];
    phone = json["phone"];
    amount = json["amount"];
    billingStatus = json["billingStatus"];
    description = json["description"];
    status = json["status"];
    errorNote = json["errorNote"];
    createdAt = json["createdAt"];
    completedAt = json["completedAt"];
  }
}

class BillingsModel {
  List<DataList>? dataListList;

  BillingsModel({
    this.dataListList
  });

  BillingsModel copyWith({
    List<DataList>? dataListList
  }) => BillingsModel(dataListList: dataListList ?? this.dataListList);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  BillingsModel.fromJson(dynamic json) {
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(DataList.fromJson(v));
      });
    }
  }
}