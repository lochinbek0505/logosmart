import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15.r,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
              color: context.palette.textStrong,
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
                      color: Colors.green.withValues(alpha: 0.15),
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
                        color: context.palette.textSecondary,
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
                  color: context.palette.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "UZS",
                style: GoogleFonts.nunito(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: context.palette.textPrimary,
                ),
              ),
            ],
          ),

          Text(
            "$oldPrice uzs",
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              color: context.palette.textSecondary,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
