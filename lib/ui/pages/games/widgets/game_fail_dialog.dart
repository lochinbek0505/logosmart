import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/service/app_settings.dart';
import 'package:logosmart/ui/pages/games/widgets/kid_widgets.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../alphabet_map/provider/level_provider.dart';
import 'package:logosmart/core/resources/app_resources.dart';

/// Bola bitta o'yinda shuncha marta xato qilsa o'yin ballsiz yakunlanadi
/// va keyingi o'yin ochiladi
const int kMaxGameMistakes = 2;

/// Ovozli o'yinlarda "eshitilmagan" urinish (bo'sh javob — STT nutq topmadi,
/// yoki tarmoq/STT xatosi) bola xatosi hisoblanmaydi, lekin bola cheksiz
/// aylanib qolmasligi uchun shuncha bo'lsa o'yin baribir o'tkazib yuboriladi
const int kMaxUnheardAttempts = 4;

/// Ovozli o'yinlar uchun urinishlar hisobi
class GameAttempts {
  int mistakes = 0;
  int unheard = 0;

  /// Noto'g'ri urinishni qayd qiladi: [counted] — bola xatosi (noto'g'ri
  /// aytdi), aks holda eshitilmagan urinish. O'yin ballsiz tugashi kerak
  /// bo'lsa true.
  bool register({required bool counted}) {
    if (counted) {
      mistakes++;
    } else {
      unheard++;
    }
    return mistakes >= kMaxGameMistakes || unheard >= kMaxUnheardAttempts;
  }
}

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
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (dialogContext, _, __) => GameFailDialog(
        onContinue: () {
          provider.clearCurrentLevel();
          Navigator.pop(dialogContext); // Dialogni yopish
          Navigator.pop(context); // Xaritaga qaytish
        },
      ),
      transitionBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
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

class _GameFailDialogState extends State<GameFailDialog> {
  static const _warm = [Color(0xFFFFC754), Color(0xFFFF8A00)];

  @override
  Widget build(BuildContext context) {
    final heroSize = 116.w;
    return Center(
      child: Material(
        type: MaterialType.transparency,
        // Kichik ekran / katta shriftda sig'masa — aylantiriladi
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Asosiy karta
                Container(
                  margin: EdgeInsets.only(top: heroSize / 2),
                  padding: EdgeInsets.fromLTRB(
                    22.w,
                    heroSize / 2 + 16.h,
                    22.w,
                    24.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFFFF6E1)],
                    ),
                    borderRadius: BorderRadius.circular(34.r),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: _warm.last.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PopIn(
                        delay: 150,
                        child: Text(
                          "Hechqisi yo'q!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.sky_blue_900,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      const _EmptyStars(),
                      SizedBox(height: 14.h),
                      _PopIn(
                        delay: 700,
                        child: Text(
                          "Bu safar ball to'play olmading,\nlekin juda yaxshi harakat qilding!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: AppColors.light_blue_900,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _PopIn(
                        delay: 850,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5B0),
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: Text(
                            "Keyingi o'yinda albatta uddalaysan!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.orange_800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _PopIn(
                        delay: 1000,
                        child: SizedBox(
                          width: double.infinity,
                          child: KidBounceButton(
                            label: "Keyingi o'yin",
                            colors: const [
                              Color(0xFF5EE07A),
                              Color(0xFF1FAA4B),
                            ],
                            leading: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                            onPressed: widget.onContinue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Yuqoridagi qahramon: suzib turgan doira ichida animatsiya
                SizedBox(
                  width: heroSize * 2.2,
                  height: heroSize * 1.2,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      const KidTwinkleStars(
                        positions: [
                          Alignment(-0.95, -0.1),
                          Alignment(-0.65, 0.8),
                          Alignment(0.9, -0.4),
                          Alignment(0.7, 0.75),
                        ],
                        size: 20,
                      ),
                      KidFloating(
                        amplitude: 6,
                        tilt: 0.05,
                        child: Container(
                          width: heroSize,
                          height: heroSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _warm,
                            ),
                            border: Border.all(color: Colors.white, width: 5),
                            boxShadow: [
                              BoxShadow(
                                color: _warm.last.withValues(alpha: 0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: AppLottie.asset(
                            'assets/animation/xato.json',
                            width: heroSize * 0.78,
                            height: heroSize * 0.78,
                            repeat: false,
                            // Animatsiya hali yuklanmagan bo'lsa — kulib turgan yuz
                            errorBuilder: (_, _, _) => Icon(
                              Icons.sentiment_satisfied_alt_rounded,
                              size: heroSize * 0.6,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bo'sh (kulrang) yulduzlar ketma-ket "sakrab" chiqadi va qimirlab turadi.
class _EmptyStars extends StatelessWidget {
  const _EmptyStars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _PopIn(
              delay: 300 + i * 140,
              child: KidWiggle(
                child: Image.asset(
                  "assets/icons/star_grey.webp",
                  // O'rtadagi yulduz kattaroq
                  width: i == 1 ? 46.w : 36.w,
                  height: i == 1 ? 46.w : 36.w,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// [delay] ms dan keyin elastik kattalashib paydo bo'ladi.
class _PopIn extends StatelessWidget {
  const _PopIn({required this.delay, required this.child});

  final int delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const appear = 500;
    final total = delay + appear;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.elasticOut),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: t, child: child),
      ),
      child: child,
    );
  }
}
