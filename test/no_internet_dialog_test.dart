import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/network/network_status.dart';
import 'package:logosmart/ui/pages/games/widgets/no_internet.dart';

import 'ui_overflow_test.dart' show host;

/// Sekin internet: tekshiruv paytida darhol "qidiryapman" oynasi chiqadi
/// (noma'lum kutish yo'q), internet topilmasa o'sha oyna "Internet yo'q" bo'ladi
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  FlutterSecureStorage.setMockInitialValues({});
  tearDown(NetworkStatus.instance.resetForTesting);

  Future<bool?> open(WidgetTester t, double scale) async {
    t.view.physicalSize = const Size(320, 640) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    bool? result;
    await t.pumpWidget(host(
      Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async => result = await ensureOnline(ctx),
              child: const Text("och"),
            ),
          ),
        ),
      ),
      scale: scale,
    ));
    await t.tap(find.text("och"));
    return result;
  }

  for (final scale in [1.0, 1.3]) {
    testWidgets('Sekin, internet yo\'q: qidiryapman -> Internet yo\'q, shrift x$scale', (t) async {
      var online = false;
      NetworkStatus.instance.checkOverride =
          () => Future.delayed(const Duration(seconds: 3), () => online);
      await open(t, scale);

      await t.pump(const Duration(milliseconds: 500));
      expect(find.text("Internetni qidiryapman..."), findsOneWidget);
      expect(find.text("Bekor qilish"), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.pump(const Duration(seconds: 3));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text("Internet yo'q"), findsOneWidget);
      expect(find.text("Qayta urinish"), findsOneWidget);
      expect(find.text("Yopish"), findsOneWidget);
      expect(t.takeException(), isNull);

      // Internet qaytdi — "Qayta urinish"dan keyin oyna yopiladi
      online = true;
      await t.tap(find.text("Qayta urinish"));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text("Internetni qidiryapman..."), findsOneWidget);
      await t.pump(const Duration(seconds: 3));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('no_internet_dialog')), findsNothing);
    });
  }

  testWidgets('Tez javob: oyna umuman ko\'rinmaydi', (t) async {
    NetworkStatus.instance.checkOverride = () async => true;
    await open(t, 1.0);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('no_internet_dialog')), findsNothing);
  });
}
