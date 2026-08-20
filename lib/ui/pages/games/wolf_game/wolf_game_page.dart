import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../alphabet_map/widgets/cloud_text.dart';

class WolfGamePage extends StatefulWidget {
  const WolfGamePage({super.key});

  @override
  State<WolfGamePage> createState() => _WolfGamePageState();
}

class _WolfGamePageState extends State<WolfGamePage> {
  final Map<String, dynamic> _config = {
    "start_voice": "assets/sound/breath/breath_start.mp3",
    "blow_voice": "assets/sound/breath/butterfly.mp3",
    "lottie_animation": "assets/animation/breath/butterfly.json",
    "background_image": "assets/backround/breath/butterfly_background.jpg",
    "icon_star": "assets/icons/star.png",
    "icon_arrow": "assets/icons/arrow_right_button.png",
    "animation_position": 30,
  };

  final List<String> list = [
    "assets/game/wolf_game/bird_house.png",
    "assets/game/wolf_game/cave.png",
    "assets/game/wolf_game/dog_house.png",
    "assets/game/wolf_game/department.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey_50,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildHeader(10),
            SizedBox(height: 30.h),
            CloudText(
              text: "Uyni topishga yordam bering!",
              fontSize: 19.sp,
              width: 270.w,
              height: 170.h,
            ),
            Image.asset(
              "assets/game/wolf_game/wolf.png",
              height: 170.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 40.h,),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return buildPetScene(list[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPetScene(String image) {
    final double houseWidth = 80.w;
    final double houseHeight = 80.h;
    final double speakerSize = 50.w;
    final double sceneHeight = 100.h;

    return SizedBox(
      width: double.infinity,
      height: sceneHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              image,
              width: houseWidth,
              height: houseHeight,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: (houseHeight / 2) + 10.h,
            left: 10.w,
            child: Image.asset(
              'assets/game/wolf_game/music.png',
              width: speakerSize,
              height: speakerSize,
            ),
          ),
        ],
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