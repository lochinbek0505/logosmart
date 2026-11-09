import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:logosmart/core/network/api_service.dart';
import 'package:logosmart/core/network/network_status.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/map_route_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/level_button.dart';
import 'package:logosmart/ui/pages/games/widgets/no_internet.dart';
import 'package:logosmart/ui/pages/main/firstspeech/StartSpeechPage.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'level_sync_test.dart' show FakeBackend;

Widget host(LevelProvider provider, Widget page) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      theme: AppTheme.light,
      builder: (ctx, child) {
        ScreenUtil.init(ctx, designSize: const Size(375, 812));
        return child!;
      },
      home: page,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  late FakeBackend srv;
  late Directory dir;

  setUpAll(() {
    HttpOverrides.global = null;
    // Xarita musiqasi (audioplayers) — testda platforma yo'q
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in ['xyz.luan/audioplayers', 'xyz.luan/audioplayers.global']) {
      messenger.setMockMethodCallHandler(MethodChannel(name), (_) async => null);
    }
    messenger.setMockStreamHandler(
      const EventChannel('xyz.luan/audioplayers.global/events'),
      MockStreamHandler.inline(onListen: (_, _) {}),
    );
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'test-token'});
    await TestWidgetsFlutterBinding.instance.runAsync(() async {
      srv = FakeBackend();
      await srv.start();
      dir = await Directory.systemTemp.createTemp('map_offline_');
      Hive.init(dir.path);
      await Hive.openBox(kLevelProgressBox);
    });
    ApiService().baseUrlForTesting = srv.baseUrl;
    NetworkStatus.instance.resetForTesting();
    NetworkStatus.instance.checkOverride = () async => !srv.offline;
  });

  tearDown(() async {
    NetworkStatus.instance.resetForTesting();
    await TestWidgetsFlutterBinding.instance.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      // Widget test zonasida boshlangan Hive yozuvlari bu yerda tugamasligi mumkin
      await Hive.close().timeout(const Duration(seconds: 1), onTimeout: () {});
      await srv.stop();
      await dir.delete(recursive: true);
    });
  });

  /// Haqiqiy HTTP javoblari kelishi uchun real vaqt bilan kutib, so'ng kadr chizish
  /// (HTTP so'rovining har bir bosqichi alohida real IO + mikrotask navbati)
  Future<void> settle(WidgetTester t, {int ms = 250}) async {
    for (var waited = 0; waited < ms; waited += 25) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
      await t.pump();
    }
    await t.pump(const Duration(milliseconds: 50));
  }

  /// Testda audioplayers plagini yo'q (xarita musiqasi) — faqat shu xatoga ruxsat
  void expectNoErrors(WidgetTester t) {
    for (Object? e = t.takeException(); e != null; e = t.takeException()) {
      if (e is MissingPluginException && '$e'.contains('audioplayers')) continue;
      fail('Kutilmagan xato: $e');
    }
  }

  /// Sahifani yopib, fondagi so'rov va taymerlar (Dio timeout, animatsiya) tugashini kutish
  Future<void> finish(WidgetTester t) async {
    expectNoErrors(t);
    await t.pumpWidget(const SizedBox());
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await t.pump(const Duration(seconds: 30));
    expectNoErrors(t);
  }

  /// Shart bajarilguncha (ko'pi bilan ~5 s) real IO va kadrlarni aylantirish
  Future<void> settleUntil(WidgetTester t, bool Function() cond) async {
    for (var i = 0; i < 200 && !cond(); i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
      // Dio xato yo'lida taymerlar bor — soxta vaqt ham oldinga suriladi
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(cond(), isTrue, reason: 'kutilgan holatga kelmadi');
    await t.pump(const Duration(milliseconds: 50));
  }

  /// Internetni o'chirish/yoqish: server manzili yopiq portga almashtiriladi
  /// (ulanish darhol rad etiladi — haqiqiy "internet yo'q" kabi)
  void setOffline(bool off) {
    srv.offline = off;
    ApiService().baseUrlForTesting = off ? 'http://127.0.0.1:1/api/v1/' : srv.baseUrl;
  }

  void phone(WidgetTester t) {
    t.view.physicalSize = const Size(390, 844) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  testWidgets("Internet yo'q — xarita o'rniga ogohlantirish, levellar ko'rinmaydi", (t) async {
    phone(t);
    setOffline(true);
    // Avval ochilgan xarita keshda bor — internetsiz baribir ko'rsatilmasligi kerak
    await t.runAsync(() => Hive.box(kLevelProgressBox)
        .put('_srv_levels_GAMES', jsonEncode(srv.levelsOf('vpG', 5))));
    final p = LevelProvider(autoBootstrap: false);
    await t.pumpWidget(host(p, MapRoadPage(sound: LevelProvider.gamesSound)));
    // Xarita keshdan yuklanib bo'lguncha kutamiz
    await settleUntil(t, () => p.currentSound == LevelProvider.gamesSound && !p.isLoading);
    expect(p.levels.length, 5, reason: 'keshdagi levellar provider\'da bor');

    expect(find.byType(NoInternetView), findsOneWidget);
    expect(find.text("Internet yo'q"), findsOneWidget);
    expect(find.text("Qayta urinish"), findsOneWidget);
    expect(find.text("Orqaga"), findsOneWidget, reason: 'alohida sahifa — orqaga chiqish mumkin');
    expect(find.byType(LevelButton), findsNothing);

    // Internet hali yo'q — "Qayta urinish" ekranni yopmaydi
    await t.tap(find.text("Qayta urinish"));
    await settle(t);
    expect(find.byType(NoInternetView), findsOneWidget);

    // Internet yoqildi — "Qayta urinish" bosilgach xarita ochiladi
    setOffline(false);
    await t.tap(find.text("Qayta urinish"));
    await settle(t, ms: 400);
    await settle(t, ms: 200);
    expect(find.byType(NoInternetView), findsNothing);
    expect(find.byType(LevelButton), findsNWidgets(5));
    await finish(t);
  });

  testWidgets("Tab ichidagi O'yinlar: 'Orqaga' yo'q; internet qaytsa o'zi ochiladi", (t) async {
    phone(t);
    srv.offline = true;
    final p = LevelProvider(autoBootstrap: false);
    await t.pumpWidget(host(p, MapRoadPage(sound: LevelProvider.gamesSound, embedded: true)));
    await settle(t);
    expect(find.byType(NoInternetView), findsOneWidget);
    expect(find.text("Orqaga"), findsNothing);

    srv.offline = false;
    // Tarmoq o'zgardi (connectivity) — NetworkStatus tekshiradi va xabar beradi
    await t.runAsync(() => NetworkStatus.instance.check());
    await settle(t, ms: 400);
    await settle(t, ms: 200);
    expect(find.byType(NoInternetView), findsNothing);
    expect(find.byType(LevelButton), findsNWidgets(5));
    await finish(t);
  });

  testWidgets("Xarita ochiq, internet uzildi — levelni bosganda ogohlantirish, o'yin ochilmaydi", (t) async {
    phone(t);
    final p = LevelProvider(autoBootstrap: false);
    await t.pumpWidget(host(p, MapRoadPage(sound: LevelProvider.gamesSound)));
    await settle(t, ms: 400);
    await settle(t, ms: 200);
    expect(find.byType(LevelButton), findsNWidgets(5));

    srv.offline = true;
    await t.tap(find.byType(LevelButton).first);
    await settle(t);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text("Internet yo'q"), findsOneWidget);
    expect(p.currentPlayingLevelId, isNull, reason: 'level ochilmadi');

    await t.tap(find.text("Yopish"));
    await settle(t);
    await t.pump(const Duration(milliseconds: 400)); // dialog yopilish animatsiyasi
    expect(find.byType(AlertDialog), findsNothing);
    expect(p.currentPlayingLevelId, isNull);
    await finish(t);
  });

  testWidgets("Ilk nutq: Boshlash — bitta xarita (GET /first-speech) ochiladi", (t) async {
    phone(t);
    final p = LevelProvider(autoBootstrap: false);
    await t.pumpWidget(host(p, const StartSpeechPage()));
    await t.pump();
    final start = find.byWidgetPredicate(
      (w) => w is GestureDetector && w.onTap != null && w.child is! Image,
    );
    // Sahifadagi oxirgi bosiladigan element — "Boshlash" tugmasi
    await t.tap(start.last);
    await t.pump(const Duration(milliseconds: 400));
    await settle(t, ms: 400);
    await settle(t, ms: 200);
    expect(find.byType(MapRoadPage), findsOneWidget);
    expect(srv.requests, contains('GET first-speech'));
    expect(find.byType(LevelButton), findsWidgets);
    expect(p.currentSound, LevelProvider.firstSpeechSound);
    await finish(t);
  });
}
