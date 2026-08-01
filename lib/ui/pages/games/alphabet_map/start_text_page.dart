import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/level_state.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../breath_game/breath_game.dart';
import '../../cv_model/camera_page.dart';

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

  void _onStartPressed() {
    // Xatolik oldini olish uchun avval ro'yxat bo'sh emasligini tekshiramiz
    if (widget.data.exercise?.steps.isNotEmpty == true) {
      widget.data.exercise!.steps.removeAt(0);
    }

    if (widget.data.mode == "exercise") {
      // Birinchi bosqichni bosganda:
      context.read<LevelProvider>().setCurrentLevel(widget.data.id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraPage()),
      );
    } else if (widget.data.mode == "game") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BreathPage()),
      );
    }
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
            fit: BoxFit.cover, // BoxFit.fill o'rniga cover ishlatish sifatni buzmaydi
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 1. Yuqori qism: Header (Tepaga yopishtirilgan)
              Positioned(
                top: 15.h,
                left: 0,
                right: 0,
                child: _buildHeader(),
              ),

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
                child: AnimatedStartButton(
                  onTap: _onStartPressed,
                ),
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
      width: 280.w,
      height: 165.h,
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 11.5.h),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/icons/cloud.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Transform.translate(
        offset: Offset(0, 10.h),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blueGrey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 19.sp,
          ),
        ),
      ),
    );
  }
}

/// 3D animatsiyali Start tugmasi
class AnimatedStartButton extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedStartButton({super.key, required this.onTap});

  @override
  State<AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<AnimatedStartButton> {
  bool _isPressed = false;

  void _handleTap() async {
    if (_isPressed) return;

    setState(() => _isPressed = true);
    await Future.delayed(const Duration(milliseconds: 160));
    if (mounted) setState(() => _isPressed = false);

    widget.onTap(); // Asosiy vazifani bajarish
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        width: width * 0.7,
        height: 65.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: _isPressed ? _buildPressedState() : _buildDefaultState(width),
      ),
    );
  }

  Widget _buildPressedState() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xff20B9E8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: _buildText(),
      ),
    );
  }

  Widget _buildDefaultState(double width) {
    return Container(
      padding: const EdgeInsets.only(bottom: 3),
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xff47809e),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          gradient: const LinearGradient(
            colors: [Color(0xffbee9f7), Color(0xff20B9E8)],
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: _buildText(),
        ),
      ),
    );
  }

  Widget _buildText() {
    return Text(
      "BOSHLADIK!",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22.sp,
      ),
    );
  }
}