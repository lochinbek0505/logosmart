class DataList {
  String? id;
  String? code;
  String? name;
  num? durationDays;
  num? price;
  String? currency;
  List<String>? featuresList;
  List<String>? promoTextsList;
  bool? active;
  String? updatedAt;

  DataList({
    this.id, this.code, this.name, this.durationDays, this.price, this.currency, this.featuresList, this.promoTextsList, this.active, this.updatedAt
  });

  DataList copyWith({
    String? id, String? code, String? name, num? durationDays, num? price, String? currency, List<
        String>? featuresList, List<
        String>? promoTextsList, bool? active, String? updatedAt
  }) =>
      DataList(id: id ?? this.id,
          code: code ?? this.code,
          name: name ?? this.name,
          durationDays: durationDays ?? this.durationDays,
          price: price ?? this.price,
          currency: currency ?? this.currency,
          featuresList: featuresList ?? this.featuresList,
          promoTextsList: promoTextsList ?? this.promoTextsList,
          active: active ?? this.active,
          updatedAt: updatedAt ?? this.updatedAt);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["code"] = code;
    map["name"] = name;
    map["durationDays"] = durationDays;
    map["price"] = price;
    map["currency"] = currency;
    map["features"] = featuresList;
    map["promoTexts"] = promoTextsList;
    map["active"] = active;
    map["updatedAt"] = updatedAt;
    return map;
  }

  DataList.fromJson(dynamic json) {
    id = json["id"];
    code = json["code"];
    name = json["name"];
    durationDays = json["durationDays"];
    price = json["price"];
    currency = json["currency"];
    featuresList =
    json["features"] != null ? json["features"].cast<String>() : [];
    promoTextsList =
    json["promoTexts"] != null ? json["promoTexts"].cast<String>() : [];
    active = json["active"];
    updatedAt = json["updatedAt"];
  }
}


class PlansModel {
  List<DataList>? dataListList;

  PlansModel({this.dataListList});

  PlansModel copyWith({List<DataList>? dataListList}) =>
      PlansModel(dataListList: dataListList ?? this.dataListList);

  // toJson endi Map emas, balki List qaytaradi
  List<dynamic> toJson() {
    if (dataListList != null) {
      return dataListList!.map((v) => v.toJson()).toList();
    }
    return [];
  }

  // fromJson aynan List qabul qiladi va to'g'ri o'qiydi
  PlansModel.fromJson(List<dynamic>? json) {
    if (json != null) {
      dataListList = [];
      for (var v in json) {
        dataListList!.add(DataList.fromJson(v));
      }
    }
  }
}