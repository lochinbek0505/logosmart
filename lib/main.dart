import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logosmart/AICameraTestPage.dart';
import 'package:logosmart/providers/level_provider.dart';
import 'package:logosmart/ui/pages/auth/login_page.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/home/home_page.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/pages/start/splash_screen.dart';
import 'package:provider/provider.dart';

import 'core/storage/level_state.dart';
import 'ui/pages/auth/success_page.dart';
import 'ui/pages/start/onboard_page.dart';

Future<void> main() async {
  await ScreenUtil.ensureScreenSize();

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(71))
    Hive.registerAdapter(ExerciseStepAdapter()); // codegen
  if (!Hive.isAdapterRegistered(72))
    Hive.registerAdapter(ExerciseInfoAdapter()); // codegen

  if (!Hive.isAdapterRegistered(73))
    Hive.registerAdapter(GameInfoAdapter()); // codegen

  if (!Hive.isAdapterRegistered(7))
    Hive.registerAdapter(LevelStateAdapter()); // MANUAL

  await Hive.openBox<LevelState>(kLevelsBox);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_)=>ProfileProvider())
      ],

      child: MaterialApp(
        builder: (ctx, child) {
          ScreenUtil.init(ctx, designSize: const Size(375, 812));
          return child!;
        },

        debugShowMaterialGrid: false,
        debugShowCheckedModeBanner: false,
        title: 'LogoSmart',
        theme: ThemeData(
          fontFamily: "Nunito", // Nurito emas, ehtimol Nunito bo'lsa kerak
          textSelectionTheme: const TextSelectionThemeData(
            selectionHandleColor: Colors.transparent, // tomchi rangi
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),

        home: const AuthChecker(),
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
        // 1. Kutish jarayonida (ma'lumot o'qilgunicha) loading ko'rsatamiz
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const SplashScreen();
        }

        return const LoginPage();
      },
    );
  }
}
