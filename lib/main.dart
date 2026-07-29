import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:logosmart/ui/pages/auth/login_page.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/diagnostic/provider/diagnostic_provider.dart';
import 'package:logosmart/ui/pages/diagnostic/provider/voice_diagnostic_provider.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/map_route_page.dart';
import 'package:logosmart/ui/pages/home/home_page.dart';
import 'package:logosmart/ui/pages/main/main_page.dart';
import 'package:logosmart/ui/pages/cv_model/camera_page.dart';
import 'package:logosmart/ui/pages/profile/providers/billings_provider.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

import 'core/storage/level_state.dart';

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

  runApp(MyApp());
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
    LevelState lv = LevelState(
      id: 1,
      stars: 0,
      locked: false,
      skin: skinGold,
      mode: 'exercise',
      exercise: ExerciseInfo(
        modelPath: 'assets/models/ochtp.tflite',
        labelsPath: 'assets/models/labels.txt',
        mediaPath: 'assets/videos/models/ong_chap.mp4',
        steps: [
          ExerciseStep(
            text: "Iltimos berilgan mashqlarni 4 martadan qayta bajaring",
            action: "about",
          ),

          ExerciseStep(text: 'Tilni o\'nga chiqarib ko‘rsating', action: "ong"),
          ExerciseStep(text: 'Tilni pastga chiqarib ko‘rsating', action: "past"),

          ExerciseStep(
            text: 'Tilni chapga chiqarib ko‘rsating',
            action: "chap",
          ),
          ExerciseStep(text: 'Tilni tepaga chiqarib ko‘rsating', action: "tepa"),

        ],
      ),
    );

    return FutureBuilder<bool>(
      future: Provider.of<AuthProvider>(
        context,
        listen: false,
      ).checkLoginData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return MapRoadPage();
        }

        return LoginPage();
      },
    );
  }
}
