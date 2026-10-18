import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

/// Hali tayyor bo'lmagan bo'limlar uchun "Tez kunda" sahifasi.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.features,
    this.onAction,
  });

  final String title;
  final String description;
  final String image;

  /// Bo'limda nimalar bo'lishi (ro'yxat ko'rinishida)
  final List<ComingSoonFeature> features;

  /// "Mashg'ulotlarga o'tish" tugmasi bosilganda
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backround_xira.webp"),
            fit: BoxFit.fill, colorFilter: context.palette.backgroundImageFilter),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            // Pastki menyu ostida qolmasligi uchun
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 110.h),
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: context.palette.textStrong,
                  ),
                ),
                SizedBox(height: 20.h),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.h, right: 10.w),
                      child: Image.asset(image, height: 220.h),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange_400,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange_400.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        "Tez kunda",
                        style: GoogleFonts.nunito(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  "Bu bo'lim tayyorlanmoqda",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: context.palette.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: context.palette.textSecondary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: context.palette.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: context.palette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nimalar bo'ladi:",
                        style: GoogleFonts.nunito(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: context.palette.textStrong,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      for (final f in features) _FeatureRow(feature: f),
                    ],
                  ),
                ),
                if (onAction != null) ...[
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main_blue_600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        "Hozircha mashg'ulotlarni davom ettiring",
                        style: GoogleFonts.nunito(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ComingSoonFeature {
  const ComingSoonFeature(this.icon, this.text);

  final IconData icon;
  final String text;
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});

  final ComingSoonFeature feature;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: context.palette.primarySoft,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              feature.icon,
              size: 20.w,
              color: context.palette.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              feature.text,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: context.palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
