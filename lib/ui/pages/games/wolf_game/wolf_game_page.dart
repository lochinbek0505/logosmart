import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../alphabet_map/widgets/cloud_text.dart';
import '../widgets/game_success_dialog.dart';

/// Mikrofonsiz "to'g'ri bo'g'inni topish" o'yini.
///
/// Bitta shablon bir nechta level uchun ishlatiladi (bo'ri-uy, olmaxon-yong'oq…):
/// birinchi bosishda variant ovozi eshittiriladi, ikkinchi bosishda tanlanadi.
/// Musiqa belgisini bosib ovozni qayta eshitish mumkin.
class WolfGamePage extends StatefulWidget {
  const WolfGamePage({super.key});

  @override
  State<WolfGamePage> createState() => _WolfGamePageState();
}

class _WolfGamePageState extends State<WolfGamePage>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _config;
  late List<Map<String, dynamic>> _options;

  late AudioPlayer _audioPlayer;
  // Natija ovozlari (to'g'ri/xato) asosiy ovozni kutmasdan chalinadi
  late AudioPlayer _effectPlayer;
  Completer<void>? _audioCompleter;

  late AnimationController _shakeController;

  bool _showContent = false;
  bool _isPlayingAudio = false;
  final Set<int> _listenedOptions = {};
  int? _wrongIndex;
  int? _correctIndex;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _effectPlayer = AudioPlayer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _initLevelConfig();
    _initGame();
  }

  void _initLevelConfig() {
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    Map<String, dynamic> defaultConfig = {
      "start_voice": "assets/sound/wolf_game/wolf_start.mp3",
      "success_sound": "assets/sound/success.mp3",
      "incorrect_sound": "assets/sound/diagnostic_error.mp3",
      "background_image": "assets/backround/wolf_game/wolf.webp",
      "icon_star": "assets/icons/star.webp",
      "icon_arrow": "assets/icons/arrow_right_button.webp",
      "character_image": "assets/game/wolf_game/wolf.webp",
      "music_icon": "assets/game/wolf_game/music.webp",
      "cloud_text": "Uyni topishga yordam bering!",
      "options": [
        {
          "image": "assets/game/wolf_game/cave.webp",
          "sound": "assets/sound/wolf_game/RA.mp3",
          "isCorrect": true,
        },
        {
          "image": "assets/game/wolf_game/bird_house.webp",
          "sound": "assets/sound/wolf_game/LA.mp3",
          "isCorrect": false,
        },
        {
          "image": "assets/game/wolf_game/dog_house.webp",
          "sound": "assets/sound/wolf_game/SA.mp3",
          "isCorrect": false,
        },
        {
          "image": "assets/game/wolf_game/department.webp",
          "sound": "assets/sound/wolf_game/YA.mp3",
          "isCorrect": false,
        },
      ]
    };

    if (currentLevel != null && currentLevel.game != null) {
      try {
        _config = jsonDecode(currentLevel.game!.jsonConfig);
      } catch (e) {
        _config = defaultConfig;
      }
    } else {
      _config = defaultConfig;
    }

    _options = List<Map<String, dynamic>>.from(_config['options'] ?? []);
    // To'g'ri javob har doim bir joyda turmasligi uchun
    if (_config['shuffle_options'] != false) {
      _options.shuffle(Random());
    }
  }

  // Eski levellar "wolf_image" kalitidan foydalanadi
  String get _characterImage =>
      (_config['character_image'] ??
              _config['wolf_image'] ??
              "assets/game/wolf_game/wolf.webp")
          .toString();

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
    _audioCompleter = completer;
    final subscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await _audioPlayer.play(AssetSource(_cleanAudioPath(path)));
      // Ovoz tugash hodisasi kelmasa ham o'yin qotib qolmasin
      await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {},
      );
    } catch (e) {
      debugPrint("Audio xatosi: $e");
    } finally {
      await subscription.cancel();
      _audioCompleter = null;
      if (mounted) setState(() => _isPlayingAudio = false);
    }
  }

  void _playEffect(String? path) {
    if (path == null || path.isEmpty) return;
    _effectPlayer.play(AssetSource(_cleanAudioPath(path))).catchError((e) {
      debugPrint("Effekt ovozi xatosi: $e");
    });
  }

  Future<void> _initGame() async {
    final startVoice = _config['start_voice'];
    if (startVoice != null && startVoice.toString().isNotEmpty) {
      await _playAudioAndWait(startVoice.toString());
    }

    if (mounted) {
      setState(() {
        _showContent = true;
      });
    }
  }

  @override
  void dispose() {
    final completer = _audioCompleter;
    if (completer != null && !completer.isCompleted) completer.complete();
    _shakeController.dispose();
    _audioPlayer.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }

  Future<void> _playOptionSound(int index) async {
    final soundPath = (_options[index]['sound'] ?? '').toString();
    if (soundPath.isNotEmpty) {
      await _playAudioAndWait(soundPath);
    }
    if (mounted) {
      setState(() => _listenedOptions.add(index));
    }
  }

  void _handleOptionTap(int index) async {
    if (_isGameOver || !_showContent || _isPlayingAudio) return;

    if (!_listenedOptions.contains(index)) {
      // BIRINCHI BOSISH: Ovozni chiqarish
      await _playOptionSound(index);
      return;
    }

    // IKKINCHI BOSISH: Tanlash (Javobni tekshirish)
    if (_options[index]['isCorrect'] == true) {
      setState(() {
        _isGameOver = true;
        _correctIndex = index;
        _wrongIndex = null;
      });
      _playEffect(_config['success_sound']?.toString());
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) _gameEnd();
    } else {
      setState(() => _wrongIndex = index);
      _playEffect(_config['incorrect_sound']?.toString());
      await _shakeController.forward(from: 0);
      if (mounted && _wrongIndex == index) {
        setState(() => _wrongIndex = null);
      }
    }
  }

  void _handleMusicTap(int index) {
    if (_isGameOver || !_showContent || _isPlayingAudio) return;
    _playOptionSound(index);
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
  Widget build(BuildContext context) {
    final totalBall = context.watch<LevelProvider>().ball;
    final characterCacheHeight =
        (170.h * MediaQuery.devicePixelRatioOf(context)).round();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_config['background_image'] ?? "assets/backround/wolf_game/wolf.webp"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildHeader(totalBall),
              SizedBox(height: 30.h),

              Expanded(
                child: AnimatedOpacity(
                  opacity: _showContent ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Column(
                    children: [
                      CloudText(
                        text: _config['cloud_text'] ?? "Uyni topishga yordam bering!",
                        fontSize: 19.sp,
                        width: 270.w,
                        height: 170.h,
                      ),
                      Image.asset(
                        _characterImage,
                        height: 170.h,
                        cacheHeight: characterCacheHeight,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 40.h),
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 50.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20.w,
                            mainAxisSpacing: 20.h,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            return _buildOption(
                              image: _options[index]["image"],
                              index: index,
                              isUnlocked: _listenedOptions.contains(index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required String image,
    required int index,
    required bool isUnlocked,
  }) {
    final double imageWidth = 90.w;
    final double imageHeight = 90.h;
    final double speakerSize = 45.w;
    final bool isWrong = _wrongIndex == index;
    final bool isCorrect = _correctIndex == index;

    Color? glowColor;
    if (isCorrect) {
      glowColor = Colors.greenAccent;
    } else if (isWrong) {
      glowColor = Colors.redAccent;
    } else if (isUnlocked) {
      glowColor = Colors.amber;
    }

    Widget content = GestureDetector(
      onTap: () => _handleOptionTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale: isCorrect ? 1.25 : (isUnlocked ? 1.1 : 1.0),
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                image,
                width: imageWidth,
                height: imageHeight,
                cacheWidth:
                    (imageWidth * MediaQuery.devicePixelRatioOf(context)).round(),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: -10.h,
              right: 10.w,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleMusicTap(index),
                child: AnimatedOpacity(
                  opacity: isUnlocked ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(
                    _config['music_icon'] ?? "assets/game/wolf_game/music.webp",
                    width: speakerSize,
                    height: speakerSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isWrong) return content;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = sin(_shakeController.value * pi * 6) * 10.w;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: content,
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
