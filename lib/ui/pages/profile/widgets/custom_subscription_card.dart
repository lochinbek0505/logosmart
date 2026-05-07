import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

class CustomSubscriptionCard extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String bonusText;
  final VoidCallback onTap;

  const CustomSubscriptionCard({
    Key? key,
    required this.isSelected,
    required this.title,
    required this.bonusText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: 15.h),
        child: Container(
          width: double.infinity,
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40.r),
            border: Border.all(
              color: isSelected ? AppColors.main_blue_600 : Colors.transparent,
              width: 1.5,
            ),
            // Mana shu yerda Containerga soya (elevation) va rang berildi
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // Soyaning rangi va tiniqligi
                spreadRadius: 1, // Soya qanchalik kengayishi
                blurRadius: 8, // Soya qanchalik xira (yumshoq) bo'lishi (elevation vazifasini bajaradi)
                offset: const Offset(0, 3), // Soyaning tushish burchagi (X, Y) pastga qarab
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.main_blue_600 : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppColors.main_blue_600,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),
              SizedBox(width: 16.w),

              // Asosiy matn
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.main_blue_900,
                ),
              ),

              SizedBox(width: 8.w),

              // Bonus matn (+ 1oy)
              Text(
                bonusText,
                style: GoogleFonts.nunito(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.green_600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}