import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../widgets/game_success_dialog.dart';

class HandGamePage extends StatefulWidget {
  const HandGamePage({super.key});

  @override
  State<HandGamePage> createState() => _HandGamePageState();
}

const String _backBtn = "assets/icons/arrow_right_button.png";
const String _starIcon = "assets/icons/star.png";
const String _startVoice = "sound/hand_game/hand_game_start.mp3";
const String _succesSound = "sound/success.mp3";

class _HandGamePageState extends State<HandGamePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late List<Map<String, dynamic>> _handGameItems;

  @override
  void initState() {
    super.initState();
    _handGameItems = [
      {
        "box_image": "assets/game/hand_game/box_1.png",
        "hand_game": "assets/game/hand_game/hand_1.png",
        "isOpen": false,
      },
      {
        "box_image": "assets/game/hand_game/box_2.png",
        "hand_game": "assets/game/hand_game/hand_2.png",
        "isOpen": false,
      },
      {
        "box_image": "assets/game/hand_game/box_3.png",
        "hand_game": "assets/game/hand_game/face_1.png",
        "isOpen": false,
      },
      {
        "box_image": "assets/game/hand_game/box_4.png",
        "hand_game": "assets/game/hand_game/lib_3.png",
        "isOpen": false,
      },
    ];
    initPage();
  }

  void _gameEnd() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameSuccessDialog(
          earnedScore: 10,
          onContinue: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> initPage() async {
    await _playAudioAndWait(_startVoice);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _playAudioAndWait(String path) async {
    final completer = Completer<void>();
    StreamSubscription<void>? subscription;

    String cleanPath = path.replaceFirst('assets/', '');

    subscription = _audioPlayer.onPlayerComplete.listen((_) {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete();
    });

    await _audioPlayer.play(AssetSource(cleanPath));
    return completer.future;
  }

  // Bosilganda ishlaydigan funksiya
  void _onItemTap(int index) async {
    final item = _handGameItems[index];

    // Agar allaqachon ochilgan bo'lsa, hech narsa qilmaymiz
    if (item["isOpen"] == true) return;

    setState(() {
      item["isOpen"] = true;
    });

    // Muvaffaqiyat ovozini chalish
    String cleanSuccessPath = _succesSound.replaceFirst('assets/', '');
    await _audioPlayer.play(AssetSource(cleanSuccessPath));

    // Hammasi ochildimi tekshiramiz
    bool isAllOpen = _handGameItems.every((e) => e["isOpen"] == true);

    if (isAllOpen) {
      // 2 soniya kutamiz
      await Future.delayed(const Duration(seconds: 2));

      // Sahifadan chiqib ketmaganimizga ishonch hosil qilamiz
      if (mounted) {
        _gameEnd();
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Xotirani tozalash
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backround/fon_q.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 10.h),
                  _buildHeader(),
                ],
              ),
              Center(
                child: SizedBox(
                  width: 300.h,
                  height: 300.h,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    // O'z-o'zidan scroll bo'lib ketmasligi uchun
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                    ),
                    itemCount: _handGameItems.length,
                    itemBuilder: (context, index) {
                      final item = _handGameItems[index];

                      return GestureDetector(
                        onTap: () => _onItemTap(index),
                        child: Container(
                          width: 120.h,
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: item["isOpen"] ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          // Animatsiya uchun AnimatedSwitcher
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (Widget child,
                                Animation<double> animation) {
                              // Chiroyli kattalashish va paydo bo'lish animatsiyasi
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Image.asset(
                              item["isOpen"]
                                  ? item["hand_game"]!
                                  : item["box_image"]!,
                              // Key berish majburiy, aks holda Flutter rasm o'zgarganini sezmaydi
                              key: ValueKey<bool>(item["isOpen"]),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.h),
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
              CustomTextWidget(text: "10", sizeText: 32.sp),
            ],
          ),
        ],
      ),
    );
  }
}