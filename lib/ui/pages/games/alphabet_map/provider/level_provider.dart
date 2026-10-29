import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../../../../core/network/api_service.dart';
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

/// S xaritasi test uchun hammasi ochiq bo'lgan payt saqlangan progressni
/// tozalash uchun bir martalik belgi
const String _kSoundSLockResetKey = '_s_lock_reset_v1';

/// Server tovush mashqlari: tovush -> voicePracticeId (offline uchun kesh)
const String _kPracticeIdsKey = '_srv_practice_ids';

/// Serverdan olingan levellar (offline uchun kesh), kalit: prefiks + tovush
const String _kServerLevelsPrefix = '_srv_levels_';

/// Serverga hali yetib bormagan natijalar: {levelMongoId: yulduz}
const String _kPendingStarsKey = '_srv_pending_stars';

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

  /// Tovush mashqlari — levellar va progress serverdan olinadi
  /// (/voice-practices, /levels, /levels/{id}/stars).
  /// Server'dagi mashq nomi tovush bilan bir xil bo'lishi kerak (R, Sh, ...).
  static const Set<String> serverSounds = {'R', 'L', 'S', 'K', 'Sh', 'Z', 'G'};

  // Qolgan xaritalar o'z level fayliga ega
  static const Map<String, String> soundLevelFiles = {
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

  static bool hasSound(String sound) =>
      serverSounds.contains(sound) || soundLevelFiles.containsKey(sound);

  static bool isServerSound(String sound) => serverSounds.contains(sound);

  final ApiService _api = ApiService();

  /// Tovush -> serverdagi voicePracticeId
  Map<String, String> _practiceIds = {};

  /// Tovush -> mashq ma'lumoti (available, availableLevelsCount, count, ...)
  Map<String, Map<String, dynamic>> _practiceInfo = {};

  /// Foydalanuvchida faol obuna bormi (server /voice-practices javobidan)
  bool? _subscribed;
  bool? get subscribed => _subscribed;

  /// false — mashqda foydalanuvchi uchun ochiq level yo'q (inactive).
  /// Ma'lumot hali kelmagan bo'lsa true.
  bool isPracticeAvailable(String sound) =>
      _practiceInfo[sound]?['available'] != false;

  /// Foydalanuvchi o'ynay oladigan levellar soni (obunasiz — faqat bepullar)
  int? availableLevelsOf(String sound) =>
      (_practiceInfo[sound]?['availableLevelsCount'] as num?)?.toInt();

  /// Mashqdagi jami levellar soni
  int? totalLevelsOf(String sound) =>
      (_practiceInfo[sound]?['count'] as num?)?.toInt();

  /// Hozir yuklanayotgan xarita
  bool _loading = false;
  bool get isLoading => _loading;

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
    // Bola kelib qolgan joy: serverdagi eng oxirgi natija qaysi mashqda bo'lsa
    final serverLast = await _lastSoundFromServer();
    if (serverLast != null) {
      _lastSound = serverLast;
      _progressBox?.put(_kLastSoundKey, serverLast);
    }
    await selectSound(_currentSound);
    // "So'ngi harakat" kartasi uchun oxirgi tovush levellari ham kerak
    final last = _lastSound;
    if (last != null && last != _currentSound) {
      await _loadSound(last);
      notifyListeners();
    }
  }

  /// Yulduzlar tarixidagi eng yangi yozuv qaysi tovush mashqiga tegishli
  Future<String?> _lastSoundFromServer() async {
    final history = await _api.getStarHistory();
    if (history == null || history.isEmpty) return null;
    final first = history.first;
    if (first is! Map) return null;
    final practiceId = first['voicePracticeId'];
    if (practiceId == null) return null;
    await _ensurePracticeIds();
    for (final e in _practiceIds.entries) {
      if (e.value == practiceId) return e.key;
    }
    return null;
  }

  /// Login/logout dan keyin: oldingi foydalanuvchi server ma'lumotlarini tozalaydi
  /// va yangisini yuklaydi.
  Future<void> reloadForUser() async {
    clearServerData();
    await bootstrap();
  }

  /// Server tovush mashqlari keshi va "so'ngi harakat"ni tozalaydi (logout)
  void clearServerData() {
    for (final sound in serverSounds) {
      _levelsBySound.remove(sound);
      _progressBox?.delete('$_kServerLevelsPrefix$sound');
    }
    _practiceIds = {};
    _practiceInfo = {};
    _subscribed = null;
    _progressBox?.delete(_kPracticeIdsKey);
    _progressBox?.delete(_kPendingStarsKey);
    _progressBox?.delete(_kLastSoundKey);
    _lastSound = null;
    if (isServerSound(_currentSound)) {
      _levels = [];
      _currentPlayingLevelId = null;
    }
    notifyListeners();
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

    final loaded = await (_loadingBySound[sound] ??= isServerSound(sound)
        ? _loadServerLevels(sound)
        : _loadLevels(
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
      if (isServerSound(sound)) refreshSound(sound);
      return;
    }

    _currentSound = sound;
    _currentPlayingLevelId = null;

    if (cached != null) {
      _levels = cached;
      notifyListeners();
      // Server progressi (boshqa qurilma, obuna) o'zgargan bo'lishi mumkin
      if (isServerSound(sound)) refreshSound(sound);
      return;
    }

    // Eski tovush levellari yangi yuklanguncha ko'rinmasin
    _levels = [];
    _loading = true;
    notifyListeners();

    final loaded = await _loadSound(sound);
    // Yuklash davomida boshqa tovush tanlangan bo'lsa, uning ro'yxatini buzmaymiz
    if (_currentSound != sound) return;

    _loading = false;
    _levels = loaded;
    _fetchScoreFromBackend();
    notifyListeners();
  }

  /// Xaritani serverdan qayta yuklaydi (keshdagi ro'yxat almashtiriladi)
  Future<void> refreshSound(String sound) async {
    if (!isServerSound(sound) || _loadingBySound.containsKey(sound)) return;
    final fresh = await (_loadingBySound[sound] = _loadServerLevels(sound));
    _loadingBySound.remove(sound);
    if (fresh.isEmpty && (_levelsBySound[sound]?.isNotEmpty ?? false)) return;
    _levelsBySound[sound] = fresh;
    if (_currentSound == sound) {
      _levels = fresh;
      _loading = false;
    }
    notifyListeners();
  }

  // JSON fayldan ma'lumotlarni yuklash (o'yinlar va "Ilk nutq" xaritalari)
  Future<List<LevelState>> _loadLevels(String assetPath) async {
    try {
      // JSON faylni o'qish
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonData = json.decode(jsonString);

      final levels = _parseLevels(jsonData);

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

  // --- SERVER TOVUSH MASHQLARI ---

  /// Tovush -> voicePracticeId xaritasini serverdan (bo'lmasa keshdan) oladi
  Future<void> _ensurePracticeIds() async {
    if (_practiceIds.isNotEmpty) return;
    await refreshPractices();
    if (_practiceIds.isNotEmpty) return;
    final saved = _progressBox?.get(_kPracticeIdsKey);
    if (saved is Map) {
      _practiceIds = saved.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
  }

  /// Mashqlar ro'yxatini (available, obuna holati) serverdan yangilaydi.
  /// Obuna sotib olingandan keyin ham chaqiriladi.
  Future<void> refreshPractices() async {
    final practices = await _api.getVoicePractices();
    if (practices == null) return;
    final ids = <String, String>{};
    final info = <String, Map<String, dynamic>>{};
    for (final p in practices) {
      final sound = _soundOfPracticeName(p['name']?.toString() ?? '');
      final id = p['id']?.toString();
      if (sound == null || id == null || ids.containsKey(sound)) continue;
      ids[sound] = id;
      info[sound] = p;
      if (p['subscribed'] is bool) _subscribed = p['subscribed'] as bool;
    }
    _practiceIds = ids;
    _practiceInfo = info;
    _progressBox?.put(_kPracticeIdsKey, ids);
    notifyListeners();
  }

  /// "R", "Sh tovushi", "S - tovush" -> serverSounds kaliti
  static String? _soundOfPracticeName(String name) {
    final words = name
        .toLowerCase()
        .split(RegExp(r"[^a-z]+"))
        .where((w) => w.isNotEmpty);
    for (final w in words) {
      for (final sound in serverSounds) {
        if (sound.toLowerCase() == w) return sound;
      }
    }
    return null;
  }

  Future<List<LevelState>> _loadServerLevels(String sound) async {
    await _flushPendingStars();
    await _ensurePracticeIds();
    final practiceId = _practiceIds[sound];

    final box = _progressBox;
    final cacheKey = '$_kServerLevelsPrefix$sound';
    List<dynamic>? raw;
    if (practiceId != null) {
      raw = await _api.getVoicePracticeLevels(practiceId);
      if (raw != null) box?.put(cacheKey, json.encode(raw));
    }
    if (raw == null) {
      // Internet yo'q — oxirgi marta olingan ro'yxat
      final cached = box?.get(cacheKey);
      if (cached is String) {
        try {
          raw = json.decode(cached) as List<dynamic>;
        } catch (_) {}
      }
    }
    if (raw == null) {
      if (kDebugMode) print("❌ '$sound' levellari serverdan olinmadi");
      return [];
    }

    final levels = _applyServerProgress(sound, _parseLevels(raw));
    if (kDebugMode) {
      print("✅ '$sound' uchun serverdan ${levels.length} ta level olindi");
    }
    return levels;
  }

  Map<String, int> _pendingStars() {
    final saved = _progressBox?.get(_kPendingStarsKey);
    if (saved is! Map) return {};
    return saved.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
  }

  void _savePendingStars(Map<String, int> pending) {
    if (pending.isEmpty) {
      _progressBox?.delete(_kPendingStarsKey);
    } else {
      _progressBox?.put(_kPendingStarsKey, pending);
    }
  }

  /// Natija avval navbatga yoziladi, server qabul qilgach o'chiriladi —
  /// internet bo'lmasa ham progress yo'qolmaydi.
  Future<void> _submitStars(String levelMongoId, int stars) async {
    final pending = _pendingStars();
    final prev = pending[levelMongoId] ?? -1;
    if (stars > prev) pending[levelMongoId] = stars;
    _savePendingStars(pending);
    await _flushPendingStars();
  }

  bool _flushing = false;

  Future<void> _flushPendingStars() async {
    if (_flushing) return;
    _flushing = true;
    try {
      for (final e in _pendingStars().entries) {
        final ok = await _api.submitLevelStars(e.key, e.value);
        if (ok == null) break; // internet yo'q — keyingi safar
        // Qabul qilindi yoki rad etildi (pullik level) — navbatdan olinadi
        final pending = _pendingStars();
        if (pending[e.key] == e.value) pending.remove(e.key);
        _savePendingStars(pending);
      }
    } finally {
      _flushing = false;
    }
  }

  /// Server progressiga hali yuborilmagan natijalarni va eski (qurilmada
  /// saqlangan) progressni qo'shadi, so'ng ochiq levellarni hisoblaydi:
  /// 1-level doim ochiq, yulduzli levelning keyingisi ochiq.
  List<LevelState> _applyServerProgress(String sound, List<LevelState> levels) {
    _migrateLocalProgressToServer(sound, levels);
    final pending = _pendingStars();

    final out = <LevelState>[];
    for (var i = 0; i < levels.length; i++) {
      var lv = levels[i];
      final p = lv.serverId == null ? null : pending[lv.serverId];
      if (p != null && p > lv.stars) lv = lv.copyWith(stars: p);

      final prev = i == 0 ? null : out[i - 1];
      final prevPlayed = prev != null &&
          (prev.stars > 0 ||
              (prev.serverId != null && pending.containsKey(prev.serverId)));
      // Pullik level obunasiz ochilmaydi
      final unlocked = lv.available && (i == 0 || !lv.locked || prevPlayed);
      out.add(lv.copyWith(
        locked: !unlocked,
        skin: unlocked ? skinGold : skinSilver,
      ));
    }
    return out;
  }

  /// Avval progress faqat qurilmada (Hive) saqlanardi. Bir marta: uni
  /// navbatga qo'yib serverga yuboramiz va qurilmadagisini o'chiramiz.
  void _migrateLocalProgressToServer(String sound, List<LevelState> levels) {
    if (sound == 'S') _resetSoundSProgressOnce();
    final box = _progressBox;
    final saved = box?.get(sound);
    if (box == null || saved is! Map || levels.isEmpty) return;

    final unlocked = Set<int>.from((saved['unlocked'] as List?) ?? const []);
    final stars = Map<String, dynamic>.from(
      (saved['stars'] as Map?) ?? const {},
    );
    final pending = _pendingStars();
    for (var i = 0; i < levels.length; i++) {
      final lv = levels[i];
      final id = lv.serverId;
      if (id == null || !lv.available) continue;
      final localStars = (stars['${lv.id}'] as num?)?.toInt() ?? 0;
      // Keyingi level ochilgan bo'lsa, bu level o'ynalgan (0 yulduz bilan ham)
      final nextUnlocked =
          i + 1 < levels.length && unlocked.contains(levels[i + 1].id);
      if (localStars > lv.stars || (nextUnlocked && lv.stars == 0)) {
        final best = localStars > lv.stars ? localStars : lv.stars;
        if (best > (pending[id] ?? -1)) pending[id] = best;
      }
    }
    _savePendingStars(pending);
    box.delete(sound);
    _flushPendingStars();
  }

  /// JSON yoki server javobidagi levellar ro'yxatini [LevelState] ga o'giradi.
  /// Server javobida `id` — mongo id, `levelId` — tartib raqami.
  List<LevelState> _parseLevels(List<dynamic> jsonData) {
    final levels = jsonData.whereType<Map>().map((data) {
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
            objective: gData['objective'],
          );
        }

        final fromServer = data['levelId'] != null;
        return LevelState(
          id: ((fromServer ? data['levelId'] : data['id']) as num).toInt(),
          serverId: fromServer ? data['id']?.toString() : null,
          available: data['available'] != false,
          stars: ((data['stars'] as num?) ?? 0).toInt(),
          locked: data['locked'] ?? true,
          skin: data['skin'] ?? skinSilver,
          mode: data['mode'] ?? 'game',
          exercise: exerciseInfo,
          game: gameInfo,
        );
      }).toList();

    // ID bo'yicha tartiblab qo'yamiz
    levels.sort((a, b) => a.id.compareTo(b.id));
    return levels;
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

  /// S xaritasi test paytida hammasi ochiq edi va progressda barcha id lar
  /// "unlocked" bo'lib saqlangan. S undan oldin hech kimda ochilmagan,
  /// shuning uchun bir marta S progressini butunlay tozalaymiz.
  void _resetSoundSProgressOnce() {
    final box = _progressBox;
    if (box == null || box.get(_kSoundSLockResetKey) == true) return;
    box.delete('S');
    box.put(_kSoundSLockResetKey, true);
  }

  List<LevelState> _applySavedProgress(String sound, List<LevelState> levels) {
    if (sound == gamesSound) _migrateGamesLockOnce();
    if (sound == 'S') _resetSoundSProgressOnce();
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
    // Tovush mashqlari progressi serverda saqlanadi
    if (isServerSound(_currentSound)) return;
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
      final serverId = lv.serverId;
      if (serverId != null) await _submitStars(serverId, clamped);
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

    // 2. Keyingi levelni ochamiz (server levellari id ketma-ket bo'lmasligi
    // mumkin — obunasizga faqat bepullari keladi, shuning uchun tartib bo'yicha)
    final nextIndex = currentIndex + 1;

    if (nextIndex < _levels.length) {
      final nextLevel = _levels[nextIndex];
      if (nextLevel.locked && nextLevel.available) {
        _levels[nextIndex] = nextLevel.copyWith(
          locked: false,
          skin: skinGold,
          stars: 0,
        );
      }
    }

    notifyListeners();
    _saveProgress();
    final serverId = currentLevel.serverId;
    if (serverId != null) _submitStars(serverId, bestStars);
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
}
