import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logosmart/providers/level_provider.dart';
import 'package:logosmart/ui/pages/auth/providera/register_provider.dart';
import 'package:logosmart/ui/pages/auth/register_page.dart';
import 'package:logosmart/ui/pages/main/HomePage.dart';
import 'package:provider/provider.dart';

import 'AICameraTestPage.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),

      ],
      child: MaterialApp(
        builder: (ctx,child){
          ScreenUtil.init(ctx, designSize: const Size(375, 812));
          return child!;
        },
        debugShowMaterialGrid: false,
        debugShowCheckedModeBanner: false,
        title: 'LogoSmart',
        theme: ThemeData(
          fontFamily: "Nurito",
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Colors.transparent, // tomchi rangi
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: RegisterPage(),
      ),
    );
  }
}
