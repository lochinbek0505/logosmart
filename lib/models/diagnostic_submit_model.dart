import 'dart:convert';


class DiagnosticSubmitModel {
  final String? id;
  final String? userId;
  final String? submittedAt;
  final num? totalPercent;
  final List<SoundItem>? sounds;

  DiagnosticSubmitModel({
    this.id,
    this.userId,
    this.submittedAt,
    this.totalPercent,
    this.sounds,
  });

  factory DiagnosticSubmitModel.fromJson(dynamic json) {
    return DiagnosticSubmitModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      submittedAt: json['submittedAt'] as String?,
      totalPercent: json['totalPercent'] as num?,
      sounds: json['sounds'] != null
          ? (json['sounds'] as List).map((v) => SoundItem.fromJson(v)).toList()
          : null,
    );
  }

  DiagnosticSubmitModel copyWith({
    String? id,
    String? userId,
    String? submittedAt,
    num? totalPercent,
    List<SoundItem>? sounds,
  }) =>
      DiagnosticSubmitModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        submittedAt: submittedAt ?? this.submittedAt,
        totalPercent: totalPercent ?? this.totalPercent,
        sounds: sounds ?? this.sounds,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['userId'] = userId;
    map['submittedAt'] = submittedAt;
    map['totalPercent'] = totalPercent;
    if (sounds != null) {
      map['sounds'] = sounds!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}


class SoundItem {
  final String? sound;
  final num? percent;
  final String? note;

  SoundItem({
    this.sound,
    this.percent,
    this.note,
  });

  factory SoundItem.fromJson(dynamic json) {
    return SoundItem(
      sound: json['sound'] as String?,
      percent: json['percent'] as num?,
      note: json['note'] as String?,
    );
  }

  SoundItem copyWith({
    String? sound,
    num? percent,
    String? note,
  }) =>
      SoundItem(
        sound: sound ?? this.sound,
        percent: percent ?? this.percent,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sound'] = sound;
    map['percent'] = percent;
    map['note'] = note;
    return map;
  }
}