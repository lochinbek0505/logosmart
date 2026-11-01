import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/otp_verification_page.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/alphabet_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:logosmart/ui/pages/home/home_page.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/pages/profile/providers/notifications_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

Widget host(Widget page, {double scale = 1.3, Size size = const Size(360, 740), double keyboard = 0}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LevelProvider(autoBootstrap: false)),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider.value(value: NotificationsProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      builder: (ctx, child) {
        ScreenUtil.init(ctx, designSize: const Size(375, 812));
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        );
      },
      home: page,
    ),
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  FlutterSecureStorage.setMockInitialValues({});
  for (final scale in [1.0, 1.3]) {
    testWidgets('OTP sahifasi, shrift x$scale, klaviatura ochiq', (t) async {
      t.view.physicalSize = const Size(360, 740) * 3;
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(const OtpVerificationPage(check: 'login', phone: '+998901234567'), scale: scale, keyboard: 300));
      await t.pump(const Duration(milliseconds: 100));
      expect(t.takeException(), isNull);
    });
    testWidgets('Bosh sahifa, shrift x$scale', (t) async {
      t.view.physicalSize = const Size(360, 740) * 3;
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(const HomePage(), scale: scale));
      await t.pump(const Duration(milliseconds: 100));
      expect(t.takeException(), isNull);
    });
    testWidgets('Tovushlar sahifasi, shrift x$scale', (t) async {
      t.view.physicalSize = const Size(360, 740) * 3;
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(const AlphabetPage(), scale: scale));
      await t.pump(const Duration(milliseconds: 100));
      expect(t.takeException(), isNull);
    });
  }
}
