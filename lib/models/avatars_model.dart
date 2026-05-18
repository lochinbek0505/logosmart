class DataList {
  String? id;
  String? name;
  String? url;
  String? gender;

  DataList({
    this.id, this.name, this.url, this.gender
  });

  DataList copyWith({
    String? id, String? name, String? url, String? gender
  }) =>
      DataList(id: id ?? this.id,
          name: name ?? this.name,
          url: url ?? this.url,
          gender: gender ?? this.gender);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["name"] = name;
    map["url"] = url;
    map["gender"] = gender;
    return map;
  }

  DataList.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
    url = json["url"];
    gender = json["gender"];
  }
}

class AvatarsModel {
  List<DataList>? dataListList;

  AvatarsModel({
    this.dataListList
  });

  AvatarsModel copyWith({
    List<DataList>? dataListList
  }) => AvatarsModel(dataListList: dataListList ?? this.dataListList);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  AvatarsModel.fromJson(dynamic json) {
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(DataList.fromJson(v));
      });
    }
  }
}