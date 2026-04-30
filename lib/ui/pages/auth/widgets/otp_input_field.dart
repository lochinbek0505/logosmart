import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:pinput/pinput.dart';

class OtpInputField extends StatefulWidget {
  final bool isTimerActive;
  final int remainingSeconds;
  final VoidCallback onResendTap;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller; // Kodni o'qish uchun qo'shildi

  const OtpInputField({
    super.key,
    required this.isTimerActive,
    required this.remainingSeconds,
    required this.onResendTap,
    required this.controller,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Silkinish animatsiyasini sozlash
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // Validatsiya funksiyasi (Tashqaridan chaqiriladi)
  bool validate() {
    if (widget.controller.text.length < 4) {
      setState(() => _hasError = true);
      _shakeController.forward(from: 0.0); // Animatsiyani ishga tushirish
      return false; // Validatsiyadan o'tmadi
    }
    setState(() => _hasError = false);
    return true; // Hammasi joyida
  }

  String get _formattedTime {
    int minutes = widget.remainingSeconds ~/ 60;
    int seconds = widget.remainingSeconds % 60;
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

    // Qizil xatolik temasi
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.red_500, width: 1.5.w), // Agar AppColors da qizil rang boshqacha nomlangan bo'lsa o'zgartiring
      borderRadius: BorderRadius.circular(12.r),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              );
            },
            child: Pinput(
              length: 4,
              controller: widget.controller,
              separatorBuilder: (a) => SizedBox(width: 12.w),
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: focusedPinTheme,
              errorPinTheme: errorPinTheme, // Xato bo'lganda shu ishladi
              forceErrorState: _hasError,   // Holatni boshqarish
              showCursor: true,
              cursor: Container(
                width: 2.w,
                height: 24.h,
                color: const Color(0xFF4DB6E1),
              ),
              onCompleted: (value) {
                setState(() => _hasError = false);
                if (widget.onCompleted != null) widget.onCompleted!(value);
              },
              onChanged: (value) {
                // Foydalanuvchi yozishni boshlasa xatolikni olib tashlaymiz
                if (_hasError) setState(() => _hasError = false);
                if (widget.onChanged != null) widget.onChanged!(value);
              },
            ),
          ),
        ),

        SizedBox(height: 24.h),

        if (widget.isTimerActive)
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
            onTap: widget.onResendTap,
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