import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class SoundGamePage extends StatefulWidget {
  const SoundGamePage({super.key});

  @override
  State<SoundGamePage> createState() => _SoundGamePageState();
}

class _SoundGamePageState extends State<SoundGamePage> {
  late Map<String, dynamic> _config;
  late List<Map<String, dynamic>> _targetWord;
  late List<Map<String, dynamic>> _options;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlayingAudio = false;
  bool _showErrorAnim = false;
  bool _isGameFinished = false;

  @override
  void initState() {
    super.initState();
    _initLevelConfig();
    _initPage();
  }

  void _initLevelConfig() {
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    // Yagona JSON config
    Map<String, dynamic> defaultConfig = {
      "start_voice": "assets/sound/sound_game/raketa_start.mp3",
      "success_sound": "assets/sound/success.mp3",
      "incorrect_sound": "assets/sound/diagnostic_error.mp3",
      "main_image": "assets/game/sound_game/raketa.png",
      "background_image": "assets/backround/sound_game/rocket_bg.jpg",
      "icon_star": "assets/icons/star.png",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "target_word": [
        {"text": "", "sound": "", "correct": "RA"},
        {"text": "KE", "sound": "assets/sound/sound_game/ke.mp3", "correct": ""},
        {"text": "TA", "sound": "assets/sound/sound_game/ta.mp3", "correct": ""}
      ],
      "options": [
        {"text": "YA", "sound": "assets/sound/sound_game/ya.mp3"},
        {"text": "RA", "sound": "assets/sound/sound_game/ra.mp3"},
        {"text": "LA", "sound": "assets/sound/sound_game/la.mp3"}
      ]
    };

    if (currentLevel != null && currentLevel.game != null) {
      try {
        _config = jsonDecode(currentLevel.game!.jsonConfig);
      } catch (e) {
        _config = defaultConfig; // Xato bo'lsa defaultni ishlatish
      }
    } else {
      _config = defaultConfig;
    }

    _targetWord = List<Map<String, dynamic>>.from(_config['target_word']);
    _options = List<Map<String, dynamic>>.from(_config['options']);
  }

  Future<void> _initPage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (_config['start_voice'] != null) {
      await _playAudioAndWait(_config['start_voice']);
    }
  }

  String _cleanAudioPath(String path) {
    if (path.startsWith('assets/')) {
      return path.replaceFirst('assets/', '');
    }
    return path;
  }

  Future<void> _playAudioAndWait(String path) async {
    if (path.isEmpty || _isPlayingAudio) return;

    setState(() => _isPlayingAudio = true);

    final completer = Completer<void>();
    StreamSubscription<void>? subscription;

    String cleanPath = _cleanAudioPath(path);

    subscription = _audioPlayer.onPlayerComplete.listen((_) {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await _audioPlayer.play(AssetSource(cleanPath));
      await completer.future;
    } catch (e) {
      debugPrint("Audio xatosi: $e");
    } finally {
      if (mounted) setState(() => _isPlayingAudio = false);
    }
  }

  // Noto'g'ri joylanganda xatolik
  Future<void> _handleWrongDrop() async {
    if (mounted) {
      setState(() {
        _showErrorAnim = true;
      });
    }

    await _playAudioAndWait(_config['incorrect_sound']);

    if (mounted) {
      setState(() {
        _showErrorAnim = false;
      });
    }
  }

  // To'g'ri joylanganda o'yinni tugatish
  Future<void> _handleCorrectDrop(int index, Map<String, dynamic> data) async {
    setState(() {
      _targetWord[index]["text"] = data["text"];
      _targetWord[index]["sound"] = data["sound"];
      _isGameFinished = true;
    });

    await _playAudioAndWait(_config['success_sound']);
    _gameEnd();
  }

  void _gameEnd() {
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
            provider.clearCurrentLevel();
            Navigator.pop(context);
            Navigator.pop(context);
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
    final totalBall = context.watch<LevelProvider>().ball;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_config['background_image']),
                fit: BoxFit.cover,
              ),
            ),
            child: AbsorbPointer(
              absorbing: _isPlayingAudio || _showErrorAnim || _isGameFinished,
              child: Column(
                children: [
                  SizedBox(height: 50.h),
                  _buildHeader(totalBall),
                  SizedBox(height: 30.h),

                  // Asosiy Rasm
                  Image.asset(
                    _config['main_image'],
                    width: 200.w,
                    height: 200.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 50.h),

                  // Tepasidagi maqsad qilingan bo'g'inlar (Target slots)
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    alignment: WrapAlignment.center,
                    children: List.generate(_targetWord.length, (index) {
                      return _buildTargetSlot(_targetWord[index], index);
                    }),
                  ),

                  SizedBox(height: 100.h),

                  // Pastdagi tanlov bo'g'inlari (Draggable options)
                  if (!_isGameFinished)
                    Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      alignment: WrapAlignment.center,
                      children: _options.map((option) => _buildDraggableOption(option)).toList(),
                    ),
                ],
              ),
            ),
          ),

          // Xatolik animatsiyasi (Xato ustiga olib borsa)
          if (_showErrorAnim)
            Container(
              color: Colors.black26,
              child: Center(
                child: Lottie.asset(
                  "assets/animation/xato.json",
                  width: 200.w,
                  height: 200.h,
                  repeat: false,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTargetSlot(Map<String, dynamic> item, int index) {
    bool isEmpty = item["text"] == "";

    if (!isEmpty) {
      // Katak to'la bo'lsa (yoki to'g'ri topilgandan so'ng) shunchaki bossa ovoz chiqadi
      return GestureDetector(
        onTap: () => _playAudioAndWait(item["sound"]),
        child: Container(
          width: 90.w,
          height: 75.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.main_blue_600, width: 3.h),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              item["text"],
              style: GoogleFonts.nunito(
                fontSize: 30.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.grey_900,
              ),
            ),
          ),
        ),
      );
    } else {
      // Katak bo'sh bo'lsa (DragTarget)
      return DragTarget<Map<String, dynamic>>(
        onWillAccept: (data) => true,
        onAccept: (data) {
          if (data["text"] == item["correct"]) {
            _handleCorrectDrop(index, data);
          } else {
            _handleWrongDrop();
          }
        },
        builder: (context, candidateData, rejectedData) {
          bool isHovered = candidateData.isNotEmpty;

          return Container(
            width: 90.w,
            height: 75.h,
            decoration: BoxDecoration(
              color: isHovered ? Colors.green.withOpacity(0.3) : Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isHovered ? Colors.green : Colors.white70,
                width: 3.h,
                style: BorderStyle.solid,
              ),
            ),
            child: isHovered
                ? Center(
              child: Icon(Icons.check_circle_outline, color: Colors.green, size: 36.sp),
            )
                : const SizedBox(),
          );
        },
      );
    }
  }

  Widget _buildDraggableOption(Map<String, dynamic> item) {
    Widget childWidget = Container(
      width: 90.w,
      height: 75.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.main_blue_400, AppColors.main_blue_600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.main_blue_600.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          item["text"],
          style: GoogleFonts.nunito(
            fontSize: 30.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: () => _playAudioAndWait(item["sound"]),
      child: Draggable<Map<String, dynamic>>(
        data: item,
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.9,
            child: Transform.scale(
              scale: 1.1,
              child: childWidget,
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: childWidget),
        child: childWidget,
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
              CustomTextWidget(
                  text: currentBall.toString(),
                  sizeText: 32.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}