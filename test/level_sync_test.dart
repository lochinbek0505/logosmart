import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:logosmart/core/network/api_service.dart';
import 'package:logosmart/core/network/network_status.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';

/// Soxta backend: tovush mashqlari, /games, /first-speech, yulduzlar va ball.
/// [offline] = true bo'lsa har bir so'rovda ulanish uziladi (internet yo'q).
class FakeBackend {
  late HttpServer server;
  bool offline = false;

  /// Bo'limlar: path -> (practiceId, levellar soni). Bo'lmasa — 404.
  final Map<String, (String, int)> sections = {
    'games': ('vpG', 5),
    'first-speech': ('vpF', 42),
  };

  /// Tovush mashqlari: practiceId -> levellar soni
  final Map<String, int> sounds = {'vpR': 4};

  /// Bo'lim levellari aniq berilsa (masalan haqiqiy JSON fayldan) — shular qaytadi
  final Map<String, List<Map<String, dynamic>>> sectionLevels = {};

  /// Pullik (obunasiz yopiq) levellar: mongo id
  final Set<String> paidLevels = {};

  /// Server progressi: level mongo id -> yulduz (eng yuqorisi)
  final Map<String, int> stars = {};

  /// Yulduzlar tarixi (eng yangisi birinchi): voicePracticeId
  final List<String> history = [];

  int ball = 0;
  final Set<String> ballEventIds = {};

  /// Ball hodisalarini qabul qilib, javobni yubormasdan ulanishni uzish
  /// (javob yo'qolgan holat) — necha marta
  int dropBallResponse = 0;

  final List<String> requests = [];

  String get baseUrl => 'http://127.0.0.1:${server.port}/api/v1/';

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
  }

  Future<void> stop() => server.close(force: true);

  static String levelId(String practiceId, int order) => '$practiceId-$order';

  List<Map<String, dynamic>> levelsOf(String practiceId, int count) {
    return [
      for (var i = 1; i <= count; i++)
        () {
          final id = levelId(practiceId, i);
          final prevPlayed = i > 1 && stars.containsKey(levelId(practiceId, i - 1));
          final available = !paidLevels.contains(id);
          return {
            'id': id,
            'voicePracticeId': practiceId,
            'levelId': i,
            'stars': stars[id] ?? 0,
            'locked': !available || !(i == 1 || stars.containsKey(id) || prevPlayed),
            'skin': 'assets/icons/silver.webp',
            'mode': 'game',
            'isFree': available,
            'available': available,
            'exercise': null,
            'game': available
                ? {'type': 'breath', 'jsonConfig': {'n': i}, 'objective': null}
                : null,
          };
        }(),
    ];
  }

  Future<void> _json(HttpResponse res, Object body, {int status = 200}) async {
    res.statusCode = status;
    res.headers.contentType = ContentType.json;
    res.write(json.encode(body));
    await res.close();
  }

  Future<void> _handle(HttpRequest req) async {
    final path = req.uri.path.replaceFirst('/api/v1/', '');
    final body = await utf8.decoder.bind(req).join();
    if (offline) {
      final socket = await req.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    requests.add('${req.method} $path');
    final res = req.response;

    if (path == 'voice-practices') {
      return _json(res, [
        for (final e in sounds.entries)
          {
            'id': e.key,
            'name': 'R tovushi',
            'count': e.value,
            'availableLevelsCount': e.value,
            'available': true,
            'subscribed': false,
          },
      ]);
    }
    if (path == 'levels') {
      final id = req.uri.queryParameters['voicePracticeId'];
      final n = sounds[id];
      if (n == null) return _json(res, {'message': 'yo\'q'}, status: 404);
      return _json(res, levelsOf(id!, n));
    }
    final section = sections[path];
    if (section != null) {
      final levels = sectionLevels[path] ?? levelsOf(section.$1, section.$2);
      return _json(res, {
        'id': section.$1,
        'name': path,
        'category': path == 'games' ? 'GAMES' : 'FIRST_SPEECH',
        'totalLevels': levels.length,
        'availableLevelsCount': levels.where((l) => l['available'] == true).length,
        'starCount': 0,
        'subscribed': false,
        'levels': levels,
      });
    }
    if (path == 'games' || path == 'first-speech') {
      return _json(res, {'message': "Bo'lim hali qo'shilmagan"}, status: 404);
    }
    final starsMatch = RegExp(r'^levels/(.+)/stars$').firstMatch(path);
    if (starsMatch != null && req.method == 'POST') {
      final id = starsMatch.group(1)!;
      if (paidLevels.contains(id)) {
        return _json(res, {'message': 'Bu level faqat obunachilar uchun.'}, status: 403);
      }
      final s = (json.decode(body)['stars'] as num).toInt();
      stars[id] = s > (stars[id] ?? 0) ? s : (stars[id] ?? 0);
      history.insert(0, id.split('-').first);
      return _json(res, {'levelId': id, 'stars': stars[id]});
    }
    if (path == 'stars/history') {
      return _json(res, [for (final p in history) {'voicePracticeId': p}]);
    }
    if (path == 'ball' && req.method == 'GET') {
      return _json(res, {'ball': ball, 'accepted': 0});
    }
    if (path == 'ball/events' && req.method == 'POST') {
      final events = (json.decode(body)['events'] as List).cast<Map>();
      var accepted = 0;
      for (final e in events) {
        final d = (e['delta'] as num).toInt();
        if (d == 0 || !ballEventIds.add(e['id'] as String)) continue;
        ball = (ball + d) < 0 ? 0 : ball + d;
        accepted++;
      }
      if (dropBallResponse > 0) {
        dropBallResponse--;
        final socket = await res.detachSocket(writeHeaders: false);
        socket.destroy();
        return;
      }
      return _json(res, {'ball': ball, 'accepted': accepted});
    }
    return _json(res, {'message': 'not found'}, status: 404);
  }
}

Future<void> eventually(bool Function() cond, {String? reason}) async {
  for (var i = 0; i < 300; i++) {
    if (cond()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Shart bajarilmadi: ${reason ?? ''}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeBackend srv;
  late Directory dir;
  late Box box;
  final providers = <LevelProvider>[];

  setUpAll(() {
    // flutter_test haqiqiy HTTP'ni bloklaydi — lokal server uchun ochamiz
    HttpOverrides.global = null;
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'test-token'});
    srv = FakeBackend();
    await srv.start();
    ApiService().baseUrlForTesting = srv.baseUrl;
    NetworkStatus.instance.resetForTesting();
    NetworkStatus.instance.checkOverride = () async => !srv.offline;
    dir = await Directory.systemTemp.createTemp('level_sync_');
    Hive.init(dir.path);
    box = await Hive.openBox(kLevelProgressBox);
  });

  tearDown(() async {
    for (final p in providers) {
      await p.ready;
      p.dispose();
    }
    providers.clear();
    // Fondagi so'rovlar tugashi uchun
    await Future<void>.delayed(const Duration(milliseconds: 50));
    NetworkStatus.instance.resetForTesting();
    await Hive.close();
    await srv.stop();
    await dir.delete(recursive: true);
  });

  LevelProvider make({bool auto = false}) {
    final p = LevelProvider(autoBootstrap: auto);
    providers.add(p);
    return p;
  }

  Future<void> goOffline() async {
    srv.offline = true;
    await NetworkStatus.instance.check();
  }

  Future<void> goOnline() async {
    srv.offline = false;
    await NetworkStatus.instance.check();
  }

  group("O'yinlar va Ilk nutq serverdan", () {
    test("O'yinlar xaritasi GET /games dan, Ilk nutq GET /first-speech dan olinadi", () async {
      final p = make();
      await p.selectSound(LevelProvider.gamesSound);
      expect(p.levels.length, 5);
      expect(p.levels.first.serverId, 'vpG-1');
      expect(p.levels.first.locked, isFalse);
      expect(p.levels[1].locked, isTrue);
      expect(srv.requests, contains('GET games'));

      await p.selectSound(LevelProvider.firstSpeechSound);
      expect(p.levels.length, 42);
      expect(srv.requests, contains('GET first-speech'));
      expect(p.totalLevelsOf(LevelProvider.firstSpeechSound), 42);
      expect(p.availableLevelsOf(LevelProvider.firstSpeechSound), 42);
      // O'yinlar ro'yxati keshda saqlanib qoladi
      expect(p.levelsOf(LevelProvider.gamesSound)?.length, 5);
    });

    test("Level tugasa natija serverga ketadi, keyingisi ochiladi", () async {
      final p = make();
      await p.selectSound(LevelProvider.gamesSound);
      p.setCurrentLevel(1);
      await p.unlock(stars: 3);
      await eventually(() => srv.stars['vpG-1'] == 3, reason: 'yulduz serverga');
      expect(p.levels[1].locked, isFalse);
      await eventually(() => box.get('_srv_pending_stars') == null, reason: 'navbat bo\'shaydi');

      // Qayta ochilganda serverdagi progress keladi (boshqa qurilma kabi)
      final p2 = make();
      await p2.selectSound(LevelProvider.gamesSound);
      expect(p2.levels[0].stars, 3);
      expect(p2.levels[1].locked, isFalse);
      expect(p2.levels[2].locked, isTrue);
    });

    test("server_levels/*.json (admin yuklaydigan fayllar) serverdan kelganda to'g'ri o'qiladi", () async {
      Map<String, dynamic> asServer(Map<String, dynamic> l, String vp) {
        // Backend LevelStateUserResponse shakli: id — mongo id, levelId — tartib
        final g = l['game'] as Map?;
        return {
          ...l,
          'id': '$vp-${l['id']}',
          'levelId': l['id'],
          'voicePracticeId': vp,
          'available': true,
          'locked': l['id'] != 1,
          // Backend bo'sh exercise/game ni ham yuboradi
          'exercise': l['exercise'] ?? {'modelPath': '', 'labelsPath': '', 'mediaPath': '', 'sound': '', 'steps': []},
          'game': g ?? {'type': '', 'objective': '', 'jsonConfig': {}},
        };
      }

      for (final (path, file, sound) in [
        ('games', 'server_levels/games.json', LevelProvider.gamesSound),
        ('first-speech', 'server_levels/first_speech.json', LevelProvider.firstSpeechSound),
      ]) {
        final raw = (json.decode(File(file).readAsStringSync()) as List).cast<Map<String, dynamic>>();
        srv.sectionLevels[path] = [for (final l in raw) asServer(l, path)];
        final p = make();
        await p.selectSound(sound);
        expect(p.levels.length, raw.length, reason: file);
        for (var i = 0; i < raw.length; i++) {
          final src = raw[i];
          final lv = p.levels[i];
          expect(lv.id, i + 1);
          expect(lv.mode, src['mode']);
          if (src['mode'] == 'game') {
            expect(lv.game?.type, (src['game'] as Map)['type'], reason: '$file #${i + 1}');
            expect(json.decode(lv.game!.jsonConfig), (src['game'] as Map)['jsonConfig']);
            expect(lv.exercise, isNull, reason: "bo'sh exercise mashq deb olinmaydi");
          } else {
            final ex = src['exercise'] as Map;
            expect(lv.exercise?.modelPath, ex['modelPath']);
            expect(lv.exercise?.steps.length, (ex['steps'] as List).length);
            expect(lv.game, isNull, reason: "bo'sh game o'yin deb olinmaydi");
          }
        }
        expect(p.levels.first.locked, isFalse);
        expect(p.levels.skip(1).every((l) => l.locked), isTrue);
      }
    });

    test("Bo'lim hali admin panelda qo'shilmagan (404) — bo'sh xarita, xatosiz", () async {
      srv.sections.remove('first-speech');
      final p = make();
      await p.selectSound(LevelProvider.firstSpeechSound);
      expect(p.levels, isEmpty);
      expect(p.isLoading, isFalse);
      // Keyin qo'shilsa — qayta urinishda keladi
      srv.sections['first-speech'] = ('vpF', 3);
      await p.refreshSound(LevelProvider.firstSpeechSound);
      expect(p.levels.length, 3);
    });

    test("Pullik level obunasiz ochilmaydi, server rad etgan natija navbatdan olinadi", () async {
      srv.paidLevels.add('vpG-2');
      final p = make();
      await p.selectSound(LevelProvider.gamesSound);
      expect(p.levels[1].available, isFalse);
      p.setCurrentLevel(1);
      await p.unlock(stars: 2);
      expect(p.levels[1].locked, isTrue, reason: 'pullik keyingi level ochilmaydi');

      // Rad etiladigan natija navbatda qolib ketmasin
      box.put('_srv_pending_stars', {'vpG-2': 1});
      await p.syncNow();
      expect(box.get('_srv_pending_stars'), isNull);
    });

    test("/voice-practices faqat tovushlar; 'So'ngi harakat' o'yin natijasini tovush deb olmaydi", () async {
      srv.history.addAll(['vpG', 'vpR']); // eng yangisi — o'yin
      final p = make();
      await p.bootstrap();
      expect(p.lastActivity?.sound, 'R');
    });
  });

  group('Internet yo\'q / qaytdi', () {
    test("Internetsiz o'ynalgan natija navbatda turadi, internet qaytishi bilan yuboriladi", () async {
      final p = make(auto: true);
      await p.ready;
      await p.selectSound(LevelProvider.gamesSound);
      // selectSound fonda xaritani yangilaydi — tugashini kutamiz
      await eventually(() => srv.requests.where((r) => r == 'GET games').length >= 2);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await goOffline();
      p.setCurrentLevel(1);
      await p.unlock(stars: 2);
      expect(p.levels[1].locked, isFalse, reason: 'bola davom eta oladi');
      expect(srv.stars, isEmpty);
      expect(box.get('_srv_pending_stars'), {'vpG-1': 2});

      // Xarita qayta qurilsa ham navbatdagi natija ko'rinadi
      await p.refreshSound(LevelProvider.gamesSound);
      expect(p.levels[0].stars, 2);
      expect(p.levels[1].locked, isFalse);

      // Internetsiz urinishlar tugasin — keyingi yuborish faqat internet qaytgani uchun bo'lsin
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(srv.stars, isEmpty);
      await goOnline(); // tinglovchi syncNow() ni chaqiradi
      await eventually(() => srv.stars['vpG-1'] == 2, reason: 'internet qaytgach yuboriladi');
      await eventually(() => box.get('_srv_pending_stars') == null);
    });

    test("Ilova fondan qaytganda (resumed) navbat yuboriladi", () async {
      final p = make(auto: true);
      await p.ready;
      box.put('_srv_pending_stars', {'vpG-3': 1});
      p.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await eventually(() => srv.stars['vpG-3'] == 1);
    });

    test("Yuborish paytida qo'shilgan natija ham shu aylanishda ketadi", () async {
      final p = make();
      await p.selectSound(LevelProvider.gamesSound);
      p.setCurrentLevel(1);
      final first = p.unlock(stars: 1);
      p.setCurrentLevel(2);
      await p.unlock(stars: 3);
      await first;
      await eventually(() => srv.stars['vpG-1'] == 1 && srv.stars['vpG-2'] == 3);
      await eventually(() => box.get('_srv_pending_stars') == null);
    });
  });

  group('Umumiy ball serverda', () {
    test("Ball serverga yuboriladi va serverdan o'qiladi", () async {
      srv.ball = 30;
      final p = make();
      await p.bootstrap();
      await eventually(() => p.ball == 30, reason: 'serverdagi ball');
      p.addBall(10);
      expect(p.ball, 40, reason: 'darhol ko\'rinadi');
      await eventually(() => srv.ball == 40);
      await eventually(() => box.get('_srv_pending_ball') == null);
      expect(p.ball, 40);
    });

    test("Internetsiz yig'ilgan ball (ayirish ham) internet qaytgach bir marta qo'shiladi", () async {
      final p = make(auto: true);
      await p.ready;
      await goOffline();
      p.addBall(10);
      p.addBall(5);
      p.addBall(-3);
      expect(p.ball, 12);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(srv.ball, 0);
      await goOnline();
      await eventually(() => srv.ball == 12);
      await eventually(() => box.get('_srv_pending_ball') == null);
      expect(p.ball, 12);
    });

    test("Server qabul qilib javob yo'qolsa — qayta yuborishda ikki marta qo'shilmaydi", () async {
      final p = make();
      srv.dropBallResponse = 1;
      p.addBall(10);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(srv.ball, 10);
      expect(box.get('_srv_pending_ball'), isNotNull, reason: 'javob kelmadi — navbatda');
      await p.syncNow();
      expect(srv.ball, 10);
      expect(box.get('_srv_pending_ball'), isNull);
      expect(p.ball, 10);
    });

    test("Ball 0 dan pastga tushmaydi", () async {
      final p = make();
      p.addBall(5);
      p.addBall(-20);
      expect(p.ball, 0);
      await eventually(() => box.get('_srv_pending_ball') == null);
      expect(srv.ball, 0);
      p.addBall(7);
      await eventually(() => srv.ball == 7);
      expect(p.ball, 7);
    });

    test("Eski (qurilmadagi) ball bir marta serverga ko'chiriladi", () async {
      box.put('_total_ball', 40);
      final p = make();
      await p.bootstrap();
      await eventually(() => srv.ball == 40);
      expect(box.get('_total_ball'), isNull);
      // Qayta ishga tushganda qayta qo'shilmaydi
      final p2 = make();
      await p2.bootstrap();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(srv.ball, 40);
      expect(p2.ball, 40);
    });
  });

  group('Eski lokal progress migratsiyasi', () {
    test("Ilk nutqning 4 ta eski xaritasi bitta xaritaga siljish bilan ko'chadi", () async {
      // artikulatsion: 1–3 o'ynalgan (4 ochilgan); nafas: 1 va 2 yulduzli
      box.put('FS_ARTIKULATSION', {
        'unlocked': [1, 2, 3, 4],
        'stars': {'1': 3, '2': 2, '3': 1},
      });
      box.put('FS_NAFAS', {
        'unlocked': [1, 2, 3],
        'stars': {'1': 3, '2': 2},
      });
      box.put('FS_CHIZIQ', {
        'unlocked': [1],
        'stars': <String, int>{},
      });
      final p = make();
      await p.bootstrap();
      await eventually(() => srv.stars.length == 5, reason: '${srv.stars}');
      expect(srv.stars, {
        'vpF-1': 3,
        'vpF-2': 2,
        'vpF-3': 1,
        'vpF-9': 3, // nafas 1
        'vpF-10': 2, // nafas 2
      });
      // Artikulatsionning oxirgi leveli (8) nafas 1 ochiq bo'lgani uchun "o'ynalgan" deb olinmaydi
      expect(srv.stars.containsKey('vpF-8'), isFalse);
      // Chiziq 1 (28) ham shunchaki ochiq edi — barmoqning oxirgisi (27) o'ynalgan emas
      expect(srv.stars.containsKey('vpF-27'), isFalse);
      for (final k in ['FS_ARTIKULATSION', 'FS_NAFAS', 'FS_BARMOQ', 'FS_CHIZIQ']) {
        expect(box.get(k), isNull, reason: k);
      }
    });

    test("O'yinlar: eski 'hammasi ochiq' progressdan faqat yulduzlilar ko'chadi", () async {
      box.put('GAMES', {
        'unlocked': [1, 2, 3, 4, 5],
        'stars': {'1': 2},
      });
      final p = make();
      await p.bootstrap();
      await eventually(() => srv.stars.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(srv.stars, {'vpG-1': 2});
      expect(box.get('GAMES'), isNull);
    });

    test("0 yulduz bilan o'tilgan level ham ko'chadi (keyingisi ochiq bo'lsa)", () async {
      box.put('_games_lock_migrated_v1', true);
      box.put('GAMES', {
        'unlocked': [1, 2, 3],
        'stars': <String, int>{},
      });
      final p = make();
      await p.selectSound(LevelProvider.gamesSound);
      await eventually(() => srv.stars.length == 2);
      expect(srv.stars, {'vpG-1': 0, 'vpG-2': 0});
      expect(p.levels[2].locked, isFalse);
    });
  });

  group('Logout / login', () {
    test("Logout: navbat avval yuboriladi, so'ng hamma narsa (eski lokal progress ham) tozalanadi", () async {
      final p = make();
      await p.selectSound(LevelProvider.gamesSound);
      await goOffline();
      p.setCurrentLevel(1);
      await p.unlock(stars: 3);
      p.addBall(10);
      box.put('FS_NAFAS', {'unlocked': [1], 'stars': {'1': 1}});
      await goOnline();
      await p.flushBeforeSignOut();
      expect(srv.stars['vpG-1'], 3);
      expect(srv.ball, 10);

      p.clearServerData();
      expect(p.ball, 0);
      expect(p.levels, isEmpty);
      expect(p.levelsOf(LevelProvider.gamesSound), isNull);
      expect(box.get('FS_NAFAS'), isNull, reason: 'keyingi akkauntga o\'tmasin');
      expect(box.get('_srv_pending_stars'), isNull);
      expect(box.get('_srv_pending_ball'), isNull);
      expect(box.get('_srv_levels_GAMES'), isNull);
    });

    test("Logout'da internet yo'q bo'lsa kutib qolmaydi", () async {
      final p = make();
      await goOffline();
      p.addBall(5);
      final sw = Stopwatch()..start();
      await p.flushBeforeSignOut(timeout: const Duration(seconds: 2));
      expect(sw.elapsed, lessThan(const Duration(seconds: 3)));
    });

    test("Login (reloadForUser): eski lokal progress saqlanadi va yangi foydalanuvchiga ko'chadi", () async {
      box.put('FS_BARMOQ', {'unlocked': [1, 2], 'stars': {'1': 3}});
      final p = make();
      await p.reloadForUser();
      await eventually(() => srv.stars['vpF-21'] == 3, reason: 'barmoq 1 = 21-level');
      expect(box.get('FS_BARMOQ'), isNull);
    });
  });
}
