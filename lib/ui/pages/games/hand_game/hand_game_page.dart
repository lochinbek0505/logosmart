import 'dart:async';
import 'dart:convert'; // JSON o'qish uchun

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class HandGamePage extends StatefulWidget {
  const HandGamePage({super.key});

  @override
  State<HandGamePage> createState() => _HandGamePageState();
}

class _HandGamePageState extends State<HandGamePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // JSON dan keladigan sozlamalar
  late Map<String, dynamic> _config;
  late List<Map<String, dynamic>> _handGameItems;

  @override
  void initState() {
    super.initState();
    _initLevelConfig();
    _initPage();
  }

  void _initLevelConfig() {
    // 1. Joriy levelni Providerdan o'qib JSON ni parse qilamiz
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);

      // JSON ichidagi elementlarni listga olamiz va "isOpen" xususiyatini qo'shamiz
      List dynamicItems = _config['items'] ?? [];
      _handGameItems = dynamicItems.map((item) {
        return {
          "box_image": item["box_image"],
          "hand_image": item["hand_image"],
          "isOpen": false,
        };
      }).toList();
    } else {
      // Fallback
      _config = {
        "start_voice": "assets/sound/hand_game/hand_game_start.mp3",
        "success_sound": "assets/sound/success.mp3",
        "background_image": "assets/backround/fon_q.png",
        "icon_star": "assets/icons/star.png",
        "icon_arrow": "assets/icons/arrow_right_button.png",
      };
      _handGameItems = [
        {"box_image": "assets/game/hand_game/box_1.png", "hand_image": "assets/game/hand_game/hand_1.png", "isOpen": false},
        {"box_image": "assets/game/hand_game/box_2.png", "hand_image": "assets/game/hand_game/hand_2.png", "isOpen": false},
        {"box_image": "assets/game/hand_game/box_3.png", "hand_image": "assets/game/hand_game/face_1.png", "isOpen": false},
        {"box_image": "assets/game/hand_game/box_4.png", "hand_image": "assets/game/hand_game/lib_3.png", "isOpen": false},
      ];
    }
  }

  String _cleanAudioPath(String path) {
    if (path.startsWith('assets/')) {
      return path.replaceFirst('assets/', '');
    }
    return path;
  }

  Future<void> _initPage() async {
    if (_config['start_voice'] != null) {
      await _playAudioAndWait(_config['start_voice']);
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _playAudioAndWait(String path) async {
    final completer = Completer<void>();
    StreamSubscription<void>? subscription;

    String cleanPath = _cleanAudioPath(path);

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
    await _audioPlayer.play(AssetSource(_cleanAudioPath(_config['success_sound'])));

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

  void _gameEnd() {
    // PROVIDER ORQALI BALL QO'SHISH VA LEVEL OCHISH
    final provider = context.read<LevelProvider>();
    provider.addBall(10);
    provider.unlock(stars: 3);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameSuccessDialog(
          earnedScore: 10,
          onContinue: () {
            provider.clearCurrentLevel(); // Xotirani tozalaymiz
            Navigator.pop(context);
            Navigator.pop(context); // Xaritaga qaytish
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UMUMIY BALLNI PROVIDERDAN OLAMIZ
    final totalBall = context.watch<LevelProvider>().ball;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_config['background_image']), // JSON
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
                  _buildHeader(totalBall),
                ],
              ),
              Center(
                child: SizedBox(
                  width: 300.h,
                  height: 300.h,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) {
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
                                  ? item["hand_image"]! // JSON (box ichidagi rasm)
                                  : item["box_image"]!, // JSON (quti)
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
            child: Image.asset(
              _config['icon_arrow'], // JSON
              width: 48.w,
              height: 48.h,
              fit: BoxFit.fill,
            ),
          ),
          Row(
            children: [
              Image.asset(_config['icon_star'], width: 32.w, height: 32.h), // JSON
              SizedBox(width: 8.w),
              CustomTextWidget(text: currentBall.toString(), sizeText: 32.sp),
            ],
          ),
        ],
      ),
    );
  }
}