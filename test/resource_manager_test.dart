import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logosmart/core/network/api_service.dart';
import 'package:logosmart/core/resources/resource_manager.dart';

/// Lokal soxta resurs serveri: manifest + fayllar, Range qo'llab-quvvatlanadi.
/// Har bir fayl uchun "yomon xulq" berish mumkin: aloqani yarmida uzish, 503, buzilgan bayt.
class FakeResourceServer {
  late HttpServer server;
  final Map<String, List<int>> files = {};
  final Map<String, String> groups = {};

  /// path -> nechta so'rovda faylni yarmida uzish
  final Map<String, int> dropMidway = {};

  /// path -> nechta so'rovda 503 qaytarish
  final Map<String, int> fail503 = {};

  /// path -> doim buzilgan bayt yuborish (manifestdagi sha256 bilan mos kelmaydi)
  final Set<String> corrupt = {};

  int manifestFailures = 0;
  final List<String> rangeHeaders = [];
  final Map<String, int> fileRequests = {};
  int version = 1;

  String get baseUrl => 'http://127.0.0.1:${server.port}/api/v1/';

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
  }

  Future<void> stop() => server.close(force: true);

  void put(String path, List<int> bytes, {String group = 'core'}) {
    files[path] = bytes;
    groups[path] = group;
    version++;
  }

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    final path = req.uri.path;
    if (path.endsWith('/resources/manifest')) {
      if (manifestFailures > 0) {
        manifestFailures--;
        res.statusCode = 503;
        await res.close();
        return;
      }
      final v = int.tryParse(req.uri.queryParameters['version'] ?? '');
      if (v == version) {
        res.statusCode = 304;
        await res.close();
        return;
      }
      res.headers.contentType = ContentType.json;
      res.write(json.encode({
        'version': version,
        'totalSize': files.values.fold<int>(0, (s, b) => s + b.length),
        'files': [
          for (final e in files.entries)
            {
              'path': e.key,
              'sha256': sha256.convert(e.value).toString(),
              'size': e.value.length,
              'group': groups[e.key],
            },
        ],
      }));
      await res.close();
      return;
    }
    if (path.endsWith('/resources/file')) {
      final p = req.uri.queryParameters['path']!;
      fileRequests[p] = (fileRequests[p] ?? 0) + 1;
      final bytes = files[p];
      if (bytes == null) {
        res.statusCode = 404;
        await res.close();
        return;
      }
      if ((fail503[p] ?? 0) > 0) {
        fail503[p] = fail503[p]! - 1;
        res.statusCode = 503;
        await res.close();
        return;
      }
      var body = corrupt.contains(p) ? List<int>.filled(bytes.length, 7) : bytes;
      final range = req.headers.value('range');
      if (range != null) {
        rangeHeaders.add('$p $range');
        final from = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
        res.statusCode = 206;
        body = body.sublist(from);
      }
      if ((dropMidway[p] ?? 0) > 0) {
        dropMidway[p] = dropMidway[p]! - 1;
        // Yarmini yuborib, ulanishni uzamiz (mobil internet uzilishi)
        res.contentLength = body.length;
        final socket = await res.detachSocket(); // sarlavhalar yoziladi
        socket.add(body.sublist(0, body.length ~/ 2));
        await socket.flush();
        socket.destroy();
        return;
      }
      res.contentLength = body.length;
      res.add(body);
      await res.close();
      return;
    }
    res.statusCode = 404;
    await res.close();
  }
}

List<int> bytesOf(int n, int seed) => List<int>.generate(n, (i) => (i * 31 + seed) % 256);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeResourceServer srv;
  late Directory dir;
  final managers = <ResourceManager>[];

  setUpAll(() {
    // flutter_test haqiqiy HTTP'ni bloklaydi — lokal server uchun ochamiz
    HttpOverrides.global = null;
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'test-token'});
    srv = FakeResourceServer();
    await srv.start();
    ApiService().baseUrlForTesting = srv.baseUrl;
    dir = await Directory.systemTemp.createTemp('res_test_');
    ResourceManager.rootOverrideForTesting = dir.path;
  });

  tearDown(() async {
    // Orqa fondagi sinxronlash keyingi testning serveriga so'rov yubormasin
    for (final m in managers) {
      await m.idle();
      m.dispose();
    }
    managers.clear();
    await srv.stop();
    await dir.delete(recursive: true);
  });

  Future<ResourceManager> fresh() async {
    final m = ResourceManager.test();
    managers.add(m);
    await m.init();
    return m;
  }

  File local(String path) => File('${dir.path}/resources/$path');

  test('birinchi yuklash: fayllar aynan shu yo\'l va nom bilan saqlanadi', () async {
    srv.put('assets/game/a.webp', bytesOf(5000, 1));
    srv.put('assets/sound/cooking/Yeguliklarni ustiga bos.mp3', bytesOf(7000, 2));
    srv.put('assets/videos/map_video/r.mp4', bytesOf(9000, 3), group: 'videos');

    final m = await fresh();
    expect(m.coreReady, isFalse);
    expect(await m.downloadCore(), isTrue);
    expect(m.coreReady, isTrue);

    expect(await local('assets/game/a.webp').readAsBytes(), bytesOf(5000, 1));
    expect(await local('assets/sound/cooking/Yeguliklarni ustiga bos.mp3').readAsBytes(), bytesOf(7000, 2));
    expect(m.fileFor('game/a.webp')?.path, local('assets/game/a.webp').path, reason: 'AssetSource uslubidagi yo\'l');

    // Qayta ochilganda (yangi nusxa) — manifestdan tiklanadi, qayta yuklanmaydi
    final before = srv.fileRequests['assets/game/a.webp'];
    final m2 = await fresh();
    expect(m2.coreReady, isTrue);
    expect(m2.fileFor('assets/game/a.webp'), isNotNull);
    expect(srv.fileRequests['assets/game/a.webp'], before);
  });

  test('aloqa fayl o\'rtasida uzilsa — Range bilan qolgan joyidan davom etadi', () async {
    final big = bytesOf(200000, 9);
    srv.put('assets/game/big.webp', big);
    srv.dropMidway['assets/game/big.webp'] = 1;

    final m = await fresh();
    expect(await m.downloadCore(), isTrue);
    expect(await local('assets/game/big.webp').readAsBytes(), big);
    expect(srv.rangeHeaders.single, startsWith('assets/game/big.webp bytes='));
    expect(srv.rangeHeaders.single, isNot(endsWith('bytes=0-')));
    // .part qolmagan
    expect(dir.listSync(recursive: true).where((f) => f.path.endsWith('.part')), isEmpty);
  });

  test('server vaqtincha 503 qaytarsa — qayta urinib, yuklab oladi', () async {
    srv.put('assets/game/x.webp', bytesOf(3000, 4));
    srv.fail503['assets/game/x.webp'] = 2;
    srv.manifestFailures = 1;

    final m = await fresh();
    expect(await m.downloadCore(), isTrue);
    expect(srv.fileRequests['assets/game/x.webp'], 3);
  });

  test('buzilgan fayl hech qachon saqlanmaydi, aniq xato beriladi', () async {
    srv.put('assets/game/ok.webp', bytesOf(1000, 5));
    srv.put('assets/game/bad.webp', bytesOf(1000, 6));
    srv.corrupt.add('assets/game/bad.webp');

    final m = await fresh();
    expect(await m.downloadCore(), isFalse);
    expect(m.coreReady, isFalse);
    expect(m.fileFor('assets/game/bad.webp'), isNull);
    expect(local('assets/game/bad.webp').existsSync(), isFalse);
    expect(m.progress.value.errorKind, ResourceErrorKind.other);
    expect(m.status.value.phase, ResourcePhase.failed, reason: "Bosh sahifadagi karta \"to'xtadi\" ko'rsatadi");

    // Admin to'g'ri faylni yuklasa — qayta urinishda tayyor
    srv.corrupt.clear();
    srv.version++;
    expect(await m.downloadCore(), isTrue);
    expect(await local('assets/game/bad.webp').readAsBytes(), bytesOf(1000, 6));
    await m.idle();
    expect(m.status.value.phase, ResourcePhase.idle, reason: 'hammasi yuklangach karta yashirinadi');
  });

  test("orqa fondagi yuklash xato bilan to'xtasa — tugma bosilmasa ham o'zi davom etadi", () async {
    srv.put('assets/game/a.webp', bytesOf(1000, 1));
    srv.put('assets/videos/v.mp4', bytesOf(4000, 2), group: 'videos');
    srv.corrupt.add('assets/videos/v.mp4');

    final m = await fresh();
    m.autoRetryDelaysForTesting = const [Duration(milliseconds: 50)];
    expect(await m.downloadCore(), isTrue);
    await m.idle();
    expect(m.status.value.phase, ResourcePhase.failed);
    expect(m.fileFor('assets/videos/v.mp4'), isNull);

    // Server tuzaldi — hech narsa chaqirmaymiz, yuklash o'zi qayta boshlanadi
    srv.corrupt.clear();
    srv.version++;
    for (var i = 0; i < 100 && m.fileFor('assets/videos/v.mp4') == null; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      await m.idle();
    }
    expect(await local('assets/videos/v.mp4').readAsBytes(), bytesOf(4000, 2));
    expect(m.status.value.phase, ResourcePhase.idle);
  });

  test('internet yo\'q bo\'lsa — tarmoq xatosi, yuklangan fayllar saqlanib qoladi', () async {
    srv.put('assets/game/a.webp', bytesOf(1000, 1));
    final m = await fresh();
    expect(await m.downloadCore(), isTrue);

    await srv.stop(); // server "yo'qoldi"
    final m2 = await fresh();
    expect(await m2.downloadCore(), isFalse);
    expect(m2.progress.value.errorKind, ResourceErrorKind.network);
    expect(m2.coreReady, isTrue, reason: 'avval yuklanganlar ishlayveradi');
    expect(m2.fileFor('assets/game/a.webp'), isNotNull);
    await srv.start(); // tearDown uchun
  });

  test('admin almashtirsa — yangisi yuklanadi; o\'chirsa — qurilmadan ham o\'chadi', () async {
    srv.put('assets/game/a.webp', bytesOf(1000, 1));
    srv.put('assets/game/old.webp', bytesOf(1000, 2));
    final m = await fresh();
    expect(await m.downloadCore(), isTrue);

    srv.put('assets/game/a.webp', bytesOf(1200, 77)); // almashtirildi
    srv.files.remove('assets/game/old.webp'); // o'chirildi
    srv.version++;

    m.syncInBackground(force: true);
    await Future.delayed(const Duration(milliseconds: 50));
    for (var i = 0; i < 100 && local('assets/game/old.webp').existsSync(); i++) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    for (var i = 0; i < 100 && (await local('assets/game/a.webp').length()) != 1200; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    expect(await local('assets/game/a.webp').readAsBytes(), bytesOf(1200, 77));
    expect(local('assets/game/old.webp').existsSync(), isFalse);
    expect(m.fileFor('assets/game/old.webp'), isNull);
  });

  test('diskdan fayl yo\'qolsa — ilova ochilganda aniqlanadi va qayta yuklanadi', () async {
    srv.put('assets/game/a.webp', bytesOf(1000, 1));
    srv.put('assets/game/b.webp', bytesOf(1000, 2));
    final m = await fresh();
    expect(await m.downloadCore(), isTrue);

    await local('assets/game/b.webp').delete();
    await local('assets/game/a.webp').writeAsBytes(bytesOf(10, 0)); // hajmi buzildi

    final m2 = await fresh();
    expect(m2.fileFor('assets/game/b.webp'), isNull);
    expect(m2.fileFor('assets/game/a.webp'), isNull);
    expect(m2.coreReady, isFalse);
    expect(await m2.downloadCore(), isTrue);
    expect(await local('assets/game/a.webp').readAsBytes(), bytesOf(1000, 1));
    expect(await local('assets/game/b.webp').readAsBytes(), bytesOf(1000, 2));
  });

  test('ensure: hali yuklanmagan video so\'ralganda shu zahoti yuklanadi', () async {
    srv.put('assets/game/a.webp', bytesOf(100, 1));
    srv.put('assets/videos/map_video/r.mp4', bytesOf(50000, 3), group: 'videos');
    final m = await fresh();
    expect(await m.downloadCore(), isTrue);

    final f = await m.ensure('assets/videos/map_video/r.mp4');
    expect(f, isNotNull);
    expect(await f!.readAsBytes(), bytesOf(50000, 3));
    expect(await m.ensure('assets/videos/yoq.mp4'), isNull, reason: 'serverda yo\'q — APK ga qaytadi');
  });

  test('ensureAll: level fayllaridan faqat yetishmaganlari yuklanadi', () async {
    srv.put('assets/game/a.webp', bytesOf(100, 1));
    srv.put('assets/sound/x.mp3', bytesOf(100, 2));
    final m = await fresh();
    expect(m.missingOf(['assets/game/a.webp']), isEmpty, reason: 'manifest hali yo\'q');
    expect(await m.ensureAll(['game/a.webp', 'sound/x.mp3', 'assets/icons/apkda.webp']), isTrue);
    expect(m.fileFor('assets/sound/x.mp3'), isNotNull);
    expect(m.missingOf(['assets/game/a.webp', 'sound/x.mp3']), isEmpty);
  });

  test('xotira yetmasa — yuklash boshlanmaydi, kerakli hajm aytiladi', () async {
    srv.put('assets/videos/map_video/r.mp4', bytesOf(1000, 1));
    const channel = MethodChannel('uz.logosmart/storage');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async => call.method == 'freeBytes' ? 1024 : true);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final m = await fresh();
    expect(await m.downloadCore(), isFalse);
    expect(m.progress.value.errorKind, ResourceErrorKind.noSpace);
    expect(m.progress.value.error, contains('MB'));
    expect(srv.fileRequests, isEmpty, reason: "joy yo'q — so'rov ham yuborilmaydi");
  });

  test("clearAll: hammasi o'chadi va qaytadan yuklab olinadi", () async {
    srv.put('assets/game/a.webp', bytesOf(4000, 1));
    srv.put('assets/videos/v.mp4', bytesOf(9000, 2), group: 'videos');
    final m = await fresh();
    expect(await m.downloadCore(), isTrue);
    await m.idle();
    expect(m.localFiles, 2);
    expect(m.localBytes, 13000);

    await m.clearAll();
    expect(m.coreReady, isFalse);
    expect(m.localFiles, 0);
    expect(m.fileFor('assets/game/a.webp'), isNull);
    expect(local('assets/game/a.webp').existsSync(), isFalse);

    // Ilova qayta ochilsa ham bo'sh
    final m2 = await fresh();
    expect(m2.coreReady, isFalse);
    expect(m2.localFiles, 0);

    // Qayta yuklash
    expect(await m.downloadCore(), isTrue);
    expect(await local('assets/game/a.webp').readAsBytes(), bytesOf(4000, 1));
  });

  test("clearAll yuklash o'rtasida chaqirilsa — eski yuklash natijasi qaytib kelmaydi", () async {
    srv.put('assets/game/big.webp', bytesOf(300000, 5));
    srv.dropMidway['assets/game/big.webp'] = 1; // birinchi urinish uzilib, qayta urinish kutadi
    final m = await fresh();
    final first = m.downloadCore();
    await Future.delayed(const Duration(milliseconds: 300));
    await m.clearAll();
    expect(await first, isFalse);
    await Future.delayed(const Duration(seconds: 2));
    expect(m.fileFor('assets/game/big.webp'), isNull);
    expect(local('assets/game/big.webp').existsSync(), isFalse);
    // Yangidan yuklash ishlaydi
    expect(await m.downloadCore(), isTrue);
    expect(await local('assets/game/big.webp').readAsBytes(), bytesOf(300000, 5));
  });
}
