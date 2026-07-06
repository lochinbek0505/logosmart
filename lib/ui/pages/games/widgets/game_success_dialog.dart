import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:logosmart/ui/theme/app_colors.dart'; // O'zingizdagi yo'lga moslang

class GameSuccessDialog extends StatelessWidget {
  final int earnedScore;
  final VoidCallback onContinue;

  const GameSuccessDialog({
    super.key,
    required this.earnedScore,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
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
            // Yutuq animatsiyasi
            Lottie.asset(
              'assets/animation/success.json',
              width: 120.w,
              height: 120.h,
              repeat: false,
            ),

            Text(
              "Tabriklayman",
              style: GoogleFonts.nunito(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.sky_blue_900,
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              "O'yinni muvaffaqiyatli yakunlading!\n +$earnedScore Ball",
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
                onPressed: onContinue,
                child: Text(
                  "Davom etish",
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