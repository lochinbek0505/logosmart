class TemplateItem {
  String? id;
  String? url;
  String? sound;
  String? promptText;
  num? orderNo;

  TemplateItem({
    this.id, this.url, this.sound, this.promptText, this.orderNo
  });

  TemplateItem copyWith({
    String? id, String? url, String? sound, String? promptText, num? orderNo
  }) =>
      TemplateItem(id: id ?? this.id,
          url: url ?? this.url,
          sound: sound ?? this.sound,
          promptText: promptText ?? this.promptText,
          orderNo: orderNo ?? this.orderNo);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["url"] = url;
    map["sound"] = sound;
    map["promptText"] = promptText;
    map["orderNo"] = orderNo;
    return map;
  }

  TemplateItem.fromJson(dynamic json) {
    id = json["id"];
    url = json["url"];
    sound = json["sound"];
    promptText = json["promptText"];
    orderNo = json["orderNo"];
  }
}

class Template {
  String? id;
  String? title;
  String? description;
  bool? active;
  List<TemplateItem>? itemsList;
  String? createdAt;

  Template({
    this.id, this.title, this.description, this.active, this.itemsList, this.createdAt
  });

  Template copyWith({
    String? id, String? title, String? description, bool? active, List<
        TemplateItem>? itemsList, String? createdAt
  }) =>
      Template(id: id ?? this.id,
          title: title ?? this.title,
          description: description ?? this.description,
          active: active ?? this.active,
          itemsList: itemsList ?? this.itemsList,
          createdAt: createdAt ?? this.createdAt);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["title"] = title;
    map["description"] = description;
    map["active"] = active;
    if (itemsList != null) {
      map["items"] = itemsList?.map((v) => v.toJson()).toList();
    }
    map["createdAt"] = createdAt;
    return map;
  }

  Template.fromJson(dynamic json) {
    id = json["id"];
    title = json["title"];
    description = json["description"];
    active = json["active"];
    if (json["items"] != null) {
      itemsList = [];
      json["items"].forEach((v) {
        itemsList?.add(TemplateItem.fromJson(v));
      });
    }
    createdAt = json["createdAt"];
  }
}

class DiagnosticGroup {
  String? id;
  String? name;
  String? description;
  List<Template>? templatesList;
  String? createdAt;

  DiagnosticGroup({
    this.id, this.name, this.description, this.templatesList, this.createdAt
  });

  DiagnosticGroup copyWith({
    String? id, String? name, String? description, List<
        Template>? templatesList, String? createdAt
  }) =>
      DiagnosticGroup(id: id ?? this.id,
          name: name ?? this.name,
          description: description ?? this.description,
          templatesList: templatesList ?? this.templatesList,
          createdAt: createdAt ?? this.createdAt);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["id"] = id;
    map["name"] = name;
    map["description"] = description;
    if (templatesList != null) {
      map["templates"] = templatesList?.map((v) => v.toJson()).toList();
    }
    map["createdAt"] = createdAt;
    return map;
  }

  DiagnosticGroup.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
    description = json["description"];
    if (json["templates"] != null) {
      templatesList = [];
      json["templates"].forEach((v) {
        templatesList?.add(Template.fromJson(v));
      });
    }
    createdAt = json["createdAt"];
  }
}

class DiagnosticGroupModel {
  List<DiagnosticGroup>? dataListList;

  DiagnosticGroupModel({
    this.dataListList
  });

  DiagnosticGroupModel copyWith({
    List<DiagnosticGroup>? dataListList
  }) => DiagnosticGroupModel(dataListList: dataListList ?? this.dataListList);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  DiagnosticGroupModel.fromJson(dynamic json) {
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(DiagnosticGroup.fromJson(v));
      });
    }
  }
}