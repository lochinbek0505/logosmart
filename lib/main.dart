import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logosmart/providers/level_provider.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/CameraPage.dart';

import 'core/storage/level_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // --- Faqat BITTA marta register qilamiz:
  if (!Hive.isAdapterRegistered(71))
    Hive.registerAdapter(ExerciseStepAdapter()); // codegen
  if (!Hive.isAdapterRegistered(72))
    Hive.registerAdapter(ExerciseInfoAdapter()); // codegen
  if (!Hive.isAdapterRegistered(73))
    Hive.registerAdapter(GameInfoAdapter()); // codegen

  // LevelState uchun - qo'lda yozilgan adapterni tanlaymiz:
  if (!Hive.isAdapterRegistered(7))
    Hive.registerAdapter(LevelStateAdapter()); // MANUAL

  await Hive.openBox<LevelState>(kLevelsBox);

  runApp(const MyApp());
}

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
      home: CameraPage(
        data: LevelState(
          id: 1,
          stars: 0,
          locked: false,
          skin: skinGold,
          mode: 'exercise',
          exercise: ExerciseInfo(
            modelPath: 'assets/models/model3.tflite',
            labelsPath: 'assets/models/labels.txt',
            mediaPath: 'assets/media/ong_chap.MP4',
            steps: [

              ExerciseStep(text: 'Tilni o\'nga chiqarib ko‘rsating', action: "ong"),
              ExerciseStep(text: 'Tilni chapga chiqarib ko‘rsating', action: 'chap'),
            ],
          ),
        ),
      ),
    );
  }
}
