import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/AppColors.dart';
import 'package:wave_linear_progress_indicator/wave_linear_progress_indicator.dart';

import '../main/HomePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size.height * 0.7,
              child: Image.asset('assets/images/ic_splash.png'),
            ),

            // (ixtiyoriy) logotip / nom
            const Text(
              'Loading..',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.main_blue_500,
              ),
            ),
            const SizedBox(height: 10),

            // 0 -> 1 gacha 2 soniyada to‘ladi
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              onEnd: () {
                if (_navigated) return;
                _navigated = true;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              builder: (context, value, _) {
                return SizedBox(
                  width: 300,
                  child: WaveLinearProgressIndicator(
                    value: value,
                    // 0.0–1.0
                    minHeight: 15,
                    borderRadius: 10,
                    waveColor: AppColors.orange_500,
                    waveBackgroundColor: AppColors.orange_100,
                    // istalgan rang
                    enableBounceAnimation: true, // ixtiyoriy
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
