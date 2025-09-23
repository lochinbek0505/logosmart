import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../core/storage/level_state.dart';

const String kLevelsBox = 'levelsBox';

const String skinGold   = 'assets/icons/gold.png';
const String skinSilver = 'assets/icons/silver.png';

const List<LevelState> kDefaultLevels = [
  LevelState(id: 1,  stars: 0, locked: false, skin: skinGold),
  LevelState(id: 2,  stars: 3, locked: true, skin: skinSilver),
  LevelState(id: 3,  stars: 2, locked: true, skin: skinSilver),
  LevelState(id: 4,  stars: 3, locked: true, skin: skinSilver),
  LevelState(id: 5,  stars: 2, locked: true, skin: skinSilver),
  LevelState(id: 6,  stars: 1, locked: true, skin: skinSilver),
  LevelState(id: 7,  stars: 3, locked: true, skin: skinSilver),
  LevelState(id: 8,  stars: 0, locked: true, skin: skinSilver),
  LevelState(id: 9,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:10,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:11,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:12,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:13,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:14,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:15,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:16,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:17,  stars: 0, locked: true,  skin: skinSilver),
  LevelState(id:18,  stars: 0, locked: true,  skin: skinSilver),
];

class LevelProvider extends ChangeNotifier {
  late final Box<LevelState> _box;

  List<LevelState> _levels = [];
  List<LevelState> get levels => _levels;

  /// Hive box allaqachon ochilgandan keyin chaqiriladi (main.dart da)
  Future<void> bootstrap() async {
    _box = Hive.box<LevelState>(kLevelsBox);

    if (_box.isEmpty) {
      await _box.addAll(kDefaultLevels);
    } else {
      // Agar versiya o‘zgargan bo‘lib, soni mos kelmasa — soddaroq yo‘l:
      if (_box.length != kDefaultLevels.length) {
        await _box.clear();
        await _box.addAll(kDefaultLevels);
      }
    }

    _levels = _box.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    notifyListeners();
  }

  LevelState? byId(int id) {
    try {
      return _levels.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> setStars(int id, int stars) async {
    final idx = _levels.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final clamped = stars.clamp(0, 3);
    final updated = _levels[idx].copyWith(stars: clamped);
    await _putAt(idx, updated);
  }

  Future<void> unlock(int id) async {
    final idx = _levels.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final updated = _levels[idx].copyWith(locked: false);
    await _putAt(idx, updated);
  }

  Future<void> lock(int id) async {
    final idx = _levels.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final updated = _levels[idx].copyWith(locked: true);
    await _putAt(idx, updated);
  }

  Future<void> setSkin(int id, String skinPath) async {
    final idx = _levels.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final updated = _levels[idx].copyWith(skin: skinPath);
    await _putAt(idx, updated);
  }

  Future<void> resetAll() async {
    await _box.clear();
    await _box.addAll(kDefaultLevels);
    _levels = _box.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    notifyListeners();
  }

  Future<void> _putAt(int index, LevelState value) async {
    await _box.putAt(index, value);
    _levels[index] = value;
    notifyListeners();
  }
}
