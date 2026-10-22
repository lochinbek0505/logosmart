import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../../../../core/storage/level_state.dart';

const String skinGold = 'assets/icons/gold.webp';
const String skinSilver = 'assets/icons/silver.webp';

/// Levellar progressi (ochilgan levellar va yulduzlar) saqlanadigan Hive box.
/// main() da ochiladi.
const String kLevelProgressBox = 'level_progress';

/// Progress box ichida oxirgi ochilgan tovush xaritasi saqlanadigan kalit
const String _kLastSoundKey = '_last_sound';

/// O'yinlar xaritasi qulflanganidan keyingi bir martalik migratsiya belgisi
const String _kGamesLockMigratedKey = '_games_lock_migrated_v1';

typedef OpenLevelCallback = void Function(LevelState level);

/// Bosh sahifadagi "So'ngi harakat" kartasi uchun ma'lumot
class LastActivity {
  const LastActivity({
    required this.sound,
    required this.currentLevelId,
    required this.levelNumber,
    required this.totalLevels,
    required this.completedLevels,
  });

  final String sound;

  /// Bola kelib qolgan (eng oxirgi ochilgan) level
  final int currentLevelId;

  /// Xaritadagi tartib raqami (1 dan boshlanadi)
  final int levelNumber;
  final int totalLevels;
  final int completedLevels;

  double get progress =>
      totalLevels == 0 ? 0 : (completedLevels / totalLevels).clamp(0.0, 1.0);
}

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

  /// O'yinlar bo'limi xaritasi (hamma o'yinlar bitta joyda, ketma-ket ochiladi)
  static const String gamesSound = 'GAMES';

  /// "Ilk nutqni rivojlantirish" bo'limi xaritalari (har biri alohida progress)
  static const String firstSpeechArticulation = 'FS_ARTIKULATSION';
  static const String firstSpeechBreath = 'FS_NAFAS';
  static const String firstSpeechFinger = 'FS_BARMOQ';
  static const String firstSpeechLine = 'FS_CHIZIQ';

  // Har bir tovush o'z level fayliga ega
  static const Map<String, String> soundLevelFiles = {
    'R': 'assets/exsepR.json',
    'L': 'assets/exsep.json',
    'S': 'assets/exsepS.json',
    gamesSound: 'assets/games.json',
    firstSpeechArticulation: 'assets/first_speech/artikulatsion.json',
    firstSpeechBreath: 'assets/first_speech/nafas.json',
    firstSpeechFinger: 'assets/first_speech/barmoq.json',
    firstSpeechLine: 'assets/first_speech/chiziq.json',
  };

  /// Tovush (harf) xaritasi emas — "So'ngi harakat" kartasida ko'rsatilmaydi
  static const Set<String> _nonSoundMaps = {
    gamesSound,
    firstSpeechArticulation,
    firstSpeechBreath,
    firstSpeechFinger,
    firstSpeechLine,
  };
  static const String defaultSound = 'R';

  static bool hasSound(String sound) => soundLevelFiles.containsKey(sound);

  String _currentSound = defaultSound;
  String get currentSound => _currentSound;

  // Ma'lumotlarni vaqtincha faqat ro'yxatda (xotirada) saqlaymiz.
  // Tovushlar orasida o'tganda progress yo'qolmasligi uchun har biri alohida keshlanadi.
  final Map<String, List<LevelState>> _levelsBySound = {};
  // Ro'yxatdagi o'zgarishlar (yulduz, unlock) keshdagi ro'yxatga ham tushadi,
  // chunki ikkalasi bitta obyekt.
  List<LevelState> _levels = [];
  List<LevelState> get levels => _levels;
  // Bir tovush bir vaqtda ikki marta yuklanmasligi uchun
  final Map<String, Future<List<LevelState>>> _loadingBySound = {};

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

  String? _lastSound;

  /// Oxirgi ochilgan tovush mashqi va unda bola kelib qolgan level.
  /// Hali hech bir tovush xaritasi ochilmagan bo'lsa null.
  LastActivity? get lastActivity {
    final sound = _lastSound;
    if (sound == null) return null;
    final levels = _levelsBySound[sound];
    if (levels == null || levels.isEmpty) return null;

    final currentIndex = levels.lastIndexWhere((lv) => !lv.locked);
    final index = currentIndex == -1 ? 0 : currentIndex;
    return LastActivity(
      sound: sound,
      currentLevelId: levels[index].id,
      levelNumber: index + 1,
      totalLevels: levels.length,
      completedLevels: levels.where((lv) => lv.stars > 0).length,
    );
  }

  // Joriy tovush levellarini yuklash
  Future<void> bootstrap() async {
    final saved = _progressBox?.get(_kLastSoundKey);
    if (saved is String && hasSound(saved) && !_nonSoundMaps.contains(saved)) {
      _lastSound = saved;
    }
    await selectSound(_currentSound);
    // "So'ngi harakat" kartasi uchun oxirgi tovush levellari ham kerak
    final last = _lastSound;
    if (last != null && last != _currentSound) {
      await _loadSound(last);
      notifyListeners();
    }
  }

  void _rememberLastSound(String sound) {
    // O'yinlar va Ilk nutq xaritalari tovush mashqi emas — "so'ngi harakat" hisoblanmaydi
    if (_nonSoundMaps.contains(sound) || sound == _lastSound) return;
    _lastSound = sound;
    _progressBox?.put(_kLastSoundKey, sound);
  }

  /// Tovush levellarini (saqlangan progress bilan) yuklab keshlaydi,
  /// joriy xaritani almashtirmaydi.
  /// Xarita levellari (keshda bo'lsa), joriy xaritani almashtirmaydi.
  /// Bo'lim kartalarida progress ko'rsatish uchun.
  List<LevelState>? levelsOf(String sound) => _levelsBySound[sound];

  /// Xarita levellarini oldindan yuklaydi (joriy xarita o'zgarmaydi)
  Future<void> preloadSound(String sound) async {
    if (!hasSound(sound) || _levelsBySound.containsKey(sound)) return;
    await _loadSound(sound);
    notifyListeners();
  }

  Future<List<LevelState>> _loadSound(String sound) async {
    final cached = _levelsBySound[sound];
    if (cached != null) return cached;

    final loaded = await (_loadingBySound[sound] ??= _loadLevels(
      soundLevelFiles[sound]!,
    ).then((levels) => _applySavedProgress(sound, levels)));
    _loadingBySound.remove(sound);
    // Xato bo'lsa (bo'sh ro'yxat) keshlamaymiz — keyingi safar qayta urinib ko'riladi
    if (loaded.isNotEmpty) _levelsBySound[sound] ??= loaded;
    return _levelsBySound[sound] ?? loaded;
  }

  /// Xaritani tanlangan tovush ([soundLevelFiles] kaliti) levellariga almashtiradi.
  Future<void> selectSound(String sound) async {
    if (!hasSound(sound)) {
      if (kDebugMode) print("❌ '$sound' tovushi uchun level fayli yo'q");
      return;
    }
    _rememberLastSound(sound);

    final cached = _levelsBySound[sound];
    if (sound == _currentSound && cached != null) {
      _levels = cached;
      return;
    }

    _currentSound = sound;
    _currentPlayingLevelId = null;

    if (cached != null) {
      _levels = cached;
      notifyListeners();
      return;
    }

    // Eski tovush levellari yangi yuklanguncha ko'rinmasin
    _levels = [];
    notifyListeners();

    final loaded = await _loadSound(sound);
    // Yuklash davomida boshqa tovush tanlangan bo'lsa, uning ro'yxatini buzmaymiz
    if (_currentSound != sound) return;

    _levels = loaded;
    _fetchScoreFromBackend();
    notifyListeners();
  }

  // Hive o'rniga JSON fayldan ma'lumotlarni yuklash
  Future<List<LevelState>> _loadLevels(String assetPath) async {
    try {
      // JSON faylni o'qish
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonData = json.decode(jsonString);

      final levels = jsonData.map((data) {
        // Exercise ma'lumotlarini parse qilish
        ExerciseInfo? exerciseInfo;
        if (data['exercise'] != null) {
          var exData = data['exercise'];
          exerciseInfo = ExerciseInfo(
            modelPath: exData['modelPath'] ?? '',
            sound: exData['sound'] ?? '',
            mediaPath: exData['mediaPath'] ?? '',
            steps:
                (exData['steps'] as List<dynamic>?)
                    ?.map(
                      (step) => ExerciseStep(
                        text: step['text'] ?? '',
                        sound: step['sound'],
                        action: step['action'] ?? '',
                      ),
                    )
                    .toList() ??
                [],
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
      levels.sort((a, b) => a.id.compareTo(b.id));

      if (kDebugMode) {
        print(
          "✅ $assetPath dan ${levels.length} ta level muvaffaqiyatli yuklandi",
        );
      }
      return levels;
    } catch (e) {
      if (kDebugMode) {
        print("❌ $assetPath ni o'qishda xatolik: $e");
      }
      return [];
    }
  }

  // --- PROGRESSNI SAQLASH ---
  // Har bir tovush uchun: {'unlocked': [id, ...], 'stars': {'id': yulduz}}

  Box? get _progressBox =>
      Hive.isBoxOpen(kLevelProgressBox) ? Hive.box(kLevelProgressBox) : null;

  /// O'yinlar xaritasi avval hammasi ochiq edi va progressda barcha id lar
  /// "unlocked" bo'lib saqlangan. Bir marta: ochiqlarni yulduzlar asosida
  /// qayta hisoblaymiz (1-o'yin + yulduzli o'yinlar + har biridan keyingisi).
  void _migrateGamesLockOnce() {
    final box = _progressBox;
    if (box == null || box.get(_kGamesLockMigratedKey) == true) return;

    final saved = box.get(gamesSound);
    if (saved is Map) {
      final stars = Map<String, dynamic>.from(
        (saved['stars'] as Map?) ?? const {},
      );
      final starred = stars.keys.map(int.tryParse).whereType<int>();
      box.put(gamesSound, {
        'unlocked': {1, ...starred, ...starred.map((id) => id + 1)}.toList(),
        'stars': stars,
      });
    }
    box.put(_kGamesLockMigratedKey, true);
  }

  List<LevelState> _applySavedProgress(String sound, List<LevelState> levels) {
    if (sound == gamesSound) _migrateGamesLockOnce();
    final saved = _progressBox?.get(sound);
    if (saved is! Map) return levels;

    final unlocked = Set<int>.from((saved['unlocked'] as List?) ?? const []);
    final stars = Map<String, dynamic>.from(
      (saved['stars'] as Map?) ?? const {},
    );

    return levels.map((lv) {
      final savedStars = (stars['${lv.id}'] as int?) ?? lv.stars;
      if (unlocked.contains(lv.id) && lv.locked) {
        return lv.copyWith(locked: false, skin: skinGold, stars: savedStars);
      }
      return savedStars != lv.stars ? lv.copyWith(stars: savedStars) : lv;
    }).toList();
  }

  void _saveProgress() {
    final box = _progressBox;
    if (box == null) return;
    box.put(_currentSound, {
      'unlocked': [
        for (final lv in _levels)
          if (!lv.locked) lv.id,
      ],
      'stars': {
        for (final lv in _levels)
          if (lv.stars > 0) '${lv.id}': lv.stars,
      },
    });
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
      _saveProgress();
    }
  }

  Future<bool> unlock({int stars = 0}) async {
    final currentId = _currentPlayingLevelId;
    if (currentId == null) return false;

    final currentIndex = _levels.indexWhere((lv) => lv.id == currentId);
    if (currentIndex == -1) return false;

    final currentLevel = _levels[currentIndex];

    final clampedStars = stars.clamp(0, 3);
    final bestStars = clampedStars > currentLevel.stars
        ? clampedStars
        : currentLevel.stars;

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
          stars: 0,
        );
      }
    }

    notifyListeners();
    _saveProgress();
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
