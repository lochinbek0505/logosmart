import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';

class TrainGamePage extends StatefulWidget {
  const TrainGamePage({super.key});

  @override
  State<TrainGamePage> createState() => _TrainGamePageState();
}

class _TrainGamePageState extends State<TrainGamePage> {
  final Random _random = Random();
  final List<Offset> _randomPositions = [];

  Map<String, dynamic> _config = {
    "start_voice": "assets/sound/breath/breath_start.mp3",
    "blow_voice": "assets/sound/breath/butterfly.mp3",
    "lottie_animation": "assets/animation/breath/butterfly.json",
    "background_image": "assets/backround/breath/butterfly_background.jpg",
    "icon_star": "assets/icons/star.png",
    "icon_arrow": "assets/icons/arrow_right_button.png",
    "animation_position": 30,
  };

  // 4 ta rasmning manzillari (o'zingizdagi rasmlarga o'zgartiring)
  final List<String> _randomImages = [
    "assets/game/train_game/dog.png",
    "assets/game/train_game/gul.png",
    "assets/game/train_game/cock.png",
    "assets/game/train_game/helicopter.png",
  ];

  @override
  void initState() {
    super.initState();
    // 0.0 dan 1.0 gacha bo'lgan ixtiyoriy (random) pozitsiyalarni yaratish
    for (int i = 0; i < 4; i++) {
      _randomPositions.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppColors.grey_50),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            _buildHeader(10),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Image.asset("assets/game/train_game/train.png"),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // Rasmlar orasida bir xil joy tashlash
                    children: List.generate(4, (index) {
                      return Container(
                        width: 75.w,
                        // Kartochka kengligi
                        height: 140.h,
                        // Kartochka balandligi
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E9F2),
                          // Kartochka orqa foni (och ko'k-kulrang)
                          borderRadius: BorderRadius.circular(
                            16.r,
                          ), // Burchaklarni yumaloqlash
                        ),
                        child: Center(
                          child: Image.asset(
                            _randomImages[index],
                            // O'zingizdagi rasm manzillari ro'yxati
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
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
