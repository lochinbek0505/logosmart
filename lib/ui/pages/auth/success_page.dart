import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

import '../main/HomePage.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light_blue_400, // Yoki havorang fon
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 400.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(
                  MediaQuery.of(context).size.width,
                  180.h,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 28.sp,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // Asosiy rasm (pastga yopishib turadi)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      "assets/images/success_person.png",
                      width: 230.w,
                      // Rasm o'lchamini dizaynga moslashtirish mumkin
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40.h),

          // 2. Matnlar
          Text(
            "Muvaffaqiyatli",
            style: GoogleFonts.nunito(
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_900,
              // To'q ko'k/kulrang tus
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Muvaffaqiyatli bajarildi",
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              color: AppColors.grey_700, // To'q ko'k/kulrang tus
            ),
          ),

          const Spacer(),

          // 3. Pastki "Keyingi" tugmasi
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 50.h),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main_blue_600, // Tugma rangi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => const HomePage()),
                    (Route<dynamic> route) =>
                        false, // false qaytsa, barcha eski sahifalar tozalanadi
                  );
                },
                child: Text(
                  "Keyingi",
                  style: GoogleFonts.nunito(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
