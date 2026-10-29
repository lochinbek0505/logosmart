import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logosmart/core/network/api_service.dart';
import 'package:logosmart/core/storage/token_storage.dart';
import 'package:logosmart/core/service/app_settings.dart';
import 'package:logosmart/core/service/notification_service.dart';
import 'package:logosmart/core/service/permission_service.dart';
import 'package:logosmart/firebase_options.dart';
import 'package:logosmart/ui/pages/auth/login_page.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/diagnostic/provider/diagnostic_provider.dart';
import 'package:logosmart/ui/pages/diagnostic/provider/voice_diagnostic_provider.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:logosmart/ui/pages/main/main_page.dart';
import 'package:logosmart/ui/pages/profile/providers/billings_provider.dart';
import 'package:logosmart/ui/pages/profile/providers/notifications_provider.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await AppSettings().load();
  await Hive.initFlutter();
  await Hive.openBox(kLevelProgressBox);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Top-level handler runApp'dan oldin ro'yxatdan o'tishi shart
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Ruxsat so'rovi ilova ochilishini to'xtatib qo'ymasligi uchun kutmaymiz
  // Bildirishnoma dialogidan keyin kamera va mikrofon ruxsatlari so'raladi
  NotificationService().init().whenComplete(
    PermissionService().requestOnFirstLaunch,
  );
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => NotificationService().handleInitialMessage(),
  );

  // WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();
  //
  // if (!Hive.isAdapterRegistered(71))
  //   Hive.registerAdapter(ExerciseStepAdapter()); // codegen
  // if (!Hive.isAdapterRegistered(72))
  //   Hive.registerAdapter(ExerciseInfoAdapter()); // codegen
  //
  // if (!Hive.isAdapterRegistered(73))
  //   Hive.registerAdapter(GameInfoAdapter()); // codegen
  //
  // if (!Hive.isAdapterRegistered(7))
  //   Hive.registerAdapter(LevelStateAdapter()); // MANUAL
  //
  // // await Hive.openBox<LevelState>(kLevelsBox);

  // Token muddati tugasa (401 / body siz 403) — login sahifasiga qaytariladi
  ApiService.onSessionExpired = _onSessionExpired;

  runApp(MyApp());
}

Future<void> _onSessionExpired() async {
  // Bir nechta so'rov birdan 403 olsa ham bir marta chiqariladi
  if (await TokenStorage().getAccessToken() == null) return;
  final context = navigatorKey.currentContext;
  if (context == null || !context.mounted) {
    await TokenStorage().clearAll();
    return;
  }
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    const SnackBar(content: Text("Sessiya muddati tugadi. Qaytadan kiring.")),
  );
  await Provider.of<ProfileProvider>(context, listen: false)
      .signOutLocally(context);
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BillingsProvider()),
        ChangeNotifierProvider(create: (_) => DiagnosticProvider()),
        ChangeNotifierProvider(create: (_) => VoiceDiagnosticProvider()),
        ChangeNotifierProvider.value(value: NotificationsProvider()),
      ],

      child: ListenableBuilder(
        listenable: AppSettings(),
        builder: (context, _) => MaterialApp(
          navigatorKey: navigatorKey,
          builder: (ctx, child) {
            ScreenUtil.init(ctx, designSize: const Size(375, 812));
            return child!;
          },

          debugShowMaterialGrid: false,
          debugShowCheckedModeBanner: false,
          title: 'LogoSmart',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: AppSettings().themeMode,

          home: const AuthChecker(),
        ),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Provider.of<AuthProvider>(
        context,
        listen: false,
      ).checkLoginData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return MainPage();
        }

        return LoginPage();
      },
    );
  }
}
