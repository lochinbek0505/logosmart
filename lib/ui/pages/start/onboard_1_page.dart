import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

class Onboard1Page extends StatefulWidget {
  const Onboard1Page({super.key});

  @override
  State<Onboard1Page> createState() => _Onboard1PageState();
}

class _Onboard1PageState extends State<Onboard1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            "assets/images/onboard1.png",
            fit: BoxFit.cover,
            height: 390.h,
            alignment: Alignment.center,
          ),
          SizedBox(height: 33.h),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 18.0.w, vertical: 10.h),
            child: Text(
              "Logosmart ilovasiga \nXush kelibsiz!",
              style: GoogleFonts.nunito(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.sky_blue_900,
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Text(
              "The app is designed for children and their caregivers to learn about autism, find resources and connect with others in the community. Let's get started!",
              style: GoogleFonts.nunito(
                  fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 34.h,)
        ],
      ),
    );
  }
}
