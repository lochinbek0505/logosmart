import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/animated_start_button.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/level_state.dart';
import '../../cv_model/camera_page.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../arrow_game/arrow_game_page.dart';
import '../breath_game/breath_game.dart';
import '../cloud_game/cloud_game_page.dart';
import '../cooking/cooking_page.dart';
import '../drag_drop/drag_drop_game_page.dart';
import '../find_image_game/find_image_game_page.dart';
import '../hand_game/hand_game_page.dart';
import '../puzzle_game/puzzle_game_widget.dart';
import 'map_route_page.dart';

class StartTextPage extends StatefulWidget {
  final LevelState data;

  const StartTextPage({super.key, required this.data});

  @override
  State<StartTextPage> createState() => _StartTextPageState();
}

class _StartTextPageState extends State<StartTextPage> {
  // Rasm va ikonka yo'llari o'zgaruvchilarda saqlangan
  static const String _backBtn = "assets/icons/arrow_right_button.png";
  static const String _starIcon = "assets/icons/star.png";
  static const String _bgImage = "assets/backround/fon_q.png";
  static const String _womenImage = "assets/images/women.png";
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _playAudioAndWait(widget.data.exercise!.steps.first.sound!);
  }

  void _onStartPressed() {
    // Xatolik oldini olish uchun avval ro'yxat bo'sh emasligini tekshiramiz
    if (widget.data.exercise?.steps.isNotEmpty == true) {
      widget.data.exercise!.steps.removeAt(0);
    }

    if (widget.data.mode == "exercise") {
      // Birinchi bosqichni bosganda:
      context.read<LevelProvider>().setCurrentLevel(widget.data.id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CameraPage()),
      );
    } else if (widget.data.mode == "game") {
      navigationTo(widget.data.game!.type);
    }
  }

  Future<void> _playAudioAndWait(String path) async {
    final completer = Completer<void>();
    StreamSubscription<void>? subscription;

    subscription = _audioPlayer.onPlayerComplete.listen((_) {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete();
    });

    await _audioPlayer.play(AssetSource(path));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_bgImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 1. Yuqori qism: Header (Tepaga yopishtirilgan)
              Positioned(top: 15.h, left: 0, right: 0, child: _buildHeader()),

              // 2. O'rta qism: Matnli bulutcha
              Positioned(
                top: 100.h,
                child: _CloudText(
                  text: widget.data.exercise?.steps.first.text ?? "",
                ),
              ),

              // 3. Qahramon (Ayol) rasmi (Tugmadan teparoqda turishi uchun)
              Positioned(
                bottom: 110.h,
                child: Image.asset(
                  _womenImage,
                  height: 380.h, // Rasmni ekranga qarab proporsional moslash
                  fit: BoxFit.contain,
                ),
              ),

              // 4. Pastki qism: Tugma (Pastga yopishtirilgan)
              Positioned(
                bottom: 30.h,
                child: AnimatedStartButton(onTap: _onStartPressed, text: "BOSHLADIK"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.asset(
              _backBtn,
              width: 48.w,
              height: 48.h,
              fit: BoxFit.fill,
            ),
          ),
          Row(
            children: [
              Image.asset(_starIcon, width: 32.w, height: 32.h),
              SizedBox(width: 8.w),
              CustomTextWidget(text: "0", sizeText: 32.sp),
            ],
          ),
        ],
      ),
    );
  }

  void navigationTo(String type) {
    Widget? page;

    // Har bir case uchun shunchaki kerakli Widget ni aniqlab olamiz
    switch (type) {
      case "breath":
        page = const BreathPage();
        break;
      case "arrow":
        page = const ArrowGamePage();
        break;
      case "cloud":
        page = const CloudGamePage();
        break;
      case "cooking":
        page = const CookingPage();
        break;
      case "drag_drop":
        page = const DragDropGamePage();
        break;
      case "find_image_page":
        page = const FindImageGamePage();
        break;
      case "hand_game":
        page = const HandGamePage();
        break;
      case "path_game":
        page = MapRoadPage();
        break;
      case "puzzle_game":
        page = const PuzzleGameWidget();
        break;
    }

    if (page != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    _audioPlayer.dispose();
  }
}

// ==========================================
// KICHIK WIDGETLAR UCHUN ALOHIDA KLASSLAR
// ==========================================

/// Matnli Bulutcha widgeti
class _CloudText extends StatelessWidget {
  final String text;

  const _CloudText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.w,
      height: 190.h,
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: 11.5.h,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/icons/cloud.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Transform.translate(
        offset: Offset(0, 25.h),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: AppColors.main_blue_900,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
      ),
    );
  }
}
