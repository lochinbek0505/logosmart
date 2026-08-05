import 'dart:convert'; // JSON o'qish uchun

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class DragDropGamePage extends StatefulWidget {
  const DragDropGamePage({Key? key}) : super(key: key);

  @override
  State<DragDropGamePage> createState() => _DragDropGamePageState();
}

class _DragDropGamePageState extends State<DragDropGamePage> {
  // JSON dan olinadigan sozlamalar
  late Map<String, dynamic> _config;

  late List<Map<String, dynamic>> _items;
  late List<Map<String, dynamic>> _shadowItems;

  final Map<String, bool> _matchedResults = {};

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    // 1. Joriy levelni Providerdan o'qib JSON ni parse qilamiz
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);

      // JSON ichidagi elementlarni listga olamiz
      List dynamicItems = _config['items'] ?? [];
      _items = List<Map<String, dynamic>>.from(dynamicItems);
    } else {
      // Fallback xavfsizlik
      _config = {
        "bg_color": "0xFFF4F6F9",
        "success_sound": "assets/sound/success.mp3",
        "icon_star": "assets/icons/star.png",
        "avatar_bg": "assets/icons/circle.png",
        "avatar_image": "assets/icons/circle_bad.png",
      };
      _items = [
        {"id": "pepper", "image": "assets/game/yellow_pepper.png"},
        {"id": "tomato", "image": "assets/game/tomato.png"},
        {"id": "eggplant", "image": "assets/game/eggplant.png"},
        {"id": "cucumber", "image": "assets/game/cucumber.png"},
      ];
    }

    _shadowItems = List.from(_items);
    _shadowItems.shuffle(); // Soyalar o'rni har safar almashib turishi uchun
  }

  // AudioPathdagi assets/ so'zini tozalash funksiyasi
  String _cleanAudioPath(String path) {
    if (path.startsWith('assets/')) {
      return path.replaceFirst('assets/', '');
    }
    return path;
  }

  void _checkGameEnd() {
    if (_matchedResults.length == _items.length) {
      // O'yin muvaffaqiyatli tugadi
      final provider = context.read<LevelProvider>();
      provider.addBall(10); // Yakuniy bonus
      provider.unlock(stars: 3);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GameSuccessDialog(
            earnedScore: 10,
            onContinue: () {
              provider.clearCurrentLevel();
              Navigator.pop(context); // Dialogni yopish
              Navigator.pop(context); // Xaritaga qaytish
            },
          );
        },
      );
    }
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

    // JSON dan fon rangini olish
    final bgColor = Color(int.parse(_config['bg_color'] ?? "0xFFF4F6F9"));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),

            // --- TEPADAGI HEADER ---
            _buildHeader(totalBall),

            SizedBox(height: 30.h),

            // --- ASOSIY O'YIN MAYDONI (Drag va Drop) ---
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chap ustun: Rangli elementlar (Draggable)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _items.map((item) {
                        if (_matchedResults[item['id']] == true) {
                          return SizedBox(height: 100.h, width: 90.w);
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Draggable<Map<String, dynamic>>(
                            data: item,
                            feedback: Image.asset(item['image'], width: 85.w, height: 85.h),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: Image.asset(item['image'], width: 85.w, height: 85.h),
                            ),
                            child: Image.asset(item['image'], width: 85.w, height: 85.h),
                          ),
                        );
                      }).toList(),
                    ),

                    // O'ng ustun: Soyalar (DragTarget)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _shadowItems.map((shadowItem) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: DragTarget<Map<String, dynamic>>(
                            onAcceptWithDetails: (details) async {
                              if (details.data['id'] == shadowItem['id']) {
                                // To'g'ri topildi
                                await _audioPlayer.play(AssetSource(_cleanAudioPath(_config['success_sound'])));

                                context.read<LevelProvider>().addBall(10); // Har bir to'g'ri element uchun ball

                                setState(() {
                                  _matchedResults[shadowItem['id']] = true;
                                });

                                _showSnackbar("To'g'ri topdingiz!", Colors.green);
                                _checkGameEnd();
                              } else {
                                // Xato
                                _showSnackbar("Xato, qayta urinib ko'ring!", Colors.red);
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              if (_matchedResults[shadowItem['id']] == true) {
                                return Image.asset(shadowItem['image'], width: 85.w, height: 85.h);
                              }

                              return ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF555555),
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(shadowItem['image'], width: 85.w, height: 85.h),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // --- PAZUA/ORQAGA TUGMASI ---
            Center(
              child: Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00B0FF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      spreadRadius: 2.w,
                      blurRadius: 6.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.pause_rounded, color: Colors.white, size: 36.w),
                  onPressed: () {
                    // Xaritaga qaytarib yuboramiz
                    context.read<LevelProvider>().clearCurrentLevel();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader(int currentBall) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 40.w,
                color: const Color(0xffFFC754),
              ),
              SizedBox(width: 8.w),
              CustomTextWidget(text: "$currentBall", sizeText: 32.sp),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8.5,
              bottom: 11.5,
            ),
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_config['avatar_bg']), // JSON
                fit: BoxFit.fill,
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(_config['avatar_image']), // JSON
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}