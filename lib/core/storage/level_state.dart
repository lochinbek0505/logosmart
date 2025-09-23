import 'package:hive/hive.dart';

part 'level_state.g.dart'; // agar codegen ishlatmasangiz, bu qatorni o'chiring

/// levelData o‘rniga Hive’da saqlanadigan minimal holat:
/// Pozitsiyalar (dx, dy) runtime’da generatePositions() orqali hisoblanadi.
@HiveType(typeId: 7)
class LevelState {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int stars;

  @HiveField(2)
  final bool locked;

  @HiveField(3)
  final String skin;

  const LevelState({
    required this.id,
    required this.stars,
    required this.locked,
    required this.skin,
  });

  LevelState copyWith({int? stars, bool? locked, String? skin}) {
    return LevelState(
      id: id,
      stars: stars ?? this.stars,
      locked: locked ?? this.locked,
      skin: skin ?? this.skin,
    );
  }
}
