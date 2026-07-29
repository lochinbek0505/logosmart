import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../../../core/storage/level_state.dart';

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
      modelPath: 'assets/models/ochtp.tflite',
      labelsPath: 'assets/models/labels.txt',
      mediaPath: 'assets/videos/models/ong_chap.mp4',
      steps: [
        ExerciseStep(
          text: "Iltimos berilgan mashqlarni 3 martadan qayta bajaring",
          action: "about",
        ),

        ExerciseStep(text: 'Tilni o\'nga chiqarib ko‘rsating', action: "ong"),

        ExerciseStep(text: 'Tilni chapga chiqarib ko‘rsating', action: "chap"),
      ],
    ),
  ),
  LevelState(
    id: 2,
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "breath",
      jsonConfig: """{
    "start_voice":"assets/sound/breath/breath_start.mp3",
        "blow_voice":"assets/sound/breath/butterfly.mp3",
        "lottie_animation":"assets/animation/breath/butterfly.json",
        "background_image":"assets/backround/breath/butterfly_background.jpg",
        "icon_star":"assets/icons/star.png",
        "icon_arrow":"assets/icons/arrow_right_button.png",
        "animation_position":-1.2
    }""",
    ),
  ),
  LevelState(
    id: 3,
    stars: 0,
    locked: true,
    skin: skinGold,
    mode: 'exercise',
    exercise: ExerciseInfo(
      modelPath: 'assets/models/ogiz_lab_tish.tflite',
      labelsPath: 'assets/models/labels.txt',
      mediaPath: 'assets/videos/models/tish_lab.mp4',
      steps: [
        ExerciseStep(
          text: "Iltimos berilgan mashqlarni 3 martadan qayta bajaring",
          action: "about",
        ),

        ExerciseStep(text: 'Iltimos tishni ko‘rsating', action: "tish"),
        ExerciseStep(text: 'Iltimos labni ko‘rsating', action: "lab"),

      ],
    ),
  ),

  // LevelState(
  //   id: 4,
  //   stars: 0,
  //   locked: true,
  //   skin: skinSilver,
  //   mode: 'exercise',
  //   exercise: ExerciseInfo(
  //     modelPath: 'assets/models/ogiz_lab_tish.tflite',
  //     labelsPath: 'assets/models/labels_olt.txt',
  //     mediaPath: 'assets/media/tish_lab.MP4',
  //     steps: [
  //
  //       ExerciseStep(
  //         text: 'Og‘zingizni ochib tishlarni ko\'rsating',
  //         action: 'tish',
  //       ),
  //       ExerciseStep(text: 'Lab harakatini bajaring', action: 'lab'),
  //       ExerciseStep(
  //         text: 'Og‘zingizni ochib tishlarni ko\'rsating',
  //         action: 'tish',
  //       ),
  //       ExerciseStep(text: 'Lab harakatini bajaring', action: 'lab'),
  //     ],
  //   ),
  // ),
  for (int i = 4; i <= 18; i++)
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

  Future<bool> unlock({int stars = 0}) async {
    final locked = levels.firstWhere(
      (e) => e.locked,
      orElse: () => levels.last,
    );
    var id = locked.id;
    final lv = _box.get(id);
    if (lv == null) false;
    if (id < 4) {
      print("Locked id $id");
      print("List id ${kDefaultLevels.length}");

      final updated = lv!.copyWith(locked: false, skin: skinGold, stars: stars);
      await _box.put(id, updated);
      _levels = _readAllSorted();
      notifyListeners();
      return true;
    }
    return false;
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
