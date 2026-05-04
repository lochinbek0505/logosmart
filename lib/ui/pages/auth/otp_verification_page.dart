import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/auth/reset_password_page.dart';
import 'package:logosmart/ui/pages/auth/success_page.dart' show SuccessPage;
import 'package:logosmart/ui/pages/auth/widgets/otp_input_field.dart';
import 'package:logosmart/ui/pages/home/home_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class OtpVerificationPage extends StatefulWidget {
  String phone;
  String check;

  OtpVerificationPage({super.key, required this.check, required this.phone});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  bool isTimerActive = false;
  int _remainingSeconds = 60;
  bool _isTimerActive = true;
  String _enteredOtp = '';
  Timer? _timer;
  final GlobalKey<OtpInputFieldState> _otpKey = GlobalKey<OtpInputFieldState>();
  final TextEditingController _otpController = TextEditingController();

  String maskPhoneNumber(String phone) {
    if (phone.length < 4)
      return phone; // Raqam juda qisqa bo'lsa o'zini qaytaradi

    String lastFour = phone.substring(phone.length - 4);
    return '***$lastFour';
  }

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
    var provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.w),
          onPressed: () {
            Navigator.pop(context);

            // switch (widget.check) {
            //   case "register":
            //     print("Ro'yxatdan o'tish jarayonidan chiqish");
            //     break;
            //   case "forgot_password":
            //     print("Parolni tiklash jarayonidan chiqish");
            //     break;
            //   case "login":
            //     Navigator.pop(context);
            //
            //     break;
            // }
          },
        ),
      ),
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
                '${maskPhoneNumber(widget.phone)} raqamli telefoningizga tasdiqlash\nkodi yuborildi',
                style: GoogleFonts.nunito(
                  fontSize: 16.sp,
                  color: AppColors.grey_700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 36.w),
              OtpInputField(
                key: _otpKey,
                isTimerActive: _isTimerActive,
                remainingSeconds: _remainingSeconds,
                onResendTap: _handleResend,
                onChanged: (value) {
                  _enteredOtp = value;
                  print("Hozirgi yozilgan kod: $_enteredOtp");
                },
                onCompleted: (value) {
                  print("Kod to'liq yozildi: $value");
                },
                controller: _otpController,
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
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 20.w,
                    ),
                    disabledBackgroundColor: AppColors.main_blue_600
                        .withOpacity(0.7),
                  ),
                  // DIQQAT: loading vaqtida qayta bosib yubormaslik uchun
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (_otpKey.currentState?.validate() ?? false) {
                            FocusScope.of(
                              context,
                            ).unfocus(); // Klaviaturani yopish

                            switch (widget.check) {
                              case "register":
                                bool isSuccess = await provider.registerVerify(
                                  context,
                                  widget.phone,
                                  _enteredOtp,
                                );
                                if (isSuccess && context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (builder) => const SuccessPage(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                                break;
                              case "forgot_password":
                                bool isSuccess = await provider.forgetVerifyOtp(
                                  context,
                                  {
                                    "phoneNumber": widget.phone,
                                    "code": _enteredOtp,
                                  },
                                );
                                if (isSuccess && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (builder) =>
                                           ResetPasswordPage(phone: widget.phone),
                                    ),
                                  );
                                }
                                break;
                              case "login":
                                bool isSuccess = await provider.loginVerify(
                                  context,
                                  widget.phone,
                                  _enteredOtp,
                                );
                                if (isSuccess && context.mounted) {
                                  // pushReplacement orqali orqaga qaytishni yopib yuboramiz
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (builder) => const SuccessPage(),
                                    ),
                                    (Route<dynamic> route) =>
                                        false, // false qaytsa, barcha eski sahifalar tozalanadi
                                  );
                                }
                                break;
                            }
                          }
                        },
                  child: provider.isLoading
                      ? SizedBox(
                          height: 24.h,
                          width: 24.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
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
