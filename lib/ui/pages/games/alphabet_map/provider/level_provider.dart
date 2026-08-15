import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../../core/storage/level_state.dart';

const String skinGold = 'assets/icons/gold.png';
const String skinSilver = 'assets/icons/silver.png';

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

  // Ma'lumotlarni vaqtincha faqat ro'yxatda (xotirada) saqlaymiz
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

  // Hive o'rniga JSON fayldan ma'lumotlarni yuklash
  Future<void> bootstrap() async {
    try {
      // JSON faylni o'qish
      final String jsonString = await rootBundle.loadString('assets/exsep.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      _levels = jsonData.map((data) {
        // Exercise ma'lumotlarini parse qilish
        ExerciseInfo? exerciseInfo;
        if (data['exercise'] != null) {
          var exData = data['exercise'];
          exerciseInfo = ExerciseInfo(
            modelPath: exData['modelPath'] ?? '',
            sound: exData['sound'] ?? '',
            mediaPath: exData['mediaPath'] ?? '',
            steps: (exData['steps'] as List<dynamic>?)?.map((step) => ExerciseStep(
              text: step['text'] ?? '',
              sound: step['sound'],
              action: step['action'] ?? '',
            )).toList() ?? [],
          );
        }

        // Game ma'lumotlarini parse qilish
        GameInfo? gameInfo;
        if (data['game'] != null) {
          var gData = data['game'];
          gameInfo = GameInfo(
            type: gData['type'] ?? '',
            // JSON ichidagi jsonConfig obyekt bo'lsa uni String'ga o'giramiz
            // (chunki oldingi kodingizda String sifatida berilgan edi)
            jsonConfig: gData['jsonConfig'] is Map
                ? json.encode(gData['jsonConfig'])
                : (gData['jsonConfig'] ?? '{}').toString(),
          );
        }

        return LevelState(
          id: data['id'],
          stars: data['stars'] ?? 0,
          locked: data['locked'] ?? true,
          skin: data['skin'] ?? skinSilver,
          mode: data['mode'] ?? 'game',
          exercise: exerciseInfo,
          game: gameInfo,
        );
      }).toList();

      // ID bo'yicha tartiblab qo'yamiz
      _levels.sort((a, b) => a.id.compareTo(b.id));

      if (kDebugMode) {
        print("✅ JSON fayldan ${_levels.length} ta level muvaffaqiyatli yuklandi");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ JSON o'qishda xatolik: $e");
      }
    }

    _fetchScoreFromBackend();
    notifyListeners();
  }

  // Endi to'g'ridan to'g'ri List ichidan qidiramiz
  LevelState? byId(int id) {
    try {
      return _levels.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> setStars(int id, int stars) async {
    final index = _levels.indexWhere((lv) => lv.id == id);
    if (index == -1) return;

    final lv = _levels[index];
    final clamped = stars.clamp(0, 3);

    if (clamped > lv.stars) {
      _levels[index] = lv.copyWith(stars: clamped);
      notifyListeners();
    }
  }

  Future<bool> unlock({int stars = 0}) async {
    final currentId = _currentPlayingLevelId;
    if (currentId == null) return false;

    final currentIndex = _levels.indexWhere((lv) => lv.id == currentId);
    if (currentIndex == -1) return false;

    final currentLevel = _levels[currentIndex];

    final clampedStars = stars.clamp(0, 3);
    final bestStars = clampedStars > currentLevel.stars ? clampedStars : currentLevel.stars;

    // 1. Joriy level yulduzlarini yangilaymiz (faqat listda)
    _levels[currentIndex] = currentLevel.copyWith(stars: bestStars);

    // 2. Keyingi levelni ochamiz
    final nextId = currentId + 1;
    final nextIndex = _levels.indexWhere((lv) => lv.id == nextId);

    if (nextIndex != -1) {
      final nextLevel = _levels[nextIndex];
      if (nextLevel.locked) {
        _levels[nextIndex] = nextLevel.copyWith(
            locked: false,
            skin: skinGold,
            stars: 0
        );
      }
    }

    notifyListeners();
    _syncLevelUnlockToBackend(currentId, bestStars);
    return true;
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

  void clearCurrentLevel() {
    _currentPlayingLevelId = null;
    notifyListeners();
  }

  // --- BACKEND FUNKSIYALARI ---
  Future<void> _syncScoreToBackend(int addedScore) async {}
  Future<void> _fetchScoreFromBackend() async {}
  Future<void> _syncLevelUnlockToBackend(int levelId, int stars) async {}
}