import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../alphabet_map/widgets/cloud_text.dart';
import '../widgets/game_success_dialog.dart';

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
  bool _showContent = false;
  bool _isPlayingAudio = false;
  final Set<int> _listenedOptions = {};
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initLevelConfig();
    _initGame();
  }

  void _initLevelConfig() {
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    Map<String, dynamic> defaultConfig = {
      "start_voice": "assets/sound/wolf_game/wolf_start.mp3",
      "background_image": "assets/backround/wolf_game/wolf.jpg",
      "icon_star": "assets/icons/star.png",
      "icon_arrow": "assets/icons/arrow_right_button.png",
      "wolf_image": "assets/game/wolf_game/wolf.png",
      "music_icon": "assets/game/wolf_game/music.png",
      "cloud_text": "Uyni topishga yordam bering!",
      "options": [
        {
          "image": "assets/game/wolf_game/cave.png",
          "sound": "assets/sound/wolf_game/RA.mp3",
          "isCorrect": true,
        },
        {
          "image": "assets/game/wolf_game/bird_house.png",
          "sound": "assets/sound/wolf_game/LA.mp3",
          "isCorrect": false,
        },
        {
          "image": "assets/game/wolf_game/dog_house.png",
          "sound": "assets/sound/wolf_game/SA.mp3",
          "isCorrect": false,
        },
        {
          "image": "assets/game/wolf_game/department.png",
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
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleOptionTap(int index) async {
    if (_isGameOver || !_showContent || _isPlayingAudio) return;

    final option = _options[index];

    if (!_listenedOptions.contains(index)) {
      // BIRINCHI BOSISH: Ovozni chiqarish
      final soundPath = option['sound'] ?? '';
      if (soundPath.toString().isNotEmpty) {
        await _playAudioAndWait(soundPath.toString());
      }
      if (mounted) {
        setState(() {
          _listenedOptions.add(index);
        });
      }
    } else {
      // IKKINCHI BOSISH: Tanlash (Javobni tekshirish)
      if (option['isCorrect'] == true) {
        setState(() {
          _isGameOver = true;
        });
        _gameEnd();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Bu emas, boshqasini sinab ko'ring!",
              style: TextStyle(fontSize: 16.sp),
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_config['background_image'] ?? "assets/backround/wolf_game/wolf.jpg"),
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
                        _config['wolf_image'] ?? "assets/game/wolf_game/wolf.png",
                        height: 170.h,
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
                            return _buildPetScene(
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

  Widget _buildPetScene({
    required String image,
    required int index,
    required bool isUnlocked,
  }) {
    final double houseWidth = 90.w;
    final double houseHeight = 90.h;
    final double speakerSize = 45.w;

    return GestureDetector(
      onTap: () => _handleOptionTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
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
              scale: isUnlocked ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                image,
                width: houseWidth,
                height: houseHeight,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: -10.h,
              right: 10.w,
              child: AnimatedOpacity(
                opacity: isUnlocked ? 0.3 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  _config['music_icon'] ?? "assets/game/wolf_game/music.png",
                  width: speakerSize,
                  height: speakerSize,
                ),
              ),
            ),
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
