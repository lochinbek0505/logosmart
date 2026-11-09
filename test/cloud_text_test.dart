import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/cloud_text.dart';

/// Bulut matni kesilmasligi: matn bulutning ichki maydonidan chiqmaydi
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  const long =
      "Artikulatsion mashqlarni mening ortimdan 5 martadan bajar, har bir harakat aniq bo'lsin.";
  const veryLong = '$long $long $long';

  for (final scale in [1.0, 1.3]) {
    for (final size in [
      const Size(320, 640),
      const Size(390, 844),
      const Size(800, 1280),
    ]) {
      for (final text in ['Salom!', long, veryLong]) {
        testWidgets(
          '${size.width}x${size.height}, shrift x$scale, ${text.length} belgi',
          (t) async {
            t.view.physicalSize = size * 2;
            t.view.devicePixelRatio = 2;
            addTearDown(t.view.reset);
            await t.pumpWidget(
              MaterialApp(
                builder: (ctx, child) {
                  ScreenUtil.init(ctx, designSize: const Size(375, 812));
                  return MediaQuery(
                    data: MediaQuery.of(
                      ctx,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!,
                  );
                },
                home: Scaffold(
                  body: Center(child: CloudText(text: text)),
                ),
              ),
            );
            expect(t.takeException(), isNull);

            final cloud = t.getRect(find.byType(Container).first);
            final txt = t.getRect(find.text(text));
            // Matn butunlay bulut tanasida (pastki 28% — pufakchalar)
            expect(
              txt.top,
              greaterThanOrEqualTo(cloud.top + cloud.height * 0.2 - 0.5),
            );
            expect(
              txt.bottom,
              lessThanOrEqualTo(cloud.bottom - cloud.height * 0.28 + 0.5),
            );
            expect(txt.left, greaterThanOrEqualTo(cloud.left - 0.5));
            expect(txt.right, lessThanOrEqualTo(cloud.right + 0.5));
          },
        );
      }
    }
  }
}
