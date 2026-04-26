import 'package:flutter/cupertino.dart'; // Eye icon uchun
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/AppColors.dart';

class InputFormWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool isPhone;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const InputFormWidget({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.isPassword = false,
    this.isPhone = false,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<InputFormWidget> createState() => _InputFormWidgetState();
}

class _InputFormWidgetState extends State<InputFormWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 15.w, bottom: 8.h),
          child: Text(
            widget.label,
            style: GoogleFonts.nunito(
              color: AppColors.grey_700,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w), // O'ng tomondan ham padding berildi
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            style: GoogleFonts.nunito(
              color: AppColors.grey_900,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: widget.isPhone ? TextInputType.phone : TextInputType.text,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
              prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: AppColors.grey_700) : null,

              suffixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                  _obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  color: AppColors.grey_700,
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText; // Holatni teskarisiga o'zgartirish
                  });
                },
              )
                  : null,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(36.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(36.r),
                borderSide: const BorderSide(
                  color: AppColors.light_grey_500,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(36.r),
                borderSide: const BorderSide(
                  color: AppColors.light_grey_500,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder( // Xatolik bo'lgandagi border
                borderRadius: BorderRadius.circular(36.r),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}