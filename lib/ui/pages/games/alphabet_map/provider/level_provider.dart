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
    skin: skinSilver,
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
  for (int i = 4; i <= 70; i++)
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
      Future.microtask(bootstrap);
    }
  }

  int _ball = 0;

  int get ball => _ball;

  // Joriy o'ynalayotgan/ochilgan bosqichning ID si
  int? _currentPlayingLevelId;

  int? get currentPlayingLevelId => _currentPlayingLevelId;

  late Box<LevelState> _box;
  List<LevelState> _levels = [];

  List<LevelState> get levels => _levels;

  OpenLevelCallback? onOpenLevel;

  void addBall(int value) {
    _ball += value;
    notifyListeners();
    _syncScoreToBackend(value); // TO-DO: Backend funksiyasini chaqirish
  }

  // Joriy oynalayotgan bosqichni belgilash (Sahifaga o'tayotganda chaqiriladi)
  void setCurrentLevel(int id) {
    _currentPlayingLevelId = id;
    notifyListeners();
  }

  // Joriy bosqichning to'liq ob'ektini olish
  LevelState? get currentLevelData {
    if (_currentPlayingLevelId == null) return null;
    return byId(_currentPlayingLevelId!);
  }

  Future<void> bootstrap() async {
    if (!Hive.isBoxOpen(kLevelsBox)) {
      _box = await Hive.openBox<LevelState>(kLevelsBox);
    } else {
      _box = Hive.box<LevelState>(kLevelsBox);
    }

    if (_box.isEmpty) {
      await _box.putAll({for (final lv in kDefaultLevels) lv.id: lv});
    } else {
      final existingIds = _box.keys.cast<int>().toSet();
      final defaultIds = kDefaultLevels.map((e) => e.id).toSet();
      if (existingIds.length != defaultIds.length ||
          !existingIds.containsAll(defaultIds)) {
        await _box.clear();
        await _box.putAll({for (final lv in kDefaultLevels) lv.id: lv});
      }
    }

    _levels = _readAllSorted();
    _fetchScoreFromBackend(); // TO-DO: Serverdan boshlang'ich ballni olish
    notifyListeners();
  }

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

  // unlock funksiyasi endi parametr sifatida joriy levelni yoki kelgusi levelni qabul qilishi ham mumkin
  Future<bool> unlock({int stars = 0}) async {
    // Eng birinchi bloklangan levelni topish va shuni ochish
    final lockedLevel = levels.firstWhere(
      (e) => e.locked,
      orElse: () => levels.last,
    );

    var id = lockedLevel.id;
    final lv = _box.get(id);
    if (lv == null) return false;

    if (id < _levels.length) {
      final updated = lv.copyWith(locked: false, skin: skinGold, stars: 0);
      final update2 = lv.copyWith(id:id - 1 >= 0 ? id - 1 : 0,locked: false, skin: skinGold, stars: stars);
      await _box.put(id - 1 >= 0 ? id - 1 : 0, update2);
      await _box.put(id, updated);
      _levels = _readAllSorted();
      notifyListeners();

      // TO-DO: Ochilgan yangi levelni serverga yuborish
      _syncLevelUnlockToBackend(id, stars);
      return true;
    }
    return false;
  }

  // --- TO-DO: BACKEND INTEGRATSIYASI UCHUN SHABLON FUNKSIYALAR ---

  /// Backendga qo'shilgan ballni yuborish (Sinxronizatsiya)
  Future<void> _syncScoreToBackend(int addedScore) async {
    // TODO: REST API yuborish. Masalan:
    // try {
    //   await http.post(Uri.parse('https://api.yoursite.com/update_score'), body: {'score': addedScore});
    // } catch (e) {
    //   print(e);
    // }
  }

  /// Ilova yonganda backenddan foydalanuvchining umumiy ballini olish
  Future<void> _fetchScoreFromBackend() async {
    // TODO: REST API dan ballni olish. Masalan:
    // try {
    //   final response = await http.get(Uri.parse('https://api.yoursite.com/get_score'));
    //   // Parsing va assign
    //   // _ball = parsedValue;
    //   // notifyListeners();
    // } catch (e) {
    //   print(e);
    // }
  }

  /// Qaysi level ochilganini va necha yulduz olinganini serverga aytib qo'yish
  Future<void> _syncLevelUnlockToBackend(int levelId, int stars) async {
    // TODO: Bosqich yutuqlarini serverga saqlash
    // try {
    //   await http.post(Uri.parse('https://api.yoursite.com/unlock_level'), body: {
    //     'level_id': levelId.toString(),
    //     'stars': stars.toString()
    //   });
    // } catch (e) {
    //   print(e);
    // }
  }

  void openLevel(LevelState level) {
    if (level.locked) return;
    setCurrentLevel(level.id);
    final cb = onOpenLevel;
    if (cb != null) {
      cb(level);
    } else {
      if (kDebugMode) {
        print('openLevel: ${level.id} - ${level.mode}');
      }
    }
  }
}
