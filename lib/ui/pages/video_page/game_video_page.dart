import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/animated_start_button.dart';
import 'package:logosmart/ui/pages/video_page/widgets/game_video_box.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../games/alphabet_map/provider/level_provider.dart';
import '../main/widgets/custom_text_widget.dart';

class GameVideoPage extends StatefulWidget {
  const GameVideoPage({super.key});

  @override
  State<GameVideoPage> createState() => _GameVideoPageState();
}

const String _starIcon = "assets/icons/star.png";

class _GameVideoPageState extends State<GameVideoPage>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

  // Tarmoqdan keladigan video URL manzili
  String _videoUrl = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Provider orqali kelayotgan video URL ni aniqlash
    final provider = context.read<LevelProvider>();
    final currentLevelData = provider.currentLevelData;

    if (currentLevelData != null &&
        currentLevelData.exercise?.mediaPath != null) {
      _videoUrl = currentLevelData.exercise!.mediaPath!;
    }

    if (_videoUrl.isNotEmpty) {
      _initializeVideo();
    } else {
      setState(() => _isVideoError = true);
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(_videoUrl)
        ..setLooping(true)
        ..setVolume(1.0);

      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoError = false;
        });
        _videoController!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVideoError = true);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _videoController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoController?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        _videoController?.pause();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Orqa fon
            Positioned.fill(
              child: Image.asset(
                'assets/backround/fon_q.png',
                fit: BoxFit.fill,
              ),
            ),

            // Yuqori panel (Qaytish tugmasi va yulduzcha)
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: GestureDetector(
                        onTap: () {
                          context.read<LevelProvider>().clearCurrentLevel();
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          "assets/icons/arrow_right_button.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(_starIcon, width: 32.w, height: 32.h),
                        SizedBox(width: 8.w),
                        Consumer<LevelProvider>(
                          builder: (context, provider, child) {
                            return CustomTextWidget(
                              text: provider.ball.toString(),
                              sizeText: 32.sp,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Video qismi
            Column(
              children: [
                SizedBox(height: 160.h, width: size.width),
                GameVideoBox(
                  size: size,
                  isVideoInitialized: _isVideoInitialized,
                  isVideoError: _isVideoError,
                  currentVideoPath: _videoUrl,
                  // URL manzil berilmoqda
                  videoController: _videoController,
                  onRetry: _initializeVideo,
                ),
                SizedBox(height: 40.h),

                // Davom etish tugmasi (Darajani yakunlash)
                AnimatedStartButton(
                  text: "Davom etish",
                  onTap: () async {
                    final provider = context.read<LevelProvider>();

                    // 1. Videoni to'xtatamiz
                    _videoController?.pause();

                    // 2. Darajani tugatilgan deb belgilaymiz (3 yulduz bilan), dialogsiz va ballsiz
                    await provider.unlock(stars: 3);

                    if (context.mounted) {
                      // 3. Joriy daraja ma'lumotlarini tozalaymiz va xaritaga qaytamiz
                      provider.clearCurrentLevel();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
