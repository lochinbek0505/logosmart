import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/games/widgets/game_fail_dialog.dart';
import 'package:logosmart/ui/pages/games/widgets/kid_widgets.dart';
import 'package:logosmart/ui/pages/games/widgets/subscription_offer_dialog.dart';

import 'ui_overflow_test.dart' show host;

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  FlutterSecureStorage.setMockInitialValues({});

  for (final scale in [1.0, 1.3]) {
    testWidgets('Yopiq bosqich dialogi: faqat "Obuna bo\'lish", shrift x$scale', (t) async {
      t.view.physicalSize = const Size(320, 640) * 3;
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(
        Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showSubscriptionOffer(ctx),
                child: const Text("och"),
              ),
            ),
          ),
        ),
        scale: scale,
      ));
      await t.tap(find.text("och"));
      await t.pump(const Duration(milliseconds: 700));
      expect(t.takeException(), isNull);
      expect(find.text("Obuna bo'lish"), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget); // faqat "och" — dialogda boshqa tugma yo'q
      expect(find.text("Keyinroq"), findsNothing);

      // Tashqariga bosilganda yopiladi
      await t.tapAt(const Offset(5, 5));
      await t.pump(const Duration(milliseconds: 700));
      expect(find.text("Obuna bo'lish"), findsNothing);
    });

    testWidgets('Yuklash vidjetlari toshmaydi, shrift x$scale', (t) async {
      t.view.physicalSize = const Size(320, 640) * 3;
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(
        Scaffold(
          body: KidSkyBackground(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const KidFloating(child: KidWiggle(child: Icon(Icons.star))),
                  const KidProgressBar(value: null),
                  const KidProgressBar(value: 0.42),
                  const Wrap(children: [
                    KidInfoChip(icon: Icons.speed_rounded, text: "512 KB/s"),
                    KidInfoChip(icon: Icons.cloud_download_rounded, text: "12.4 / 80.0 MB"),
                  ]),
                  KidBounceButton(label: "Qayta urinish", onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
        scale: scale,
      ));
      await t.pump(const Duration(milliseconds: 600));
      expect(t.takeException(), isNull);
    });

    testWidgets("O'yin yutqazish dialogi toshmaydi, shrift x$scale", (t) async {
      t.view.physicalSize = const Size(320, 640) * 3;
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      var continued = false;
      await t.pumpWidget(host(
        Scaffold(body: GameFailDialog(onContinue: () => continued = true)),
        scale: scale,
      ));
      await t.pump(const Duration(milliseconds: 1600));
      expect(t.takeException(), isNull);
      expect(find.text("Hechqisi yo'q!"), findsOneWidget);
      await t.tap(find.text("Keyingi o'yin"));
      expect(continued, isTrue);
    });
  }
}
