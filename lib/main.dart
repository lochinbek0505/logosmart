import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logosmart/providers/level_provider.dart';
import 'package:logosmart/ui/pages/start/SplashScreen.dart';
import 'package:provider/provider.dart';

import 'core/storage/level_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init
  await Hive.initFlutter();

  // Manual adapterni ro‘yxatdan o‘tkazamiz
  Hive.registerAdapter(LevelStateAdapter());

  // Box ochamiz (LevelState turiga mos)
  await Hive.openBox<LevelState>(kLevelsBox);
  final levelProvider = LevelProvider();
  await levelProvider.bootstrap();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LevelProvider>.value(value: levelProvider),
      ],
      child: const MyApp(),
    ),
  );}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LogoSmart',
      theme: ThemeData(
        fontFamily: "Nurito",
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.transparent, // tomchi rangi
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
