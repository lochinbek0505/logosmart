import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/network/api_service.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
import 'package:logosmart/core/storage/level_state.dart';
import 'package:logosmart/ui/pages/games/widgets/level_resources_dialog.dart';

import 'ui_overflow_test.dart' show host;

/// Resurs yuklash oynasi kichik ekran va katta shriftda ham toshmaydi;
/// yuklab bo'lmasa "Qayta urinish" va "Keyinroq" chiqadi
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  FlutterSecureStorage.setMockInitialValues({});

  const level = LevelState(
    id: 1,
    stars: 0,
    locked: false,
    skin: 'assets/icons/gold.webp',
    mode: 'game',
    game: GameInfo(
      type: 'find_image_page',
      jsonConfig:
          '{"start_voice":"assets/sound/test/a.mp3","video":"assets/videos/test/b.mp4","items":[{"image":"assets/game/test/c.webp"}]}',
    ),
  );

  late Directory dir;
  setUpAll(() async {
    // Haqiqiy (yopiq portga) so'rov — darhol rad etiladi
    HttpOverrides.global = null;
    dir = await Directory.systemTemp.createTemp('res_dialog_test_');
    ResourceManager.rootOverrideForTesting = dir.path;
  });
  tearDownAll(() => dir.delete(recursive: true));

  for (final scale in [1.0, 1.3]) {
    testWidgets('Resurs oynasi: yuklanish -> xato, shrift x$scale', (t) async {
      // Server yo'q — yuklash muvaffaqiyatsiz tugaydi
      ApiService().baseUrlForTesting = 'http://127.0.0.1:9/api/v1/';
      t.view.physicalSize = const Size(320, 640) * 3;
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      bool? result;
      await t.pumpWidget(host(
        Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async =>
                    result = await prepareLevelResources(ctx, level),
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
      expect(find.text("Mashg'ulot yo'lda!"), findsOneWidget);

      for (var i = 0; i < 120 && find.text("Qayta urinish").evaluate().isEmpty; i++) {
        await t.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
        await t.pump(const Duration(seconds: 1));
      }
      expect(find.text("Qayta urinish"), findsOneWidget);
      await t.pump(const Duration(milliseconds: 600));
      expect(t.takeException(), isNull);

      await t.tap(find.text("Keyinroq"));
      await t.pump(const Duration(milliseconds: 700));
      expect(result, isFalse);
    });
  }
}
