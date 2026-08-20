import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_colors.dart';

class CloudText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final double? width;
  final double? height;

  CloudText({required this.text, this.fontSize, this.width, this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 320.w,
      height: height ?? 190.h,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 11.5.h,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/icons/cloud.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Transform.translate(
        offset: Offset(0, 25.h),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: AppColors.main_blue_900,
            fontWeight: FontWeight.w600,
            fontSize: fontSize ?? 18.sp,
          ),
        ),
      ),
    );
  }
}
