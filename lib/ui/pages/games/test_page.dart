import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TestPage extends StatefulWidget {
  TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Qaysi soniyada qotib turishini mana shu yerdan o'zgartirasiz
  final double freezeAtSecond = 0.6;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 0),
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Eslatma: avval controllerni, keyin super.dispose() ni chaqirish tavsiya etiladi
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Orqa fon rasmi
          Positioned.fill(
            child: Image.asset(
              'assets/backround/candle_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: const Alignment(0.0, 0.3),
            child: Lottie.asset(
              'assets/animation/candle.json',
              width: 350,
              height: 350,
              controller: _controller,
              onLoaded: (composition) {
                // 1. Asl davomiylikni o'zlashtiramiz
                _controller.duration = composition.duration;

                // 2. Animatsiyaning umumiy vaqtini soniyalarda hisoblab olamiz
                double totalSeconds =
                    composition.duration.inMilliseconds / 1000.0;

                // 3. Kerakli soniyani umumiy vaqtga nisbatini topamiz (0.0 dan 1.0 gacha)
                double progress = freezeAtSecond / totalSeconds;

                // 4. Progress qiymatini 0 va 1 orasida saqlab, kontrollerga o'rnatamiz
                _controller.value = progress.clamp(0.0, 1.0);
              },
            ),
          ),
        ],
      ),
    );
  }
}
