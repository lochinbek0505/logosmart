import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:logosmart/core/service/app_settings.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../alphabet_map/provider/level_provider.dart';

/// Bola bitta o'yinda shuncha marta xato qilsa o'yin ballsiz yakunlanadi
/// va keyingi o'yin ochiladi
const int kMaxGameMistakes = 3;

/// Xatolar limiti tugaganda chaqiriladi: dialog ko'rsatiladi, joriy o'yin
/// uchun ball/yulduz berilmaydi ([revokeBall] — shu o'yinda oraliq qadamlarda
/// berilgan ball qaytarib olinadi), lekin keyingi o'yin ochiladi.
Future<void> showGameFailDialog(
  BuildContext context, {
  int revokeBall = 0,
}) async {
  final provider = context.read<LevelProvider>();
  AppSettings().vibrateError();

  // Avval dialog ekranni qoplaydi, provider holati keyin o'zgaradi
  // (GameSuccessDialog bilan bir xil tartib)
  unawaited(
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'game_fail',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (dialogContext, _, __) => GameFailDialog(
        onContinue: () {
          provider.clearCurrentLevel();
          Navigator.pop(dialogContext); // Dialogni yopish
          Navigator.pop(context); // Xaritaga qaytish
        },
      ),
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeIn,
            ),
            child: child,
          ),
        );
      },
    ),
  );

  await Future.delayed(const Duration(milliseconds: 50));
  if (revokeBall > 0) provider.addBall(-revokeBall);
  // stars: 0 — joriy o'yinga yulduz berilmaydi, faqat keyingisi ochiladi
  await provider.unlock(stars: 0);
}

class GameFailDialog extends StatefulWidget {
  final VoidCallback onContinue;

  const GameFailDialog({super.key, required this.onContinue});

  @override
  State<GameFailDialog> createState() => _GameFailDialogState();
}

class _GameFailDialogState extends State<GameFailDialog>
    with SingleTickerProviderStateMixin {
  // Lottie tugagach yengil "tebranib turish" animatsiyasi
  late final AnimationController _wobbleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _wobbleController,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_wobbleController.value);
                return Transform.rotate(angle: (t - 0.5) * 0.12, child: child);
              },
              child: Lottie.asset(
                'assets/animation/xato.json',
                width: 120.w,
                height: 120.h,
                repeat: false,
                onLoaded: (composition) {
                  // Lottie bir marta o'ynab bo'lgach tebranish boshlanadi
                  Future.delayed(composition.duration, () {
                    if (mounted) _wobbleController.repeat(reverse: true);
                  });
                },
              ),
            ),

            Text(
              "Hechqisi yo'q!",
              style: GoogleFonts.nunito(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.sky_blue_900,
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              "Bu safar ball ololmading.\nKeyingi o'yinda yaxshilab urinib ko'r!",
              style: GoogleFonts.nunito(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.light_blue_900,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main_blue_600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 48.w,
                    vertical: 16.h,
                  ),
                  elevation: 5,
                ),
                onPressed: widget.onContinue,
                child: Text(
                  "Keyingi o'yin",
                  style: GoogleFonts.nunito(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
