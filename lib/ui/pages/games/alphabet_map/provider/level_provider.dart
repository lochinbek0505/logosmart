import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/network_status.dart';
import '../../../../../core/storage/level_state.dart';

const String skinGold = 'assets/icons/gold.webp';
const String skinSilver = 'assets/icons/silver.webp';

/// Levellar keshi, serverga hali yetib bormagan natijalar va ball navbati
/// saqlanadigan Hive box. main() da ochiladi.
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

/// Tovush mashqlari tartibi (serverdagi sequenceNumber bo'yicha), offline uchun kesh
const String _kPracticeOrderKey = '_srv_practice_order';

/// Serverdan olingan levellar (kesh), kalit: prefiks + xarita
const String _kServerLevelsPrefix = '_srv_levels_';

/// Serverga hali yetib bormagan natijalar: {levelMongoId: yulduz}
const String _kPendingStarsKey = '_srv_pending_stars';

/// Eski (faqat qurilmada saqlangan) umumiy ball — bir marta serverga ko'chiriladi
const String _kLegacyBallKey = '_total_ball';

/// Serverdagi umumiy ballning oxirgi ma'lum qiymati
const String _kServerBallKey = '_srv_ball';

/// Serverga hali yetib bormagan ball o'zgarishlari: [{id, delta}, ...]
const String _kPendingBallKey = '_srv_pending_ball';

/// Bir so'rovda yuboriladigan ball hodisalari (server cheklovi 200)
const int _kBallBatch = 100;

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

/// Eski lokal progress kaliti va uning yangi (server) xaritadagi siljishi
class _LegacyPart {
  const _LegacyPart(this.key, this.offset);

  final String key;
  final int offset;
}

class LevelProvider extends ChangeNotifier with WidgetsBindingObserver {
  LevelProvider({bool autoBootstrap = true}) {
    if (autoBootstrap) {
      _listening = true;
      NetworkStatus.instance.addListener(_onNetworkChanged);
      WidgetsBinding.instance.addObserver(this);
      _ready = Future.microtask(bootstrap);
    }
  }

  Future<void>? _ready;

  /// Testlar uchun: avtomatik bootstrap tugashini kutish
  @visibleForTesting
  Future<void> get ready => _ready ?? Future.value();

  bool _listening = false;
  bool _disposed = false;

  int? _currentPlayingLevelId;
  int? get currentPlayingLevelId => _currentPlayingLevelId;

  /// O'yinlar bo'limi xaritasi (hamma o'yinlar bitta joyda, ketma-ket ochiladi)
  static const String gamesSound = 'GAMES';

  /// "Ilk nutqni rivojlantirish" bo'limi — bitta xarita
  static const String firstSpeechSound = 'FIRST_SPEECH';

  /// Bo'lim xaritalari: kalit -> server yo'li (GET /games, GET /first-speech)
  static const Map<String, String> sectionPaths = {
    gamesSound: 'games',
    firstSpeechSound: 'first-speech',
  };

  /// Tovush mashqlari — levellar va progress serverdan olinadi
  /// (/voice-practices, /levels, /levels/{id}/stars).
  /// Server'dagi mashq nomi tovush bilan bir xil bo'lishi kerak (R, Sh, ...).
  static const Set<String> serverSounds = {'R', 'L', 'S', 'K', 'Sh', 'Z', 'G'};

  /// Avval progress faqat qurilmada saqlangan xaritalar. Ilk nutq 4 ta alohida
  /// xarita edi — endi bitta xaritada ketma-ket: artikulatsion (1–8),
  /// nafas (9–20), barmoq (21–27), chiziq (28–42).
  static const Map<String, List<_LegacyPart>> _legacyParts = {
    gamesSound: [_LegacyPart(gamesSound, 0)],
    firstSpeechSound: [
      _LegacyPart('FS_ARTIKULATSION', 0),
      _LegacyPart('FS_NAFAS', 8),
      _LegacyPart('FS_BARMOQ', 20),
      _LegacyPart('FS_CHIZIQ', 27),
    ],
  };

  static Iterable<String> get _legacyKeys =>
      _legacyParts.values.expand((parts) => parts.map((p) => p.key));

  static const String defaultSound = 'R';

  /// Barcha xaritalar (tovushlar, o'yinlar, ilk nutq) serverda
  static Iterable<String> get allMaps => [...serverSounds, ...sectionPaths.keys];

  static bool hasSound(String sound) =>
      serverSounds.contains(sound) || sectionPaths.containsKey(sound);

  /// Xarita levellari va progressi serverdan olinadimi (hammasi — ha)
  static bool isServerSound(String sound) => hasSound(sound);

  static bool isSection(String sound) => sectionPaths.containsKey(sound);

  final ApiService _api = ApiService();

  /// Tovush -> serverdagi voicePracticeId
  Map<String, String> _practiceIds = {};

  /// Tovush/bo'lim -> mashq ma'lumoti (available, availableLevelsCount, count, ...)
  Map<String, Map<String, dynamic>> _practiceInfo = {};

  /// Foydalanuvchida faol obuna bormi (server javobidan)
  bool? _subscribed;
  bool? get subscribed => _subscribed;

  /// false — mashqda foydalanuvchi uchun ochiq level yo'q (inactive).
  /// Ma'lumot hali kelmagan bo'lsa true.
  bool isPracticeAvailable(String sound) =>
      _practiceInfo[sound]?['available'] != false;

  /// Foydalanuvchi o'ynay oladigan levellar soni (obunasiz — faqat bepullar)
  int? availableLevelsOf(String sound) =>
      (_practiceInfo[sound]?['availableLevelsCount'] as num?)?.toInt();

  /// Tovushlar serverdagi tartib raqami (sequenceNumber) bo'yicha
  List<String> _soundOrder = [];

  /// [sounds] ni admin paneldagi tartib raqami bo'yicha saralaydi. Serverda
  /// yo'q tovushlar (masalan "Tez kunda") oxirida, berilgan tartibda qoladi.
  List<T> sortBySoundOrder<T>(List<T> items, String Function(T) soundOf) {
    if (_soundOrder.isEmpty) {
      final saved = _progressBox?.get(_kPracticeOrderKey);
      if (saved is List) _soundOrder = saved.map((e) => e.toString()).toList();
    }
    int rank(T item) {
      final i = _soundOrder.indexOf(soundOf(item));
      return i < 0 ? _soundOrder.length : i;
    }
    final indexed = items.asMap().entries.toList()
      ..sort((a, b) {
        final byRank = rank(a.value).compareTo(rank(b.value));
        return byRank != 0 ? byRank : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }

  /// Mashqdagi jami levellar soni
  int? totalLevelsOf(String sound) =>
      (_practiceInfo[sound]?['count'] as num?)?.toInt();

  /// Hozir yuklanayotgan xarita
  bool _loading = false;
  bool get isLoading => _loading;

  String _currentSound = defaultSound;
  String get currentSound => _currentSound;

  // Tovushlar orasida o'tganda qayta yuklanmasligi uchun har biri alohida keshlanadi.
  final Map<String, List<LevelState>> _levelsBySound = {};
  // Ro'yxatdagi o'zgarishlar (yulduz, unlock) keshdagi ro'yxatga ham tushadi,
  // chunki ikkalasi bitta obyekt.
  List<LevelState> _levels = [];
  List<LevelState> get levels => _levels;
  // Bir tovush bir vaqtda ikki marta yuklanmasligi uchun
  final Map<String, Future<List<LevelState>>> _loadingBySound = {};

  OpenLevelCallback? onOpenLevel;

  // --- UMUMIY BALL (serverda) ---

  /// Serverdagi ball + hali yuborilmagan o'zgarishlar (server kabi 0 dan
  /// pastga tushmaydi)
  int get ball {
    var v = _serverBall;
    for (final e in _pendingBall()) {
      v = max(0, v + ((e['delta'] as num?)?.toInt() ?? 0));
    }
    return v;
  }

  int _serverBall = 0;

  final Random _rnd = Random.secure();

  String _newEventId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-'
      '${_rnd.nextInt(1 << 32).toRadixString(36)}';

  void addBall(int value) {
    if (value == 0) return;
    final pending = _pendingBall()..add({'id': _newEventId(), 'delta': value});
    _savePendingBall(pending);
    notifyListeners();
    _flushBall();
  }

  List<Map<String, dynamic>> _pendingBall() {
    final saved = _progressBox?.get(_kPendingBallKey);
    if (saved is! List) return [];
    return saved
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  void _savePendingBall(List<Map<String, dynamic>> pending) {
    if (pending.isEmpty) {
      _progressBox?.delete(_kPendingBallKey);
    } else {
      _progressBox?.put(_kPendingBallKey, pending);
    }
  }

  void _loadBallState() {
    final saved = _progressBox?.get(_kServerBallKey);
    _serverBall = saved is int ? saved : 0;
    // Avval ball faqat qurilmada edi — bir marta serverga hodisa sifatida yuboramiz
    final legacy = _progressBox?.get(_kLegacyBallKey);
    if (legacy is int && legacy > 0) {
      final pending = _pendingBall()
        ..add({'id': 'legacy-${_newEventId()}', 'delta': legacy});
      _savePendingBall(pending);
    }
    _progressBox?.delete(_kLegacyBallKey);
  }

  Future<void>? _flushingBall;

  /// Navbatdagi ball hodisalarini yuboradi; navbat bo'sh bo'lsa serverdagi
  /// qiymatni o'qiydi. Yuborish paytida qo'shilgan hodisalar ham shu
  /// aylanishda yuboriladi.
  Future<void> _flushBall({bool refresh = false}) =>
      _flushingBall ??= _doFlushBall(refresh).whenComplete(() => _flushingBall = null);

  Future<void> _doFlushBall(bool refresh) async {
    var pending = _pendingBall();
    if (pending.isEmpty) {
      if (!refresh) return;
      final b = await _api.getBall();
      if (b != null && _pendingBall().isEmpty) _setServerBall(b);
      return;
    }
    while (pending.isNotEmpty) {
      final batch = pending.take(_kBallBatch).toList();
      final res = await _api.postBallEvents(batch);
      if (res == null) return; // internet yo'q — keyingi safar
      final sent = batch.map((e) => e['id']).toSet();
      pending = _pendingBall()..removeWhere((e) => sent.contains(e['id']));
      _savePendingBall(pending);
      if (res.ball != null) _setServerBall(res.ball!);
      notifyListeners();
    }
  }

  void _setServerBall(int b) {
    _serverBall = max(0, b);
    _progressBox?.put(_kServerBallKey, _serverBall);
    notifyListeners();
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
    _loadBallState();
    final saved = _progressBox?.get(_kLastSoundKey);
    if (saved is String && serverSounds.contains(saved)) {
      _lastSound = saved;
    }
    // Ball: navbatdagilar yuboriladi va serverdagi qiymat olinadi
    unawaited(_flushBall(refresh: true));
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
    // O'yinlar va Ilk nutq: eski (qurilmadagi) progress darhol serverga
    // ko'chirilsin va xaritalar keshda tayyor tursin
    for (final s in sectionPaths.keys) {
      await preloadSound(s);
    }
  }

  /// Yulduzlar tarixidagi eng yangi tovush mashqi yozuvi (o'yin/ilk nutq emas)
  Future<String?> _lastSoundFromServer() async {
    final history = await _api.getStarHistory();
    if (history == null || history.isEmpty) return null;
    await _ensurePracticeIds();
    final bySoundId = {for (final e in _practiceIds.entries) e.value: e.key};
    for (final item in history) {
      if (item is! Map) continue;
      final sound = bySoundId[item['voicePracticeId']];
      if (sound != null) return sound;
    }
    return null;
  }

  /// Login dan keyin: oldingi foydalanuvchi server ma'lumotlarini tozalaydi
  /// va yangisini yuklaydi. Eski (yangilanishdan oldingi) lokal progress
  /// saqlanib qoladi va shu foydalanuvchiga ko'chiriladi.
  Future<void> reloadForUser() async {
    clearServerData(keepLegacy: true);
    await bootstrap();
  }

  /// Logout'dan oldin: navbatdagi natija va ballarni serverga yuborishga
  /// urinib ko'radi (ko'pi bilan [timeout]).
  Future<void> flushBeforeSignOut({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      await Future.wait([
        _flushPendingStars(),
        _flushBall(),
      ]).timeout(timeout);
    } catch (_) {}
  }

  /// Server ma'lumotlari keshi, navbatlar va "so'ngi harakat"ni tozalaydi
  /// (logout). Keyingi foydalanuvchiga oldingisining progressi o'tmasin.
  void clearServerData({bool keepLegacy = false}) {
    for (final sound in allMaps) {
      _levelsBySound.remove(sound);
      _progressBox?.delete('$_kServerLevelsPrefix$sound');
    }
    if (!keepLegacy) {
      for (final key in _legacyKeys) {
        _progressBox?.delete(key);
      }
      _progressBox?.delete(_kLegacyBallKey);
    }
    _practiceIds = {};
    _practiceInfo = {};
    _subscribed = null;
    _progressBox?.delete(_kPracticeIdsKey);
    _progressBox?.delete(_kPendingStarsKey);
    _progressBox?.delete(_kLastSoundKey);
    _progressBox?.delete(_kServerBallKey);
    _progressBox?.delete(_kPendingBallKey);
    _serverBall = 0;
    _lastSound = null;
    _levels = [];
    _currentPlayingLevelId = null;
    notifyListeners();
  }

  void _rememberLastSound(String sound) {
    // O'yinlar va Ilk nutq xaritalari tovush mashqi emas — "so'ngi harakat" hisoblanmaydi
    if (!serverSounds.contains(sound) || sound == _lastSound) return;
    _lastSound = sound;
    _progressBox?.put(_kLastSoundKey, sound);
  }

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

    final loaded =
        await (_loadingBySound[sound] ??= _loadServerLevels(sound));
    _loadingBySound.remove(sound);
    // Xato bo'lsa (bo'sh ro'yxat) keshlamaymiz — keyingi safar qayta urinib ko'riladi
    if (loaded.isNotEmpty) _levelsBySound[sound] ??= loaded;
    return _levelsBySound[sound] ?? loaded;
  }

  /// Xaritani tanlangan tovush/bo'lim levellariga almashtiradi.
  Future<void> selectSound(String sound) async {
    if (!hasSound(sound)) {
      if (kDebugMode) print("❌ '$sound' xaritasi yo'q");
      return;
    }
    _rememberLastSound(sound);

    final cached = _levelsBySound[sound];
    if (sound == _currentSound && cached != null) {
      _levels = cached;
      refreshSound(sound);
      return;
    }

    _currentSound = sound;
    _currentPlayingLevelId = null;

    if (cached != null) {
      _levels = cached;
      notifyListeners();
      // Server progressi (boshqa qurilma, obuna) o'zgargan bo'lishi mumkin
      refreshSound(sound);
      return;
    }

    // Eski xarita levellari yangi yuklanguncha ko'rinmasin
    _levels = [];
    _loading = true;
    notifyListeners();

    final loaded = await _loadSound(sound);
    // Yuklash davomida boshqa tovush tanlangan bo'lsa, uning ro'yxatini buzmaymiz
    if (_currentSound != sound) return;

    _loading = false;
    _levels = loaded;
    notifyListeners();
  }

  /// Xaritani serverdan qayta yuklaydi (keshdagi ro'yxat almashtiriladi)
  Future<void> refreshSound(String sound) async {
    if (!hasSound(sound) || _loadingBySound.containsKey(sound)) return;
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

  // --- SERVER XARITALARI ---

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
    final seq = <String, num>{};
    final info = <String, Map<String, dynamic>>{
      // Bo'limlar ma'lumoti o'z API'sidan keladi — saqlanib qoladi
      for (final s in sectionPaths.keys)
        if (_practiceInfo[s] != null) s: _practiceInfo[s]!,
    };
    for (final p in practices) {
      final sound = _soundOfPracticeName(p['name']?.toString() ?? '');
      final id = p['id']?.toString();
      if (sound == null || id == null || ids.containsKey(sound)) continue;
      ids[sound] = id;
      info[sound] = p;
      final n = p['sequenceNumber'];
      if (n is num) seq[sound] = n;
      if (p['subscribed'] is bool) _subscribed = p['subscribed'] as bool;
    }
    _practiceIds = ids;
    _practiceInfo = info;
    _progressBox?.put(_kPracticeIdsKey, ids);
    // Server ro'yxatni allaqachon tartiblab yuboradi; sequenceNumber
    // bo'lmagan eski yozuvlar oxiriga, kelgan tartibida
    final order = ids.keys.toList();
    final pos = {for (var i = 0; i < order.length; i++) order[i]: i};
    order.sort((a, b) {
      final sa = seq[a], sb = seq[b];
      if (sa != null && sb != null && sa != sb) return sa.compareTo(sb);
      if ((sa == null) != (sb == null)) return sa == null ? 1 : -1;
      return pos[a]!.compareTo(pos[b]!);
    });
    _soundOrder = order;
    _progressBox?.put(_kPracticeOrderKey, order);
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

  /// Xarita levellari serverdan: tovushlar — /levels?voicePracticeId=,
  /// O'yinlar va Ilk nutq — /games, /first-speech
  Future<List<dynamic>?> _fetchLevels(String sound) async {
    final section = sectionPaths[sound];
    if (section != null) {
      final data = await _api.getSection(section);
      if (data == null || data['levels'] is! List) return null;
      _practiceInfo[sound] = {
        'id': data['id'],
        'count': data['totalLevels'],
        'availableLevelsCount': data['availableLevelsCount'],
        'available': ((data['availableLevelsCount'] as num?) ?? 0) > 0,
        'subscribed': data['subscribed'],
      };
      if (data['subscribed'] is bool) _subscribed = data['subscribed'] as bool;
      return data['levels'] as List;
    }
    await _ensurePracticeIds();
    final practiceId = _practiceIds[sound];
    if (practiceId == null) return null;
    return _api.getVoicePracticeLevels(practiceId);
  }

  Future<List<LevelState>> _loadServerLevels(String sound) async {
    await _flushPendingStars();

    final box = _progressBox;
    final cacheKey = '$_kServerLevelsPrefix$sound';
    var raw = await _fetchLevels(sound);
    if (raw != null) {
      box?.put(cacheKey, json.encode(raw));
    } else {
      // Server javob bermadi — oxirgi marta olingan ro'yxat
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
  /// internet uzilsa ham progress yo'qolmaydi.
  Future<void> _submitStars(String levelMongoId, int stars) async {
    final pending = _pendingStars();
    final prev = pending[levelMongoId] ?? -1;
    if (stars > prev) pending[levelMongoId] = stars;
    _savePendingStars(pending);
    await _flushPendingStars();
  }

  Future<void>? _flushingStars;

  Future<void> _flushPendingStars() =>
      _flushingStars ??= _doFlushStars().whenComplete(() => _flushingStars = null);

  Future<void> _doFlushStars() async {
    // Yuborish paytida yangi natija qo'shilsa (yoki yulduzi oshsa) — u ham yuboriladi
    while (true) {
      final snapshot = _pendingStars();
      if (snapshot.isEmpty) return;
      for (final e in snapshot.entries) {
        final ok = await _api.submitLevelStars(e.key, e.value);
        if (ok == null) return; // internet yo'q — keyingi safar
        // Qabul qilindi yoki rad etildi (pullik level) — navbatdan olinadi
        final pending = _pendingStars();
        if (pending[e.key] == e.value) pending.remove(e.key);
        _savePendingStars(pending);
      }
    }
  }

  /// Hammasi navbatda turgan bo'lsa (internet qaytdi / ilova fondan qaytdi):
  /// natijalar va ball yuboriladi, ochiq xarita serverdan yangilanadi.
  Future<void> syncNow() async {
    await Future.wait([_flushPendingStars(), _flushBall(refresh: true)]);
    if (_disposed) return;
    if (_levelsBySound.containsKey(_currentSound)) {
      await refreshSound(_currentSound);
    }
  }

  bool _wasOnline = true;

  void _onNetworkChanged() {
    final online = NetworkStatus.instance.isOnline;
    final reconnected = online && !_wasOnline;
    _wasOnline = online;
    if (reconnected) syncNow();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) syncNow();
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
  /// Ilk nutqning 4 ta eski xaritasi yangi xaritaga siljish bilan tushadi.
  void _migrateLocalProgressToServer(String sound, List<LevelState> levels) {
    if (sound == 'S') _resetSoundSProgressOnce();
    if (sound == gamesSound) _migrateGamesLockOnce();
    final box = _progressBox;
    if (box == null || levels.isEmpty) return;

    final parts = _legacyParts[sound] ?? [_LegacyPart(sound, 0)];
    // Yangi xaritadagi tartib raqamlari bo'yicha: ochilganlar va yulduzlar
    final unlocked = <int>{};
    final stars = <int, int>{};
    var found = false;
    for (final part in parts) {
      final saved = box.get(part.key);
      if (saved is! Map) continue;
      found = true;
      for (final id in (saved['unlocked'] as List?) ?? const []) {
        final n = (id as num?)?.toInt();
        // Har bir eski xaritaning 1-leveli doim ochiq edi — bu oldingi
        // bo'limning oxirgi leveli o'ynalganini bildirmaydi
        if (n == null || (n == 1 && part.offset > 0)) continue;
        unlocked.add(n + part.offset);
      }
      ((saved['stars'] as Map?) ?? const {}).forEach((k, v) {
        final n = int.tryParse(k.toString());
        final s = (v as num?)?.toInt() ?? 0;
        if (n != null && s > 0) stars[n + part.offset] = s;
      });
    }
    if (!found) return;

    final pending = _pendingStars();
    for (var i = 0; i < levels.length; i++) {
      final lv = levels[i];
      final id = lv.serverId;
      if (id == null || !lv.available) continue;
      final localStars = stars[lv.id] ?? 0;
      // Keyingi level ochilgan bo'lsa, bu level o'ynalgan (0 yulduz bilan ham)
      final nextUnlocked =
          i + 1 < levels.length && unlocked.contains(levels[i + 1].id);
      if (localStars > lv.stars || (nextUnlocked && lv.stars == 0)) {
        final best = localStars > lv.stars ? localStars : lv.stars;
        if (best > (pending[id] ?? -1)) pending[id] = best;
      }
    }
    _savePendingStars(pending);
    for (final part in parts) {
      box.delete(part.key);
    }
    _flushPendingStars();
  }

  /// JSON yoki server javobidagi levellar ro'yxatini [LevelState] ga o'giradi.
  /// Server javobida `id` — mongo id, `levelId` — tartib raqami.
  static bool _isNonEmptyExercise(Object? ex) {
    if (ex is! Map) return false;
    String str(Object? v) => (v ?? '').toString().trim();
    return str(ex['modelPath']).isNotEmpty ||
        str(ex['mediaPath']).isNotEmpty ||
        str(ex['sound']).isNotEmpty ||
        ((ex['steps'] as List?)?.isNotEmpty ?? false);
  }

  List<LevelState> _parseLevels(List<dynamic> jsonData) {
    final levels = jsonData.whereType<Map>().map((data) {
        // Exercise ma'lumotlarini parse qilish
        ExerciseInfo? exerciseInfo;
        // Server bo'sh obyekt yuborishi mumkin ({"modelPath": "", "steps": []}) — bu "mashq yo'q"
        if (_isNonEmptyExercise(data['exercise'])) {
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
        // Server mashq levellari uchun ham {"type": ""} yuboradi — turi bo'sh bo'lsa o'yin yo'q
        if (data['game'] is Map && (data['game']['type'] ?? '').toString().isNotEmpty) {
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

  // --- ESKI LOKAL PROGRESS (bir martalik migratsiyalar) ---
  // Eski format: {'unlocked': [id, ...], 'stars': {'id': yulduz}}

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

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_listening) {
      NetworkStatus.instance.removeListener(_onNetworkChanged);
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}
