import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Mashq tugaganda chiqadigan "Barakalla" + qarsak (clap) animatsiyasi.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _appearController;
  late final AnimationController _clapController;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Qo'llarning urilishi (qarsak) — tez-tez takrorlanadi
    _clapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    )..play();
  }

  @override
  void dispose() {
    _appearController.dispose();
    _clapController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appear = CurvedAnimation(
      parent: _appearController,
      curve: Curves.elasticOut,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _appearController,
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.06,
            numberOfParticles: 25,
            gravity: 0.25,
            shouldLoop: false,
            colors: const [
              Color(0xff20B9E8),
              Colors.greenAccent,
              Colors.yellow,
              Colors.pinkAccent,
              Colors.orangeAccent,
            ],
          ),
        ),
        Center(
          child: ScaleTransition(
            scale: appear,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _clapController,
                  builder: (context, child) {
                    final t = _clapController.value;
                    return Transform.rotate(
                      angle: sin(t * pi) * 0.15,
                      child: Transform.scale(
                        scale: 1.0 + 0.18 * t,
                        child: child,
                      ),
                    );
                  },
                  child: Text('👏', style: TextStyle(fontSize: 110.sp)),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade700,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.6),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '🌟 Barakalla! 🌟',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
