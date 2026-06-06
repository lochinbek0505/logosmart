import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/iafp_widget.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/path_drag_game_widget.dart';
import 'package:logosmart/ui/pages/main/widgets/custom_text_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

class ItemAndFinishPathGamePage extends StatefulWidget {
  const ItemAndFinishPathGamePage({super.key});

  @override
  State<ItemAndFinishPathGamePage> createState() =>
      _ItemAndFinishPathGamePageState();
}

class _ItemAndFinishPathGamePageState extends State<ItemAndFinishPathGamePage> {
  final level1 = {
    "startPoint": {"x": 0.15, "y": 0.9},
    "segments": [
      {
        "cp1": {"x": 1.5, "y": 0.7},
        "cp2": {"x": -0.5, "y": 0.3},
        "endPoint": {"x": 0.85, "y": 0.1},
      },
    ],
  };

  final level2 = {
    "startPoint": {"x": 0.40, "y": 0.05},
    "segments": [
      {
        "type": "line",
        "endPoint": {"x": 0.85, "y": 0.02},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.35, "y": 0.25},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.95, "y": 0.35},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.15, "y": 0.45},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.90, "y": 0.60},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.05, "y": 0.70},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.80, "y": 0.85},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.40, "y": 0.95},
      },
    ],
  };

  final level3 = {
    "startPoint": {"x": 0.10, "y": 0.05},
    "segments": [
      {
        "type": "line",
        "endPoint": {"x": 0.95, "y": 0.05},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.95, "y": 0.95},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.20, "y": 0.95},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.20, "y": 0.25},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.75, "y": 0.25},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.75, "y": 0.75},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.40, "y": 0.75},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.40, "y": 0.45},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.60, "y": 0.45},
      },
    ],
  };

  final level4 = {
    "startPoint": {"x": 0.60, "y": 0.05},
    "segments": [
      {
        "type": "curve",
        "cp1": {"x": 0.00, "y": 0.05},
        "cp2": {"x": 0.00, "y": 0.35},
        "endPoint": {"x": 0.90, "y": 0.35},
      },
      {
        "type": "curve",
        "cp1": {"x": 1.0, "y": 0.35},
        "cp2": {"x": 1.30, "y": 0.65},
        "endPoint": {"x": 0.10, "y": 0.65},
      },
      {
        "type": "curve",
        "cp1": {"x": 0, "y": 0.65},
        "cp2": {"x": -0.30, "y": 0.95},
        "endPoint": {"x": 0.90, "y": 0.90},
      },
      {
        "type": "curve",
        "cp1": {"x": 1.10, "y": 0.90},
        "cp2": {"x": 0.60, "y": 0.95},
        "endPoint": {"x": 0.30, "y": 1},
      },
    ],
  };

  final level5 = {
    "startPoint": {"x": 0.60, "y": 0.05},
    "segments": [
      {
        "type": "curve",
        "cp1": {"x": 0.85, "y": 0.05},
        "cp2": {"x": 0.95, "y": 0.25},
        "endPoint": {"x": 0.95, "y": 0.45},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.95, "y": 0.75},
        "cp2": {"x": 0.75, "y": 0.90},
        "endPoint": {"x": 0.50, "y": 0.90},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.25, "y": 0.90},
        "cp2": {"x": 0.10, "y": 0.70},
        "endPoint": {"x": 0.10, "y": 0.45},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.10, "y": 0.20},
        "cp2": {"x": 0.25, "y": 0.2},
        "endPoint": {"x": 0.50, "y": 0.25},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.70, "y": 0.3},
        "cp2": {"x": 0.75, "y": 0.50},
        "endPoint": {"x": 0.75, "y": 0.50},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.75, "y": 0.65},
        "cp2": {"x": 0.60, "y": 0.70},
        "endPoint": {"x": 0.55, "y": 0.70},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.25, "y": 0.70},
        "cp2": {"x": 0.2, "y": 0.60},
        "endPoint": {"x": 0.25, "y": 0.50},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.3, "y": 0.40},
        "cp2": {"x": 0.45, "y": 0.40},
        "endPoint": {"x": 0.55, "y": 0.45},
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            color: AppColors.grey_50,
            child: Container(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 56.w,
                              height: 56.h,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Image.asset(
                                  "assets/icons/arrow_right_button.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/star.png",
                                  width: 40.w,
                                  height: 40.h,
                                ),
                                const SizedBox(width: 12),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      "12",
                                      style: TextStyle(
                                        fontSize: 35.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      transitionBuilder: (c, a) =>
                                          ScaleTransition(scale: a, child: c),
                                      child: CustomTextWidget(text: '12'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 120.h),
                        SizedBox(
                          height: 430.h,
                          child: IafpWidget(
                            pathConfig: PathConfig.fromJson(level1),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        CircleAvatar(
                          radius: 40.r,
                          backgroundImage: const AssetImage(
                            "assets/icons/circle.png",
                          ),
                          child: Image.asset(
                            "assets/icons/micrafon.png",
                            width: 26.w,
                            height: 38.r,
                          ),
                        ),
                      ],
                    ),
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
