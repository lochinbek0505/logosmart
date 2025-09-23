// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseStepAdapter extends TypeAdapter<ExerciseStep> {
  @override
  final int typeId = 71;

  @override
  ExerciseStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseStep(
      text: fields[0] as String,
      action: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseStep obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.action);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseInfoAdapter extends TypeAdapter<ExerciseInfo> {
  @override
  final int typeId = 72;

  @override
  ExerciseInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseInfo(
      modelPath: fields[0] as String,
      labelsPath: fields[1] as String,
      steps: (fields[2] as List).cast<ExerciseStep>(),
      mediaPath: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.modelPath)
      ..writeByte(1)
      ..write(obj.labelsPath)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.mediaPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameInfoAdapter extends TypeAdapter<GameInfo> {
  @override
  final int typeId = 73;

  @override
  GameInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameInfo(
      type: fields[0] as String,
      jsonConfig: fields[1] as String,
      objective: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GameInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.jsonConfig)
      ..writeByte(2)
      ..write(obj.objective);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LevelStateAdapterGen extends TypeAdapter<LevelState> {
  @override
  final int typeId = 7;

  @override
  LevelState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LevelState(
      id: fields[0] as int,
      stars: fields[1] as int,
      locked: fields[2] as bool,
      skin: fields[3] as String,
      mode: fields[4] as String,
      game: fields[5] as GameInfo?,
      exercise: fields[6] as ExerciseInfo?,
    );
  }

  @override
  void write(BinaryWriter writer, LevelState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.stars)
      ..writeByte(2)
      ..write(obj.locked)
      ..writeByte(3)
      ..write(obj.skin)
      ..writeByte(4)
      ..write(obj.mode)
      ..writeByte(5)
      ..write(obj.game)
      ..writeByte(6)
      ..write(obj.exercise);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelStateAdapterGen &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
