import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/widgets/otp_input_field.dart';
import 'package:logosmart/ui/theme/AppColors.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  bool isTimerActive = false;
  int _remainingSeconds = 60;
  bool _isTimerActive = true;
  String _enteredOtp = '';
  Timer? _timer;

  void _startTimer() {
    setState(() {
      _remainingSeconds = 60;
      _isTimerActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _isTimerActive = false; // Vaqt tugadi, tugma ko'rinadi
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleResend() {
    print("Yangi SMS yuborildi!");

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 28.h),
              Text(
                'Telefon raqamini tasdiqlash',
                style: GoogleFonts.nunito(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey_900,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '***1234 raqamli telefoningizga tasdiqlash\nkodi yuborildi',
                style: GoogleFonts.nunito(
                  fontSize: 16.sp,
                  color: AppColors.grey_700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 36.w),
              OtpInputField(
                isTimerActive: _isTimerActive,
                remainingSeconds: _remainingSeconds,
                onResendTap: _handleResend,
                onChanged: (value) {
                  _enteredOtp = value;
                  print("Hozirgi yozilgan kod: $_enteredOtp");
                },
                onCompleted: (value) {
                  print("Kod to'liq yozildi: $value");
                  // Bu yerda bevosita backend ga kodni tekshirishga yuborishingiz mumkin
                },
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main_blue_600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36.r),
                    ),
                    padding:  EdgeInsets.symmetric(vertical: 16.h,horizontal: 20.w),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Tasdiqlash",
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
