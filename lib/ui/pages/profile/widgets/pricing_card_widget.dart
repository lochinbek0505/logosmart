import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

class PricingCardWidget extends StatelessWidget {
  final List<String> features;
  final String currentPrice;
  final String oldPrice;

  const PricingCardWidget({
    Key? key,
    required this.features,
    required this.currentPrice,
    required this.oldPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15.r,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sarlavha
          Text(
            "Siz uchun",
            style: GoogleFonts.nunito(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_900,
            ),
          ),
          SizedBox(height: 10.h),

          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  // Rasm/Ikonka qismi
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.15),
                    ),
                    child: SvgPicture.asset("assets/icons/green_sub.svg"),
                    // child: Image.asset("assets/icons/green_sub.svg"),
                  ),
                  SizedBox(width: 5.w),

                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.nunito(
                        fontSize: 12.sp,
                        color: AppColors.grey_600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentPrice,
                style: GoogleFonts.nunito(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.main_blue_900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "UZS",
                style: GoogleFonts.nunito(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.main_blue_900,
                ),
              ),
            ],
          ),

          Text(
            "$oldPrice uzs",
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              color: AppColors.grey_600,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
