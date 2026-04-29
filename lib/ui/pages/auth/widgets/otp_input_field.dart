import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/AppColors.dart';
import 'package:pinput/pinput.dart';

class OtpInputField extends StatelessWidget {
  final bool isTimerActive;
  final int remainingSeconds;
  final VoidCallback onResendTap;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputField({
    super.key,
    required this.isTimerActive,
    required this.remainingSeconds,
    required this.onResendTap,
    this.onCompleted,
    this.onChanged,
  });

  String get _formattedTime {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 56.h,
      textStyle: GoogleFonts.nunito(
        fontSize: 20.sp,
        color: AppColors.grey_900,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.light_grey_500, width: 1.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF4DB6E1), width: 1.5.w),
      borderRadius: BorderRadius.circular(12.r),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Pinput(
            length: 4,
            separatorBuilder: (a) => SizedBox(width: 12.w),
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: focusedPinTheme,
            showCursor: true,
            cursor: Container(
              width: 2.w,
              height: 24.h,
              color: const Color(0xFF4DB6E1),
            ),
            onCompleted: onCompleted,
            onChanged: onChanged,
          ),
        ),

        SizedBox(height: 24.h),

        if (isTimerActive)
          Text(
            _formattedTime,
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey_900,
            ),
          )
        else
          GestureDetector(
            onTap: onResendTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 20.sp, color: AppColors.grey_900),
                SizedBox(width: 8.w),
                Text(
                  'Qayta yuborish',
                  style: GoogleFonts.nunito(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey_900,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
