import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';

class SoundGamePage extends StatefulWidget {
  const SoundGamePage({super.key});

  @override
  State<SoundGamePage> createState() => _SoundGamePageState();
}

class _SoundGamePageState extends State<SoundGamePage> {
  Map<String, dynamic> _config = {
    "start_voice": "assets/sound/breath/breath_start.mp3",
    "blow_voice": "assets/sound/breath/butterfly.mp3",
    "lottie_animation": "assets/animation/breath/butterfly.json",
    "background_image": "assets/backround/breath/butterfly_background.jpg",
    "icon_star": "assets/icons/star.png",
    "icon_arrow": "assets/icons/arrow_right_button.png",
    "animation_position": 30,
  };

  var list1 = ["", "KE", "TA"];
  var list2=["YA","RA","LA"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: AppColors.grey_50),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            _buildHeader(10),
            SizedBox(height: 80.h),
            Expanded(
              flex: 2,
              child: Center(
                child: Image.asset(
                  "assets/game/sound_game/rocket.png",
                  width: 140.w,
                  height: 140.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 80.h),
            Wrap(
              spacing: 12.w, // Yonma-yon elementlar orasidagi masofa
              runSpacing: 12.h, // Qatorlar orasidagi masofa
              alignment: WrapAlignment.center,
              children: [
                ...list1.map((text)=>_firstContain(text))

              ],
            ),
            SizedBox(height: 100.h),
            Wrap(
              spacing: 12.w, // Yonma-yon elementlar orasidagi masofa
              runSpacing: 12.h, // Qatorlar orasidagi masofa
              alignment: WrapAlignment.center,
              children: [
                ...list2.map((text)=>_secondContain(text))

              ],
            ),
            Expanded(flex: 2, child: SizedBox()),
            CircleAvatar(
              radius: 40.r,
              backgroundImage: const AssetImage("assets/icons/circle.png"),
              child: Image.asset(
                "assets/icons/micrafon.png",
                width: 26.w,
                height: 38.h,
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _firstContain(String text) {
    // Agar text bo'sh bo'lsa, o'yin uchun "bo'sh katak" (placeholder) yasaymiz
    if (text.isEmpty) {
      return Container(
        width: 90.w,
        height: 65.h,
        decoration: BoxDecoration(
          color: AppColors.grey_50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.grey_300, width: 2.h, style: BorderStyle.solid),
        ),
      );
    }

    return Container(
      width: 90.w,
      height: 65.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.main_blue_600, width: 2.h),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.grey_900,
          ),
        ),
      ),
    );
  }

  Widget _secondContain(String text) {
    return Container(
      width: 90.w,
      height: 65.h,
      decoration: BoxDecoration(
        color: AppColors.main_blue_600,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.main_blue_600.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int currentBall) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              context.read<LevelProvider>().clearCurrentLevel();
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 48.w,
              height: 48.h,
              child: (_config['icon_arrow'] is String)
                  ? Image.asset(
                      _config['icon_arrow'] as String,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: (_config['icon_star'] is String)
                    ? Image.asset(
                        _config['icon_star'] as String,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.star, color: Colors.orange),
                      )
                    : const Icon(Icons.star, color: Colors.orange),
              ),
              SizedBox(width: 8.w),
              CustomTextWidget(text: currentBall.toString(), sizeText: 32.sp),
            ],
          ),
        ],
      ),
    );
  }
}
