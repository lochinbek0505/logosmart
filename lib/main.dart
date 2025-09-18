import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/MainPage.dart';
import 'package:logosmart/ui/pages/main/firstspeech/RoadPage.dart';
import 'package:logosmart/ui/pages/start/OnboardPage.dart';
import 'package:logosmart/ui/pages/start/SplashScreen.dart';

void main() {
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
      home: LevelMapPage(),
    );
  }
}
