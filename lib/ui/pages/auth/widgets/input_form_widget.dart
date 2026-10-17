import 'package:flutter/cupertino.dart'; // Eye icon uchun
import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';

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
              color: context.palette.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            style: GoogleFonts.nunito(
              color: context.palette.textStrong,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: widget.isPhone
                ? TextInputType.phone
                : TextInputType.text,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 20.w,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: context.palette.textSecondary)
                  : null,

              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        color: context.palette.textSecondary,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(36.r),
                borderSide: BorderSide(
                  color: context.palette.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(36.r),
                borderSide: const BorderSide(
                  color: AppColors.sky_blue_500,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(36.r),
                borderSide: BorderSide(
                  color: context.palette.border,
                  width: 1,
                ),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(36.r),
                borderSide: BorderSide(
                  color: context.palette.border,
                  width: 1.5,
                ),
              ),

              errorStyle: GoogleFonts.nunito(
                color: Colors.red,
                fontSize: 12.sp,
              ),

              filled: true,
              fillColor: context.palette.surface,
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
