import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:wave_linear_progress_indicator/wave_linear_progress_indicator.dart';

import '../main/main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff12A9E1), Color(0xff12E3F0)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/splash_logo.png",
              width: 650.w,
              height: 650.h,
              fit: BoxFit.contain,
            ),
            SizedBox(
              width: 343.w,
              child: Text(
                'Loading..',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              onEnd: () {
                if (_navigated) return;
                _navigated = true;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainPage()),
                );
              },
              builder: (context, value, _) {
                return SizedBox(
                  width: 343.w,
                  child: Column(
                    children: [
                      WaveLinearProgressIndicator(
                        value: value,
                        minHeight: 16.h,
                        borderRadius: 32.r,
                        waveColor: AppColors.orange_500,
                        waveBackgroundColor: AppColors.orange_100,
                        enableBounceAnimation: true,
                      ),
                      SizedBox(height: 17.h),
                      Text(
                        '${(value * 100).toInt()}%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
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
