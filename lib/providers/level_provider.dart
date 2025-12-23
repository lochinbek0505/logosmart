import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../core/storage/level_state.dart';

const String kLevelsBox = 'levelsBox';

const String skinGold = 'assets/icons/gold.png';
const String skinSilver = 'assets/icons/silver.png';

final List<LevelState> kDefaultLevels = [
  LevelState(
    id: 1,
    stars: 0,
    locked: false,
    skin: skinGold,
    mode: 'exercise',
    exercise: ExerciseInfo(
      modelPath: 'assets/models/model3.tflite',
      labelsPath: 'assets/models/labels.txt',
      mediaPath: 'assets/media/ong_chap.MP4',
      steps: [

        ExerciseStep(text: 'Tilni o\'nga chiqarib ko‘rsating', action: "ong"),
        ExerciseStep(text: 'Tilni chapga chiqarib ko‘rsating', action: 'chap'),
      ],
    ),
  ),
  LevelState(
    id: 2,
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'exercise',
    exercise: ExerciseInfo(
      modelPath: 'assets/models/ogiz_lab_tish.tflite',
      labelsPath: 'assets/models/labels_olt.txt',
      mediaPath: 'assets/media/ogiz_lab.MP4',
      steps: [
        ExerciseStep(
          text: "Qani ketdik, meni ortimdan mashqni bajar!",
          action: "about",
        ),
        ExerciseStep(text: 'Og‘zingizni keng oching', action: 'ogiz'),
        ExerciseStep(text: 'Lab harakatini bajaring', action: 'lab'),
        ExerciseStep(text: 'Og‘zingizni keng oching', action: 'ogiz'),
        ExerciseStep(text: 'Lab harakatini bajaring', action: 'lab'),
      ],
    ),
  ),
  LevelState(
    id: 3,
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'exercise',
    exercise: ExerciseInfo(
      modelPath: 'assets/models/ogiz_lab_tish.tflite',
      labelsPath: 'assets/models/labels_olt.txt',
      mediaPath: 'assets/media/tish_lab.MP4',
      steps: [
        ExerciseStep(
          text: "Qani ketdik, meni ortimdan mashqni bajar!",
          action: "about",
        ),
        ExerciseStep(text: 'Og‘zingizni ochib tishlarni ko\'rsating', action: 'tish'),
        ExerciseStep(text: 'Lab harakatini bajaring', action: 'lab'),
        ExerciseStep(text: 'Og‘zingizni ochib tishlarni ko\'rsating', action: 'tish'),
        ExerciseStep(text: 'Lab harakatini bajaring', action: 'lab'),
      ],
    ),
  ),
  LevelState(
    id: 3,
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'exercise',
    exercise: ExerciseInfo(
      modelPath: 'assets/models/ogiz_lab_tish.tflite',
      labelsPath: 'assets/models/labels_olt.txt',
      mediaPath: 'assets/media/tish_lab.MP4',
      steps: [
        ExerciseStep(
          text: "Qani ketdik, meni ortimdan mashqni bajar!",
          action: "about",
        ),
        ExerciseStep(text: 'Og‘zingizni ochib tishlarni ko\'rsating', action: 'tish'),
        ExerciseStep(text: 'Lab harakatini bajaring', action: 'lab'),
        ExerciseStep(text: 'Og‘zingizni ochib tishlarni ko\'rsating', action: 'tish'),
        ExerciseStep(text: 'Lab harakatini bajaring', action: 'lab'),
      ],
    ),
  ),

  for (int i = 5; i <= 18; i++)
    LevelState(
      id: i,
      stars: 0,
      locked: true,
      skin: skinSilver,
      mode: 'game',
      game: GameInfo(type: 'comingSoon', jsonConfig: '{}', objective: null),
    ),
];

typedef OpenLevelCallback = void Function(LevelState level);

class LevelProvider extends ChangeNotifier {
  LevelProvider({bool autoBootstrap = true}) {
    if (autoBootstrap) {
      // async chaqiruvni kechiktiramiz
      Future.microtask(bootstrap);
    }
  }

  late Box<LevelState> _box;

  List<LevelState> _levels = [];

  List<LevelState> get levels => _levels;

  OpenLevelCallback? onOpenLevel;

  /// Hive box'ni ochadi va defaultlarni (id → LevelState) bo'yicha joylaydi.
  Future<void> bootstrap() async {
    if (!Hive.isBoxOpen(kLevelsBox)) {
      _box = await Hive.openBox<LevelState>(kLevelsBox);
    } else {
      _box = Hive.box<LevelState>(kLevelsBox);
    }

    if (_box.isEmpty) {
      // id'ni key sifatida ishlatamiz (barqaror va putAt muammosiz)
      await _box.putAll({for (final lv in kDefaultLevels) lv.id: lv});
    } else {
      // Agar mavjud box dagi elementlar soni yoki id set'i mos kelmasa, sinxronlash:
      final existingIds = _box.keys.cast<int>().toSet();
      final defaultIds = kDefaultLevels.map((e) => e.id).toSet();
      if (existingIds.length != defaultIds.length ||
          !existingIds.containsAll(defaultIds)) {
        await _box.clear();
        await _box.putAll({for (final lv in kDefaultLevels) lv.id: lv});
      }
    }

    _levels = _readAllSorted();
    notifyListeners();
  }

  /// Box dagi barcha qiymatlarni id bo‘yicha sortlab qaytaradi.
  List<LevelState> _readAllSorted() {
    final list = _box.values.toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  LevelState? byId(int id) => _box.get(id);

  Future<void> setStars(int id, int stars) async {
    final lv = _box.get(id);
    if (lv == null) return;
    final clamped = stars.clamp(0, 3);
    final updated = lv.copyWith(stars: clamped);
    await _box.put(id, updated);
    _levels = _readAllSorted();
    notifyListeners();
  }

  Future<void> unlock(int id, int stars) async {
    final lv = _box.get(id);
    if (lv == null) return;
    final updated = lv.copyWith(locked: false, skin: skinGold, stars: stars);
    await _box.put(id, updated);
    _levels = _readAllSorted();
    notifyListeners();
  }

  Future<void> lock(int id) async {
    final lv = _box.get(id);
    if (lv == null) return;
    final updated = lv.copyWith(locked: true, skin: skinSilver);
    await _box.put(id, updated);
    _levels = _readAllSorted();
    notifyListeners();
  }

  Future<void> setSkin(int id, String skinPath) async {
    final lv = _box.get(id);
    if (lv == null) return;
    final updated = lv.copyWith(skin: skinPath);
    await _box.put(id, updated);
    _levels = _readAllSorted();
    notifyListeners();
  }

  /// -------------------- REJIM/MALUMOTLARNI YANGILASH --------------------

  Future<void> setMode(int id, String mode) async {
    assert(mode == 'game' || mode == 'exercise');
    final lv = _box.get(id);
    if (lv == null) return;

    LevelState updated = lv.copyWith(mode: mode);
    if (mode == 'game') {
      updated = updated.copyWith(
        game: lv.game ?? const GameInfo(type: 'comingSoon', jsonConfig: '{}'),
        exercise: null,
      );
    } else {
      updated = updated.copyWith(
        game: null,
        exercise:
            lv.exercise ??
            const ExerciseInfo(
              modelPath: '',
              labelsPath: '',
              steps: [],
              mediaPath: '',
            ),
      );
    }
    await _box.put(id, updated);
    _levels = _readAllSorted();
    notifyListeners();
  }

  Future<void> setGameInfo(int id, GameInfo info) async {
    final lv = _box.get(id);
    if (lv == null) return;
    final updated = lv.copyWith(mode: 'game', game: info, exercise: null);
    await _box.put(id, updated);
    _levels = _readAllSorted();
    notifyListeners();
  }

  Future<void> setExerciseInfo(int id, ExerciseInfo info) async {
    final lv = _box.get(id);
    if (lv == null) return;
    final updated = lv.copyWith(mode: 'exercise', exercise: info, game: null);
    await _box.put(id, updated);
    _levels = _readAllSorted();
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _box.clear();
    await _box.putAll({for (final lv in kDefaultLevels) lv.id: lv});
    _levels = _readAllSorted();
    notifyListeners();
  }

  /// Map sahifasidan bosilganda chaqiriladi.
  /// Tashqaridan `onOpenLevel` ni bog'lab qo'ying yoki bu metodni bevosita
  /// `Navigator` bilan to'ldiring.
  void openLevel(LevelState level) {
    if (level.locked) return;
    final cb = onOpenLevel;
    if (cb != null) {
      cb(level);
    } else {
      if (kDebugMode) {
        // Hozircha faqat log — UI navigatsiyani tashqarida bering.
        // Masalan: main.dart yoki MapRoadPage ochilganda:
        // context.read<LevelProvider>().onOpenLevel = (lv) => Navigator.push(...);
        print('openLevel: ${level.id} - ${level.mode}');
      }
    }
  }
}
