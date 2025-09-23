import 'dart:convert';
import 'package:hive/hive.dart';

part 'level_state.g.dart';

// -------------------- ExerciseStep (codegen adapter) --------------------
@HiveType(typeId: 71)
class ExerciseStep {
  @HiveField(0)
  final String text;   // ko'rsatma matni
  @HiveField(1)
  final String action; // harakat identifikatori

  const ExerciseStep({required this.text, required this.action});

  ExerciseStep copyWith({String? text, String? action}) =>
      ExerciseStep(text: text ?? this.text, action: action ?? this.action);

  Map<String, dynamic> toMap() => {'text': text, 'action': action};
  factory ExerciseStep.fromMap(Map<String, dynamic> map) =>
      ExerciseStep(text: map['text'] ?? '', action: map['action'] ?? '');
}

// -------------------- ExerciseInfo (codegen adapter) --------------------
@HiveType(typeId: 72)
class ExerciseInfo {
  @HiveField(0)
  final String modelPath;   // .tflite yo'li
  @HiveField(1)
  final String labelsPath;  // labels.txt yo'li
  @HiveField(2)
  final List<ExerciseStep> steps; // text + action ketma-ketligi
  @HiveField(3)
  final String mediaPath;
  const ExerciseInfo({
    required this.modelPath,
    required this.labelsPath,
    required this.steps,
    required this.mediaPath,
  });

  ExerciseInfo copyWith({
    String? modelPath,
    String? labelsPath,
    List<ExerciseStep>? steps,
    String? mediaPath,
  }) =>
      ExerciseInfo(
        modelPath: modelPath ?? this.modelPath,
        labelsPath: labelsPath ?? this.labelsPath,
        steps: steps ?? this.steps,
        mediaPath: mediaPath ?? this.mediaPath,
      );
}

// -------------------- GameInfo (codegen adapter) --------------------
@HiveType(typeId: 73)
class GameInfo {
  @HiveField(0)
  final String type; // o'yin turi (mas: "tapRunner", "balloonPop")
  @HiveField(1)
  final String jsonConfig; // arbitrary JSON (string)
  @HiveField(2)
  final String? objective; // ixtiyoriy maqsad/ta'rif

  const GameInfo({
    required this.type,
    required this.jsonConfig,
    this.objective,
  });

  GameInfo copyWith({
    String? type,
    String? jsonConfig,
    String? objective,
  }) =>
      GameInfo(
        type: type ?? this.type,
        jsonConfig: jsonConfig ?? this.jsonConfig,
        objective: objective ?? this.objective,
      );

  Map<String, dynamic> configAsMap() {
    try {
      return jsonDecode(jsonConfig) as Map<String, dynamic>;
    } catch (_) {
      return const {};
    }
  }
}

// -------------------- LevelState --------------------
// E’TIBOR: adapterName berildi, shuning uchun generator
// LevelStateAdapter O‘RNIGA LevelStateAdapterGen yaratadi.
@HiveType(typeId: 7, adapterName: 'LevelStateAdapterGen')
class LevelState {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int stars; // 0..3
  @HiveField(2)
  final bool locked;
  @HiveField(3)
  final String skin; // asset path

  /// 'game' yoki 'exercise'
  @HiveField(4)
  final String mode;

  /// mode == 'game' bo'lsa to'ldiriladi
  @HiveField(5)
  final GameInfo? game;

  /// mode == 'exercise' bo'lsa to'ldiriladi
  @HiveField(6)
  final ExerciseInfo? exercise;

  const LevelState({
    required this.id,
    required this.stars,
    required this.locked,
    required this.skin,
    required this.mode,
    this.game,
    this.exercise,
  });

  LevelState copyWith({
    int? stars,
    bool? locked,
    String? skin,
    String? mode,
    GameInfo? game,
    ExerciseInfo? exercise,
  }) {
    return LevelState(
      id: id,
      stars: stars ?? this.stars,
      locked: locked ?? this.locked,
      skin: skin ?? this.skin,
      mode: mode ?? this.mode,
      game: game ?? this.game,
      exercise: exercise ?? this.exercise,
    );
  }
}

/// Qo'lda yozilgan adapter (typeId = 7).
/// Eski yozuvlarda yangi maydonlar bo'lmasa ham xatosiz ochiladi.
class LevelStateAdapter extends TypeAdapter<LevelState> {
  @override
  final int typeId = 7;

  @override
  LevelState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Eski yozuvlar uchun defaultlar
    final int id      = fields[0] as int? ?? 0;
    final int stars   = (fields[1] as int? ?? 0).clamp(0, 3);
    final bool locked = fields[2] as bool? ?? true;
    final String skin = fields[3] as String? ?? 'assets/icons/silver.png';

    String mode = fields[4] as String? ?? 'game';
    if (mode != 'game' && mode != 'exercise') {
      mode = 'game';
    }

    final GameInfo? game = fields[5] as GameInfo?;
    final ExerciseInfo? exercise = fields[6] as ExerciseInfo?;

    return LevelState(
      id: id,
      stars: stars,
      locked: locked,
      skin: skin,
      mode: mode,
      game: mode == 'game' ? game : null,
      exercise: mode == 'exercise' ? exercise : null,
    );
  }

  @override
  void write(BinaryWriter writer, LevelState obj) {
    writer
      ..writeByte(7) // maydonlar soni
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.stars.clamp(0, 3))
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
}
