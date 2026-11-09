import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../network/api_service.dart';
import '../service/app_settings.dart';
import '../storage/token_storage.dart';

/// Resurs yo'lini bir xil ko'rinishga keltiradi: "sound/x.mp3" (AssetSource uslubi)
/// va "assets/sound/x.mp3" — ikkalasi ham "assets/sound/x.mp3".
String normalizeResourcePath(String path) {
  var p = path.trim().replaceAll('\\', '/');
  while (p.startsWith('/')) {
    p = p.substring(1);
  }
  return p.startsWith('assets/') ? p : 'assets/$p';
}

/// Yuklash nima sababdan to'xtadi
enum ResourceErrorKind {
  /// Internet yo'q yoki juda sekin
  network,

  /// Server vaqtincha ishlamayapti (5xx)
  server,

  /// Telefon xotirasida joy yetarli emas
  noSpace,

  /// Fayl buzilib kelaverdi / boshqa xato
  other,
}

/// Yuklash holati (yuklash ekrani va banner uchun)
class ResourceProgress {
  const ResourceProgress({
    this.doneFiles = 0,
    this.totalFiles = 0,
    this.doneBytes = 0,
    this.totalBytes = 0,
    this.bytesPerSecond = 0,
    this.retrying = false,
    this.error,
    this.errorKind,
  });

  final int doneFiles;
  final int totalFiles;
  final int doneBytes;
  final int totalBytes;

  /// Oxirgi soniyalardagi o'rtacha tezlik
  final double bytesPerSecond;

  /// Aloqa uzilib, qayta urinilyapti
  final bool retrying;

  /// null bo'lmasa — yuklash to'xtadi
  final String? error;
  final ResourceErrorKind? errorKind;

  double get fraction => totalBytes == 0
      ? (totalFiles == 0 ? 0 : doneFiles / totalFiles)
      : (doneBytes / totalBytes).clamp(0.0, 1.0);

  /// Taxminiy qolgan vaqt (tezlik ma'lum bo'lsa)
  Duration? get eta {
    if (bytesPerSecond < 1 || totalBytes == 0) return null;
    final left = math.max(0, totalBytes - doneBytes);
    return Duration(seconds: (left / bytesPerSecond).ceil());
  }
}

/// Orqa fondagi yuklash bosqichi (Bosh sahifadagi karta uchun)
enum ResourcePhase {
  /// Hammasi qurilmada, hech narsa yuklanmayapti
  idle,

  /// Yuklanyapti
  downloading,

  /// Videolar/modellar Wi-Fi kutilyapti ("faqat Wi-Fi" sozlamasi yoqilgan)
  waitingWifi,

  /// Yuklash to'xtadi (internet yo'q, joy yo'q va h.k.)
  failed,
}

/// Orqa fondagi yuklashning umumiy holati
class ResourceStatus {
  const ResourceStatus({
    this.phase = ResourcePhase.idle,
    this.groups = const {},
    this.progress = const ResourceProgress(),
    this.pendingBytes = 0,
  });

  final ResourcePhase phase;

  /// Hozir yuklanayotgan (yoki kutib turgan) guruhlar: core, videos, models
  final Set<String> groups;
  final ResourceProgress progress;

  /// Wi-Fi kutilayotgan fayllar hajmi
  final int pendingBytes;
}

class _Entry {
  _Entry(this.sha256, this.size, this.group);

  final String sha256;
  final int size;
  final String group;

  Map<String, dynamic> toJson() => {
        'sha256': sha256,
        'size': size,
        'group': group,
      };

  static _Entry fromJson(Map<String, dynamic> m) => _Entry(
        m['sha256']?.toString() ?? '',
        (m['size'] as num?)?.toInt() ?? 0,
        m['group']?.toString() ?? 'core',
      );
}

enum _Result { ok, network, server, notFound, shaMismatch, noSpace, sessionLost }

/// Ilova resurslari: serverdan (faqat login'dan keyin) yuklab olinadi va
/// <AppSupport>/resources/<asset yo'li> ga aynan shu nom bilan saqlanadi.
///
/// Ishonchlilik:
/// - har bir fayl `.part` ga yuklanadi, uzilsa `Range` bilan **davom ettiriladi**;
///   sha256 tekshirilgachgina asl nomiga ko'chiriladi — chala/buzilgan fayl ishlatilmaydi;
/// - tarmoq/server xatosida fayl **5 martagacha qayta uriniladi** (1, 2, 4, 8 s), aloqa yomon
///   bo'lsa parallel yuklashlar 2 taga tushadi;
/// - yuklashdan oldin bo'sh joy tekshiriladi, xotira to'lsa aniq xabar beriladi;
/// - ilova ochilganda diskdagi fayllar hajmi tekshiriladi, yo'qolgan/buzilganlari qayta yuklanadi;
/// - videolar va modellar orqa fonda mobil internetda ham (sozlamada "faqat Wi-Fi" yoqilsa — faqat Wi-Fi'da);
/// - iOS'da resurslar iCloud zaxirasiga kirmaydi.
class ResourceManager with WidgetsBindingObserver {
  ResourceManager._();

  /// Faqat testlar uchun: alohida nusxa
  @visibleForTesting
  ResourceManager.test();

  static final ResourceManager instance = ResourceManager._();

  /// Faqat testlar uchun: resurslar papkasi (path_provider o'rniga)
  @visibleForTesting
  static String? rootOverrideForTesting;

  static const String coreGroup = 'core';
  static const int _maxWorkers = 4;
  static const int _slowWorkers = 2;
  static const int _maxAttempts = 5;
  static const int _spaceMargin = 30 * 1024 * 1024;
  static const Duration _idleTimeout = Duration(seconds: 30);
  static const Duration _resumeCheckInterval = Duration(minutes: 5);

  /// Yuklash xato bilan to'xtasa — shuncha vaqtdan keyin o'zi qayta boshlanadi
  /// (oxirgisi takrorlanaveradi; internet yo'q bo'lsa ulanish qaytishi kutiladi)
  static const List<Duration> _autoRetryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
  ];
  static const MethodChannel _storageChannel = MethodChannel('uz.logosmart/storage');

  final ApiService _api = ApiService();
  final Connectivity _connectivity = Connectivity();

  Directory? _root;
  int _version = -1;
  bool _coreReady = false;
  final Map<String, _Entry> _local = {};

  /// Oxirgi olingan server manifesti (path -> entry)
  Map<String, _Entry>? _remote;
  int _remoteVersion = -1;

  final ValueNotifier<ResourceProgress> progress = ValueNotifier(const ResourceProgress());

  /// Asosiy guruh to'liq yuklanganda true bo'ladi (banner yashirinadi)
  final ValueNotifier<bool> coreReadyNotifier = ValueNotifier(false);

  /// Orqa fondagi yuklash holati (videolar, modellar, yangilanishlar ham)
  final ValueNotifier<ResourceStatus> status = ValueNotifier(const ResourceStatus());

  /// Wi-Fi kutib turgan videolar/modellarni hozir (mobil internetda) yuklash
  void downloadPendingNow() {
    _allowMobileOnce = true;
    syncInBackground(force: true);
  }

  bool _allowMobileOnce = false;

  /// [clearAll] chaqirilganda oshadi — o'sha paytda ketayotgan yuklashlar natijasi tashlab yuboriladi
  int _generation = 0;

  /// Qurilmadagi yuklangan resurslar hajmi (baytda)
  int get localBytes => _local.values.fold(0, (s, e) => s + e.size);

  /// Qurilmadagi yuklangan fayllar soni
  int get localFiles => _local.length;

  /// Yuklab olingan barcha resurslarni o'chiradi (qayta yuklashni sinash uchun).
  /// Shundan keyin ilova yuklash ekranini qayta ko'rsatadi.
  Future<void> clearAll() async {
    _generation++;
    _inflight.clear();
    _local.clear();
    _remote = null;
    _version = -1;
    _invalidated.clear();
    _allowMobileOnce = false;
    _retryTimer?.cancel();
    _autoRetries = 0;
    _setCoreReady(false);
    progress.value = const ResourceProgress();
    status.value = const ResourceStatus();
    final root = _root;
    if (root != null) {
      try {
        if (await root.exists()) await root.delete(recursive: true);
        await root.create(recursive: true);
        _excludeFromBackup(root.path);
      } catch (e) {
        debugPrint("Resurslarni o'chirishda xato: $e");
      }
    }
    await _saveManifest();
  }

  /// Asosiy resurslar qurilmada bormi (birinchi yuklash tugaganmi)
  bool get coreReady => _coreReady;

  /// Server manifesti shu sessiyada olinganmi
  bool get hasManifest => _remote != null;

  Future<void>? _syncing;
  DateTime? _lastCheck;
  final Map<String, Future<_Result>> _inflight = {};

  /// Bu sessiyada ochilmay qolgani uchun qayta yuklangan fayllar (cheksiz tsikl bo'lmasin)
  final Set<String> _invalidated = {};

  int _workerLimit = _maxWorkers;
  bool _onWifi = true;
  bool _online = true;
  Future<void> _saveChain = Future.value();
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  // Tezlikni hisoblash
  int _speedBytes = 0;
  DateTime _speedSince = DateTime.now();
  double _speed = 0;

  // ---------------------------------------------------------------------------
  // Ishga tushirish va qidirish
  // ---------------------------------------------------------------------------

  /// main() da runApp dan oldin chaqiriladi
  Future<void> init() async {
    final base = rootOverrideForTesting ?? (await getApplicationSupportDirectory()).path;
    _root = Directory('$base/resources');
    await _root!.create(recursive: true);
    _excludeFromBackup(_root!.path);
    try {
      final f = _manifestFile;
      if (await f.exists()) {
        final data = json.decode(await f.readAsString()) as Map<String, dynamic>;
        _version = (data['version'] as num?)?.toInt() ?? -1;
        _coreReady = data['coreReady'] == true;
        final files = Map<String, dynamic>.from(data['files'] as Map? ?? const {});
        files.forEach(
          (k, v) => _local[k] = _Entry.fromJson(Map<String, dynamic>.from(v as Map)),
        );
      }
    } catch (e) {
      // Manifest buzilgan bo'lsa — noldan (fayllar sha256 bo'yicha qayta tekshiriladi)
      debugPrint("Resurslar manifestini o'qib bo'lmadi: $e");
      _local.clear();
      _coreReady = false;
    }
    await _verifyLocalFiles();
    coreReadyNotifier.value = _coreReady;

    WidgetsBinding.instance.addObserver(this);
    _initConnectivity();
  }

  File get _manifestFile => File('${_root!.path}/manifest.json');

  /// Diskda yo'qolgan yoki hajmi mos kelmaydigan fayllar manifestdan chiqariladi —
  /// keyingi sinxronlashda qayta yuklanadi.
  Future<void> _verifyLocalFiles() async {
    final root = _root;
    if (root == null || _local.isEmpty) return;
    final broken = <String>[];
    for (final e in _local.entries) {
      try {
        final stat = await File('${root.path}/${e.key}').stat();
        if (stat.type == FileSystemEntityType.notFound || stat.size != e.value.size) {
          broken.add(e.key);
        }
      } catch (_) {
        broken.add(e.key);
      }
    }
    if (broken.isEmpty) return;
    debugPrint("Resurslar: ${broken.length} ta fayl yo'qolgan/buzilgan, qayta yuklanadi");
    for (final p in broken) {
      final entry = _local.remove(p);
      if (entry?.group == coreGroup) _coreReady = false;
    }
    _version = -1; // to'liq manifest qayta olinsin
    await _saveManifest();
  }

  /// Qurilmada yuklab olingan fayl (bo'lmasa null). Sinxron — widget build ichida ishlatiladi.
  File? fileFor(String path) {
    final root = _root;
    if (root == null) return null;
    final p = normalizeResourcePath(path);
    if (!_local.containsKey(p)) return null;
    return File('${root.path}/$p');
  }

  /// Fayl ochilmadi (dekodlash xatosi) — buzilgan deb hisoblab, qayta yuklaydi.
  /// Bir sessiyada bir fayl uchun bir marta.
  void reportBroken(String path) {
    final p = normalizeResourcePath(path);
    if (!_local.containsKey(p) || !_invalidated.add(p)) return;
    debugPrint("Resurs ochilmadi, qayta yuklanadi: $p");
    final file = fileFor(p);
    final entry = _local.remove(p);
    if (entry?.group == coreGroup) _setCoreReady(false);
    unawaited(() async {
      try {
        if (file != null && await file.exists()) await file.delete();
      } catch (_) {}
      await _saveManifest();
      await ensure(p);
    }());
  }

  /// Fayl qurilmada bo'lmasa (masalan video hali orqa fonda yuklanmagan) — darhol yuklab oladi.
  /// Serverda ham bo'lmasa yoki yuklab bo'lmasa null (unda APK ichidagi asset ishlatiladi).
  Future<File?> ensure(String path) async {
    final p = normalizeResourcePath(path);
    final existing = fileFor(p);
    if (existing != null) return existing;
    if (_remote == null) await _fetchManifest();
    if (_remote?[p] == null) return null;
    final r = await _downloadWithRetry(p);
    if (r == _Result.ok) await _saveManifest();
    return fileFor(p);
  }

  /// Ro'yxatdagi fayllarning qurilmada yo'q, lekin serverda bor bo'lganlari
  /// (level ochishdan oldin tekshirish uchun). Manifest hali olinmagan bo'lsa bo'sh ro'yxat.
  List<String> missingOf(Iterable<String> paths) {
    final remote = _remote;
    if (remote == null) return const [];
    final out = <String>{};
    for (final raw in paths) {
      final p = normalizeResourcePath(raw);
      if (!_local.containsKey(p) && remote.containsKey(p)) out.add(p);
    }
    return out.toList();
  }

  /// Level fayllarini darhol yuklab oladi. Hammasi tayyor bo'lsa true.
  Future<bool> ensureAll(Iterable<String> paths, {void Function(int done, int total)? onProgress}) async {
    if (_remote == null) await _fetchManifest();
    final missing = missingOf(paths);
    var done = 0;
    var allOk = true;
    onProgress?.call(0, missing.length);
    await Future.wait(missing.map((p) async {
      final r = await _downloadWithRetry(p);
      if (r != _Result.ok && r != _Result.notFound) allOk = false;
      onProgress?.call(++done, missing.length);
    }));
    if (missing.isNotEmpty) await _saveManifest();
    return allOk;
  }

  // ---------------------------------------------------------------------------
  // Sinxronlash
  // ---------------------------------------------------------------------------

  /// Birinchi yuklash (yuklash ekrani): "core" guruhi to'liq yuklanguncha kutadi.
  /// true — tayyor, false — xato ([progress].error da sabab).
  Future<bool> downloadCore() async {
    // Yuklash ekranidagi "ilovaga kirish" yoki internet qaytishi shu paytda
    // syncInBackground(force) chaqirishi mumkin — ikkinchi parallel core
    // yuklash boshlanmasin (progress ikki joydan yozilib "sakrab" turardi)
    final running = _syncing;
    if (running != null) {
      await running;
      if (_coreReady) return true;
    }
    final completer = Completer<void>();
    _syncing = completer.future;
    var ok = false;
    try {
      ok = await _downloadCoreInner();
      return ok;
    } finally {
      _syncing = null;
      completer.complete();
      // Videolar va modellar orqa fonda — _syncing bo'shagandan keyingina,
      // aks holda syncInBackground band deb hech narsa qilmasdi
      if (ok) syncInBackground(force: true);
    }
  }

  Future<bool> _downloadCoreInner() async {
    progress.value = const ResourceProgress();
    if (!await _fetchManifest()) {
      _reportError(
        _lastManifestStatus != null && _lastManifestStatus! >= 500 ? _Result.server : _Result.network,
      );
      return false;
    }
    final ok = await _downloadGroups({coreGroup});
    if (ok) {
      _setCoreReady(true);
      await _saveManifest();
    }
    return ok;
  }

  /// Orqa fonda to'liq sinxronlash: yangilangan fayllar, videolar va modellar.
  /// Birinchi yuklash o'tkazib yuborilgan bo'lsa ham ishlaydi (asosiy guruhni ham yuklaydi).
  void syncInBackground({bool force = false}) {
    if (!force && _lastCheck != null && DateTime.now().difference(_lastCheck!) < _resumeCheckInterval) {
      return;
    }
    if (_syncing != null) return;
    _retryTimer?.cancel();
    final gen = _generation;
    _syncing = _syncAll().then((finished) {
      if (gen != _generation) return; // resurslar o'chirildi — yangi yuklash boshlanadi
      if (finished) {
        _autoRetries = 0;
      } else {
        _scheduleAutoRetry();
      }
    }).whenComplete(() {
      _syncing = null;
    });
  }

  Timer? _retryTimer;
  int _autoRetries = 0;

  /// Faqat testlar uchun: avtomatik qayta urinish kutish vaqtlari
  @visibleForTesting
  List<Duration>? autoRetryDelaysForTesting;

  /// Yuklash xato bilan to'xtadi — foydalanuvchi tugma bosishini kutmasdan
  /// o'zi qayta urinadi. Joy yetmasa urinmaydi (foydalanuvchi bo'shatishi kerak);
  /// internet yo'q bo'lsa — ulanish qaytganda [_initConnectivity] davom ettiradi.
  void _scheduleAutoRetry() {
    _retryTimer?.cancel();
    if (progress.value.errorKind == ResourceErrorKind.noSpace) return;
    if (!_online) return;
    final delays = autoRetryDelaysForTesting ?? _autoRetryDelays;
    final delay = delays[math.min(_autoRetries, delays.length - 1)];
    _autoRetries++;
    _retryTimer = Timer(delay, () => syncInBackground(force: true));
  }

  /// true — hammasi yuklandi (yoki "faqat Wi-Fi" sababli Wi-Fi kutilyapti);
  /// false — xato bilan to'xtadi, qayta urinish kerak.
  Future<bool> _syncAll() async {
    _lastCheck = DateTime.now();
    if (await TokenStorage().getAccessToken() == null) return true;
    if (!await _fetchManifest(useVersion: true)) {
      _reportError(
        _lastManifestStatus != null && _lastManifestStatus! >= 500 ? _Result.server : _Result.network,
      );
      return false;
    }
    final remote = _remote;
    if (remote == null) return false;

    // Avval asosiy guruh (yangilangan bo'lishi mumkin)
    if (!await _downloadGroups({coreGroup})) return false;
    _setCoreReady(true);
    await _saveManifest();

    // Katta guruhlar — mobil internetda ham; sozlamada "faqat Wi-Fi" yoqilgan
    // bo'lsa Wi-Fi kutiladi
    final bigGroups = {for (final e in remote.values) e.group}..remove(coreGroup);
    var allDone = true;
    var waitingWifi = false;
    if (bigGroups.isNotEmpty) {
      if (_onWifi || !AppSettings().wifiOnlyDownload || _allowMobileOnce) {
        allDone = await _downloadGroups(bigGroups);
        if (allDone) _allowMobileOnce = false;
      } else {
        final pending = [for (final g in bigGroups) ..._missingInGroup(g)];
        allDone = pending.isEmpty;
        waitingWifi = !allDone;
        if (!allDone) {
          status.value = ResourceStatus(
            phase: ResourcePhase.waitingWifi,
            groups: {for (final p in pending) remote[p]!.group},
            pendingBytes: pending.fold<int>(0, (s, p) => s + (remote[p]?.size ?? 0)),
          );
        }
      }
    }
    if (allDone) {
      await _cleanupPartials();
      if (_version != _remoteVersion) {
        _version = _remoteVersion;
        await _saveManifest();
      }
    }
    return allDone || waitingWifi;
  }

  int? _lastManifestStatus;

  /// Manifestni oladi va serverda o'chirilgan fayllarni qurilmadan ham o'chiradi.
  /// [useVersion] — versiya o'zgarmagan bo'lsa (304) qo'shimcha ish qilinmaydi.
  /// Tarmoq/server xatosida 3 marta qayta urinadi.
  Future<bool> _fetchManifest({bool useVersion = false}) async {
    Map<String, dynamic>? data;
    for (var attempt = 0; attempt < 3 && data == null; attempt++) {
      if (attempt > 0) await Future.delayed(Duration(seconds: 1 << attempt));
      data = await _api.getResourceManifest(
        version: useVersion && _remote != null ? _version : null,
      );
    }
    _lastManifestStatus = data == null ? _api.lastResourceManifestStatus : 200;
    if (data == null) return false;
    if (data['notModified'] == true) return true;

    final files = <String, _Entry>{};
    for (final f in (data['files'] as List? ?? const [])) {
      if (f is! Map) continue;
      final path = f['path']?.toString();
      if (path == null) continue;
      files[path] = _Entry.fromJson(Map<String, dynamic>.from(f));
    }
    _remote = files;
    _remoteVersion = (data['version'] as num?)?.toInt() ?? -1;

    final removed = _local.keys.where((p) => !files.containsKey(p)).toList();
    for (final p in removed) {
      final file = fileFor(p);
      _local.remove(p);
      try {
        if (file != null && await file.exists()) await file.delete();
      } catch (_) {}
    }
    if (removed.isNotEmpty) await _saveManifest();
    return true;
  }

  List<String> _missingInGroup(String group) => [
        for (final e in (_remote ?? const <String, _Entry>{}).entries)
          if (e.value.group == group && _local[e.key]?.sha256 != e.value.sha256) e.key,
      ];

  /// Guruh(lar)dagi yangi yoki o'zgargan fayllarni yuklaydi. Hammasi muvaffaqiyatli bo'lsa true.
  Future<bool> _downloadGroups(Set<String> groups) async {
    final remote = _remote;
    if (remote == null) return false;
    final queue = [for (final g in groups) ..._missingInGroup(g)];
    if (queue.isEmpty) {
      progress.value = const ResourceProgress(doneFiles: 1, totalFiles: 1);
      return true;
    }

    final totalBytes = queue.fold<int>(0, (s, p) => s + (remote[p]?.size ?? 0));

    // Bo'sh joy: yetmasa boshlamaymiz ham
    final free = await _freeBytes();
    if (free != null && free < totalBytes + _spaceMargin) {
      _reportError(_Result.noSpace, needBytes: totalBytes + _spaceMargin - free);
      return false;
    }

    var doneFiles = 0, doneBytes = 0, sinceSave = 0;
    _Result? stop;
    _resetSpeed();
    _workerLimit = _maxWorkers;
    void report({bool retrying = false}) {
      progress.value = ResourceProgress(
        doneFiles: doneFiles,
        totalFiles: queue.length,
        doneBytes: doneBytes,
        totalBytes: totalBytes,
        bytesPerSecond: _speed,
        retrying: retrying,
      );
      status.value = ResourceStatus(
        phase: ResourcePhase.downloading,
        groups: groups,
        progress: progress.value,
      );
    }

    report();
    var next = 0;
    Future<void> worker(int id) async {
      // Aloqa yomonlashsa ortiqcha worker'lar to'xtaydi (_workerLimit kamayadi)
      while (stop == null && next < queue.length && id < _workerLimit) {
        final path = queue[next++];
        final r = await _downloadWithRetry(path, onRetry: () => report(retrying: true));
        if (r == _Result.ok || r == _Result.notFound) {
          doneFiles++;
          doneBytes += remote[path]?.size ?? 0;
          report();
          if (++sinceSave >= 25) {
            sinceSave = 0;
            await _saveManifest();
          }
        } else {
          stop = r;
        }
      }
    }

    await Future.wait(List.generate(_maxWorkers, worker));
    // Worker'lar kamayib, navbatda fayl qolgan bo'lsa — qolganini bitta-bitta
    while (stop == null && next < queue.length) {
      await worker(0);
    }
    await _saveManifest();
    if (stop != null) {
      if (stop != _Result.sessionLost) {
        _reportError(stop!, needBytes: totalBytes - doneBytes);
        status.value = ResourceStatus(phase: ResourcePhase.failed, groups: groups, progress: progress.value);
      } else {
        status.value = const ResourceStatus();
      }
      return false;
    }
    status.value = const ResourceStatus();
    return true;
  }

  /// Bitta faylni qayta urinishlar bilan yuklaydi. Bir fayl bir vaqtda bir marta yuklanadi.
  Future<_Result> _downloadWithRetry(String path, {VoidCallback? onRetry}) {
    // Diqqat: callback blok bo'lishi shart — `() => _inflight.remove(path)` o'chirilgan
    // Future'ning o'zini qaytaradi va whenComplete uni (ya'ni o'zini) kutib qotib qoladi
    final existing = _inflight[path];
    if (existing != null) return existing;
    late final Future<_Result> f;
    f = _retryLoop(path, onRetry).whenComplete(() {
      // clearAll() dan keyin shu yo'l uchun yangi yuklash boshlangan bo'lishi mumkin — uni o'chirmaymiz
      if (identical(_inflight[path], f)) _inflight.remove(path);
    });
    return _inflight[path] = f;
  }

  Future<_Result> _retryLoop(String path, VoidCallback? onRetry) async {
    var refetched = false;
    final gen = _generation;
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      // Resurslar o'chirildi — bu yuklash endi kerak emas (jim to'xtaydi)
      if (gen != _generation) return _Result.sessionLost;
      final entry = _remote?[path];
      if (entry == null) return _Result.notFound;
      if (_local[path]?.sha256 == entry.sha256) return _Result.ok;

      final r = await _downloadOnce(path, entry);
      switch (r) {
        case _Result.ok:
        case _Result.noSpace:
        case _Result.sessionLost:
          return r;
        case _Result.notFound:
        case _Result.shaMismatch:
          // Admin faylni o'chirgan/almashtirgan bo'lishi mumkin — manifestni bir marta yangilaymiz
          if (refetched) return r == _Result.notFound ? _Result.notFound : _Result.shaMismatch;
          refetched = true;
          await _fetchManifest();
          continue;
        case _Result.network:
        case _Result.server:
          if (attempt == _maxAttempts - 1) return r;
          // Aloqa yomon — parallel yuklashlarni kamaytiramiz
          _workerLimit = _slowWorkers;
          onRetry?.call();
          final jitter = math.Random().nextInt(500);
          await Future.delayed(Duration(milliseconds: (1000 << attempt) + jitter));
      }
    }
    return _Result.network;
  }

  /// Bitta urinish. `.part` (sha256 bo'yicha nomlangan) bor bo'lsa — Range bilan davom ettiradi.
  Future<_Result> _downloadOnce(String path, _Entry entry) async {
    final gen = _generation;
    final root = _root;
    if (root == null) return _Result.network;
    final target = File('${root.path}/$path');
    final part = File('${target.path}.${entry.sha256.substring(0, math.min(12, entry.sha256.length))}.part');
    IOSink? sink;
    try {
      await target.parent.create(recursive: true);
      var from = await part.exists() ? await part.length() : 0;
      if (from > entry.size) {
        await part.delete();
        from = 0;
      }

      if (from < entry.size || entry.size == 0) {
        final response = await _api.openResourceStream(path, from: from);
        final status = response.statusCode ?? 0;
        if (status == 416) {
          // Saqlangan qism yaroqsiz — keyingi urinishda noldan
          await part.delete();
          return _Result.network;
        }
        final append = status == 206 && from > 0;
        sink = part.openWrite(mode: append ? FileMode.append : FileMode.write);
        final body = response.data;
        if (body == null) return _Result.network;
        // Ma'lumot 30 soniya kelmasa — uzilgan deb hisoblaymiz (qism saqlanib qoladi)
        await for (final chunk in body.stream.timeout(_idleTimeout)) {
          sink.add(chunk);
          _addSpeedSample(chunk.length);
        }
        await sink.flush();
        await sink.close();
        sink = null;
      }

      final digest = await sha256.bind(part.openRead()).first;
      if (digest.toString() != entry.sha256) {
        debugPrint("Resurs buzilgan (sha256 mos emas): $path");
        await part.delete();
        return _Result.shaMismatch;
      }
      final replaced = _local.containsKey(path);
      if (gen != _generation) {
        // Yuklash davomida resurslar o'chirildi — natijani saqlamaymiz
        await part.delete();
        return _Result.sessionLost;
      }
      await part.rename(target.path);
      _local[path] = entry;
      _invalidated.remove(path);
      // Almashtirilgan rasmning eski nusxasi keshda qolib ketmasin
      if (replaced) PaintingBinding.instance.imageCache.evict(FileImage(target));
      return _Result.ok;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) return _Result.notFound;
      if (status == 401 || status == 403) return _Result.sessionLost;
      if (status != null && status >= 500) return _Result.server;
      return _Result.network;
    } on TimeoutException {
      return _Result.network;
    } on FileSystemException catch (e) {
      // ENOSPC (28) — xotira to'ldi
      if (e.osError?.errorCode == 28) return _Result.noSpace;
      debugPrint("Resursni saqlashda xato ($path): $e");
      return _Result.network;
    } catch (e) {
      debugPrint("Resursni yuklashda xato ($path): $e");
      return _Result.network;
    } finally {
      try {
        await sink?.close();
      } catch (_) {}
    }
  }

  /// Tugallanmagan, endi kerak bo'lmagan `.part` fayllarini o'chiradi
  Future<void> _cleanupPartials() async {
    final root = _root;
    if (root == null) return;
    try {
      await for (final f in root.list(recursive: true)) {
        if (f is File && f.path.endsWith('.part')) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  void _reportError(_Result r, {int needBytes = 0}) {
    final p = progress.value;
    final (kind, message) = switch (r) {
      _Result.noSpace => (
          ResourceErrorKind.noSpace,
          "Telefon xotirasida joy yetarli emas. Yana taxminan "
              "${(needBytes / (1024 * 1024)).ceil()} MB bo'shating va qayta urinib ko'ring.",
        ),
      _Result.server => (
          ResourceErrorKind.server,
          "Server vaqtincha ishlamayapti. Birozdan keyin qayta urinib ko'ring.",
        ),
      _Result.shaMismatch => (
          ResourceErrorKind.other,
          "Fayllar buzilib kelyapti. Internetni almashtirib (masalan Wi-Fi), qayta urinib ko'ring.",
        ),
      _ => (
          ResourceErrorKind.network,
          "Internet aloqasi yo'q yoki juda sekin. Ulanishni tekshirib, qayta urinib ko'ring.",
        ),
    };
    progress.value = ResourceProgress(
      doneFiles: p.doneFiles,
      totalFiles: p.totalFiles,
      doneBytes: p.doneBytes,
      totalBytes: p.totalBytes,
      error: message,
      errorKind: kind,
    );
  }

  void _setCoreReady(bool value) {
    _coreReady = value;
    coreReadyNotifier.value = value;
  }

  // --- tezlik ---
  void _resetSpeed() {
    _speedBytes = 0;
    _speedSince = DateTime.now();
    _speed = 0;
  }

  void _addSpeedSample(int bytes) {
    _speedBytes += bytes;
    final ms = DateTime.now().difference(_speedSince).inMilliseconds;
    if (ms >= 1500) {
      final current = _speedBytes * 1000 / ms;
      _speed = _speed == 0 ? current : _speed * 0.6 + current * 0.4;
      _speedBytes = 0;
      _speedSince = DateTime.now();
    }
  }

  // --- qurilma ---
  Future<int?> _freeBytes() async {
    try {
      final v = await _storageChannel.invokeMethod<num>('freeBytes');
      return v?.toInt();
    } catch (_) {
      return null; // aniqlab bo'lmasa — tekshirmaymiz (ENOSPC baribir ushlanadi)
    }
  }

  void _excludeFromBackup(String path) {
    if (!Platform.isIOS) return; // Android: backup_rules.xml
    _storageChannel.invokeMethod('excludeFromBackup', {'path': path}).catchError((_) => null);
  }

  void _initConnectivity() {
    void read(List<ConnectivityResult> r) {
      _onWifi = r.contains(ConnectivityResult.wifi) || r.contains(ConnectivityResult.ethernet);
      _online = r.any((c) => c != ConnectivityResult.none);
    }

    void apply(List<ConnectivityResult> r) {
      final wasWifi = _onWifi, wasOnline = _online;
      read(r);
      // Internet qaytdi yoki Wi-Fi'ga ulandi — to'xtab qolgan yuklashlar davom etsin
      if (_online && (!wasOnline || (_onWifi && !wasWifi))) {
        _autoRetries = 0;
        syncInBackground(force: true);
      }
    }

    _connectivity.checkConnectivity().then(read).catchError((_) {});
    _connSub = _connectivity.onConnectivityChanged.listen(apply, onError: (_) {});
  }

  /// Hozir mobil internetdami (yuklash ekranida ogohlantirish uchun)
  bool get onMobileData => !_onWifi;

  /// Manifest yozuvlari navbat bilan (bir vaqtda ikkitasi bir faylga yozmasin)
  Future<void> _saveManifest() => _saveChain = _saveChain.then((_) => _writeManifest());

  Future<void> _writeManifest() async {
    final root = _root;
    if (root == null) return;
    try {
      final data = json.encode({
        'version': _version,
        'coreReady': _coreReady,
        'files': _local.map((k, v) => MapEntry(k, v.toJson())),
      });
      final tmp = File('${_manifestFile.path}.tmp');
      await tmp.writeAsString(data, flush: true);
      await tmp.rename(_manifestFile.path);
    } catch (e) {
      debugPrint("Resurslar manifestini saqlab bo'lmadi: $e");
    }
  }

  // Fondan qaytganda yangilanishlarni tekshirish
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Yuklash tugamay qolgan bo'lsa — ilovaga qaytilishi bilan davom etadi
    final unfinished = status.value.phase == ResourcePhase.failed;
    syncInBackground(force: unfinished);
  }

  /// Faqat testlar uchun: orqa fondagi sinxronlash tugashini kutish
  @visibleForTesting
  Future<void> idle() async {
    while (_syncing != null) {
      await _syncing;
    }
  }

  @visibleForTesting
  void dispose() {
    _connSub?.cancel();
    _retryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
