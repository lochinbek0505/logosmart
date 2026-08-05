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
  LevelState(
    id: 4, // Yoki o'zingizga kerakli id
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "arrow",
      jsonConfig: """{
      "start_voice": "assets/sound/arrow/arrow_start.mp3",
      "background_image": "assets/backround/arrow/arrow_back_1.jpg",
      "icon_star": "assets/icons/star.png",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "icon_mic": "assets/icons/micrafon.png",
      "center_letter": "R",
      "outer_nodes": [
        {
          "id": 0,
          "letter": "A",
          "color": "0xFFFFA726",
          "angle": -180.0,
          "sound": "assets/sound/arrow/ar.mp3",
          "target_text": "aarr"
        },
        {
          "id": 1,
          "letter": "O",
          "color": "0xFF43A047",
          "angle": -90.0,
          "sound": "assets/sound/arrow/or.mp3",
          "target_text": "oorr"
        },
        {
          "id": 2,
          "letter": "U",
          "color": "0xFFEC407A",
          "angle": 0.0,
          "sound": "assets/sound/arrow/ur.mp3",
          "target_text": "uurr"
        },
        {
          "id": 4,
          "letter": "E",
          "color": "0xFF7FD8F7",
          "angle": 90.0,
          "sound": "assets/sound/arrow/er.mp3",
          "target_text": "ERRR"
        }
      ]
    }""",
    ),
  ),
  LevelState(
    id: 5, // O'zingizga kerakli id
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "cloud",
      jsonConfig: """{
      "start_voice": "assets/sound/find_image/game_1_start.mp3",
      "success_sound": "assets/sound/success.mp3",
      "incorrect_sound": "assets/sound/diagnostic_error.mp3",
      "background_image": "assets/backround/fon_q.png",
      "icon_star": "assets/icons/star.png",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "icon_mic": "assets/icons/micrafon.png",
      "helicopter_image": "assets/game/cloud_game/helicopter.png",
      "cloud_image": "assets/game/cloud_game/cloud.png",
      "clouds": [
        {"id": 1, "text": "ar", "music": "assets/sound/cloud_game/ar.mp3"},
        {"id": 2, "text": "ir", "music": "assets/sound/cloud_game/ir.mp3"},
        {"id": 3, "text": "ur", "music": "assets/sound/cloud_game/ur.mp3"},
        {"id": 4, "text": "er", "music": "assets/sound/cloud_game/er.mp3"},
        {"id": 5, "text": "re", "music": "assets/sound/cloud_game/re.mp3"},
        {"id": 6, "text": "or", "music": "assets/sound/cloud_game/or.mp3"},
        {"id": 7, "text": "ru", "music": "assets/sound/cloud_game/ru.mp3"},
        {"id": 8, "text": "ro", "music": "assets/sound/cloud_game/ro.mp3"},
        {"id": 9, "text": "ri", "music": "assets/sound/cloud_game/ri.mp3"},
        {"id": 10, "text": "ra", "music": "assets/sound/cloud_game/ra.mp3"}
      ]
    }""",
    ),
  ),
  LevelState(
    id: 6, // O'zingizga moslashtirasiz
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "cooking",
      jsonConfig: """{
      "start_voice": "assets/sound/cooking/cooking_start.mp3",
      "success_sound": "assets/sound/success.mp3",
      "bg_image": "assets/backround/cooking/cooking.png",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "icon_star": "assets/icons/star.png",
      "icon_mic": "assets/icons/micrafon.png",
      "chef_image": "assets/game/cooking/chef_girl.png",
      "products": [
        {"id": "soup", "asset": "assets/game/cooking/shorva.png", "text": "sho'rva", "sound": "assets/sound/cooking/shorva.mp3", "x": 220, "y": 550},
        {"id": "tomato", "asset": "assets/game/cooking/pamidor.png", "text": "pamidor", "sound": "assets/sound/cooking/pamidor.mp3", "x": 40, "y": 520},
        {"id": "cucumber", "asset": "assets/game/cooking/bodring.png", "text": "bodring", "sound": "assets/sound/cooking/bodring.mp3", "x": 130, "y": 420},
        {"id": "radish", "asset": "assets/game/cooking/rediska.png", "text": "rediska", "sound": "assets/sound/cooking/rediska.mp3", "x": 230, "y": 320},
        {"id": "pomegranate", "asset": "assets/game/cooking/anor.png", "text": "anor", "sound": "assets/sound/cooking/anor.mp3", "x": 220, "y": 200}
      ]
    }""",
    ),
  ),
  LevelState(
    id: 7, // O'zingizga kerakli id ni bering
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "drag_drop",
      jsonConfig: """{
      "bg_color": "0xFFF4F6F9",
      "success_sound": "assets/sound/success.mp3",
      "icon_star": "assets/icons/star.png",
      "avatar_bg": "assets/icons/circle.png",
      "avatar_image": "assets/icons/circle_bad.png",
      "items": [
        {"id": "pepper", "image": "assets/game/yellow_pepper.png"},
        {"id": "tomato", "image": "assets/game/tomato.png"},
        {"id": "eggplant", "image": "assets/game/eggplant.png"},
        {"id": "cucumber", "image": "assets/game/cucumber.png"}
      ]
    }""",
    ),
  ),
  LevelState(
    id: 8, // O'zingizga kerakli id
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "find_image_page", // MapRoadPage'da navigationTo ichida qanday nomlagan bo'lsangiz
      jsonConfig: """{
      "start_voice": "assets/sound/find_image/game_1_start.mp3",
      "success_sound": "assets/sound/success.mp3",
      "incorrect_sound": "assets/sound/diagnostic_error.mp3",
      "background_image": "assets/backround/fon_q.png",
      "icon_star": "assets/icons/star.png",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "icon_mic": "assets/icons/micrafon.png",
      "items": [
        {
          "image": "assets/game/find_image/ari.png",
          "sound": "assets/sound/find_image/ari.mp3",
          "text": "ari",
          "isCorrect": true
        },
        {
          "image": "assets/game/find_image/pasha.png",
          "sound": "assets/sound/find_image/pashsha.mp3",
          "text": "pashsha",
          "isCorrect": false
        },
        {
          "image": "assets/game/find_image/ninachi.png",
          "sound": "assets/sound/find_image/ninachi.mp3",
          "text": "ninachi",
          "isCorrect": false
        },
        {
          "image": "assets/game/find_image/qongiz.png",
          "sound": "assets/sound/find_image/qongiz.mp3",
          "text": "qo'ng'iz",
          "isCorrect": false
        }
      ]
    }""",
    ),
  ),
  LevelState(
    id: 9, // O'zingizga kerakli id
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "hand_game", // MapRoadPage dagi navigationTo dagi nom
      jsonConfig: """{
      "start_voice": "assets/sound/hand_game/hand_game_start.mp3",
      "success_sound": "assets/sound/success.mp3",
      "background_image": "assets/backround/fon_q.png",
      "icon_star": "assets/icons/star.png",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "items": [
        {
          "box_image": "assets/game/hand_game/box_1.png",
          "hand_image": "assets/game/hand_game/hand_1.png"
        },
        {
          "box_image": "assets/game/hand_game/box_2.png",
          "hand_image": "assets/game/hand_game/hand_2.png"
        },
        {
          "box_image": "assets/game/hand_game/box_3.png",
          "hand_image": "assets/game/hand_game/face_1.png"
        },
        {
          "box_image": "assets/game/hand_game/box_4.png",
          "hand_image": "assets/game/hand_game/lib_3.png"
        }
      ]
    }""",
    ),
  ),
  LevelState(
    id: 10, // O'zingizga kerakli id
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "path_game", // MapRoadPage'da qanday nomlangan bo'lsa shunday
      jsonConfig: """{
      "start_voice": "assets/sound/paint/paint_start.mp3",
      "item_sound": "assets/sound/paint/RRRRA.mp3",
      "error_sound": "assets/sound/paint/paint_end.mp3",
      "success_sound": "assets/sound/success.mp3",
      "image": "assets/game/paint/tiger.png",
      "target_text": "rrrra",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "icon_star": "assets/icons/star.png",
      "icon_mic": "assets/icons/micrafon.png",
      "path_config": {
        "startPoint": {"x": 0.15, "y": 0.9},
        "segments": [
          {
            "cp1": {"x": 1.5, "y": 0.7},
            "cp2": {"x": -0.5, "y": 0.3},
            "endPoint": {"x": 0.8, "y": 0}
          }
        ]
      }
    }""",
    ),
  ),
  LevelState(
    id: 11, // O'zingizga kerakli id ni bering
    stars: 0,
    locked: true,
    skin: skinSilver,
    mode: 'game',
    game: GameInfo(
      type: "puzzle_game", // MapRoadPage'dagi navigationTo da qanday bo'lsa shunday
      jsonConfig: """{
      "start_voice": "assets/sound/puzzle_game/puzzle_start_1.mp3",
      "success_sound": "assets/sound/success.mp3",
      "error_sound": "assets/sound/diagnostic_error.mp3",
      "background_image": "assets/backround/puzzle_game/puzzle_back_4.jpg",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "icon_star": "assets/icons/star.png",
      "puzzle_frame": "assets/game/puzzle_game/puzzle.png",
      "correct_anim": "assets/animation/correct.json",
      "incorrect_anim": "assets/animation/xato.json",
      "pieces": [
        {
          "id": "t1",
          "pairId": 1,
          "color": "0xFFFFFFFF",
          "isTop": true,
          "side": "left",
          "image": "assets/game/puzzle_game/puzzle_1_game_3.png",
          "sound": "assets/sound/puzzle_game/ari.mp3"
        },
        {
          "id": "t2",
          "pairId": 2,
          "color": "0xFFFFFFFF",
          "isTop": true,
          "side": "right",
          "image": "assets/game/puzzle_game/puzzle_1_game_4.png",
          "sound": "assets/sound/puzzle_game/daraxt.mp3"
        },
        {
          "id": "b1",
          "pairId": 2,
          "color": "0xFFFFFFFF",
          "isTop": false,
          "side": "left",
          "image": "assets/game/puzzle_game/puzzle_1_game_1.png",
          "sound": "assets/sound/puzzle_game/daraxtlar.mp3"
        },
        {
          "id": "b2",
          "pairId": 1,
          "color": "0xFFFFFFFF",
          "isTop": false,
          "side": "right",
          "image": "assets/game/puzzle_game/puzzle_1_game_2.png",
          "sound": "assets/sound/puzzle_game/arilar.mp3"
        }
      ]
    }""",
    ),
  ),
  for (int i = 12; i <= 70; i++)
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

  int? _currentPlayingLevelId;
  int? get currentPlayingLevelId => _currentPlayingLevelId;

  late Box<LevelState> _box;
  List<LevelState> _levels = [];
  List<LevelState> get levels => _levels;

  OpenLevelCallback? onOpenLevel;

  void addBall(int value) {
    _ball += value;
    notifyListeners();
    _syncScoreToBackend(value);
  }

  void setCurrentLevel(int id) {
    _currentPlayingLevelId = id;
    notifyListeners();
  }

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
    _fetchScoreFromBackend();
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

    // Yulduzlar faqat oldingisidan ko'p bo'lsa yangilanadi (masalan, avval 2 ta olib, endi 3 ta olsa)
    final clamped = stars.clamp(0, 3);
    if (clamped > lv.stars) {
      final updated = lv.copyWith(stars: clamped);
      await _box.put(id, updated);
      _levels = _readAllSorted();
      notifyListeners();
    }
  }

  /// O'yin tugaganda chaqiriladigan asosiy funksiya
  Future<bool> unlock({int stars = 0}) async {
    // 1. Biz joriy o'ynalayotgan level ID sini olishimiz kerak
    final currentId = _currentPlayingLevelId;
    if (currentId == null) return false;

    final currentLevel = _box.get(currentId);
    if (currentLevel == null) return false;

    // 2. Joriy level uchun yulduzlarni yangilaymiz (agar yangi yulduz ko'proq bo'lsa)
    final clampedStars = stars.clamp(0, 3);
    final bestStars = clampedStars > currentLevel.stars ? clampedStars : currentLevel.stars;

    final updatedCurrent = currentLevel.copyWith(stars: bestStars);
    await _box.put(currentId, updatedCurrent);

    // 3. Keyingi levelni topib uni qulfdan chiqaramiz
    final nextId = currentId + 1;
    final nextLevel = _box.get(nextId);

    if (nextLevel != null && nextLevel.locked) {
      final updatedNext = nextLevel.copyWith(
          locked: false,
          skin: skinGold, // Ochiq level skini
          stars: 0
      );
      await _box.put(nextId, updatedNext);
    }

    // State'ni yangilash
    _levels = _readAllSorted();
    notifyListeners();

    // TO-DO: Serverga yuborish
    _syncLevelUnlockToBackend(currentId, bestStars);
    return true;
  }

  void openLevel(LevelState level) {
    if (level.locked) return;
    setCurrentLevel(level.id); // <- Bu yerda State o'zgaryapti

    final cb = onOpenLevel;
    if (cb != null) {
      cb(level);
    } else {
      if (kDebugMode) {
        print('openLevel: ${level.id} - ${level.mode}');
      }
    }
  }

  // O'yindan chiqilganda current ID ni tozalab qoyish tavsiya qilinadi
  void clearCurrentLevel() {
    _currentPlayingLevelId = null;
    notifyListeners();
  }

  // --- BACKEND FUNKSIYALARI ---
  Future<void> _syncScoreToBackend(int addedScore) async {}
  Future<void> _fetchScoreFromBackend() async {}
  Future<void> _syncLevelUnlockToBackend(int levelId, int stars) async {}
}