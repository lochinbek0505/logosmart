import 'dart:async';
import 'dart:convert'; // JSON parse uchun

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// O'zingizdagi yo'llarni to'g'irlab olasiz
import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class BreathPage extends StatefulWidget {
  const BreathPage({super.key});

  @override
  State<BreathPage> createState() => _BreathPageState();
}

class _BreathPageState extends State<BreathPage> with TickerProviderStateMixin {
  // JSON dan keladigan sozlamalar
  late Map<String, dynamic> _config;

  // Lottie va Audio
  late final AnimationController _lottieController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Mikrofon animatsiyasi uchun controllerlar
  late final AnimationController _pulse;
  late final AnimationController _bounce;
  late final Animation<double> _scale;
  late final Animation<double> _bounceAnim;
  late final Animation<Color?> _colorAnim;
  DateTime? _blowStartTime;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSub;
  StreamSubscription<void>? _audioCompleteSub;

  // Ovoz va animatsiya holatlari
  bool _isMicReady = false;
  bool _isAskingGirl = false;
  bool _hasBlown = false;
  bool _isRecording = false;

  // Vizualizator uchun o'zgaruvchilar
  List<double> heights = [10.0, 18.0, 26.0, 36.0, 26.0, 18.0, 10.0];
  int activeBars = 0;
  int _breathCount = 0;

  // Puflash sezgirligi (Detsibel)
  static const double _thresholdDb = 75.0;

  @override
  void initState() {
    super.initState();

    // 1. Joriy level ob'ektini Providerdan olish va JSON ni parse qilish
    final currentLevel = context.read<LevelProvider>().currentLevelData;
    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);
    } else {
      // Xavfsizlik uchun default qiymatlar (kutilmagan xato bo'lsa)
      _config = {
        "start_voice": "assets/sound/breath/breath_start.mp3",
        "blow_voice": "assets/sound/breath/butterfly.mp3",
        "lottie_animation": "assets/animation/breath/butterfly.json",
        "background_image": "assets/backround/breath/butterfly_background.jpg",
        "icon_star": "assets/icons/star.png",
        "icon_arrow": "assets/icons/arrow_right_button.png",
      };
    }

    // 2. Lottie Controller
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener(_onAnimationStatus);

    // 3. Mikrofon Animatsiyalari Controllerlari
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _bounceAnim = Tween<double>(begin: -5.0, end: 5.0).animate(
        CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));

    _colorAnim = ColorTween(begin: Colors.green, end: Colors.lightGreenAccent)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    // Sahifani initsializatsiya qilish
    _initPage();
  }

  // AudioPlayer AssetSource uchun "assets/" so'zini olib tashlash kerak bo'lishi mumkin
  String _cleanAudioPath(String path) {
    if (path.startsWith('assets/')) {
      return path.replaceFirst('assets/', '');
    }
    return path;
  }

  Future<void> _initPage() async {
    _audioCompleteSub = _audioPlayer.onPlayerComplete.listen((_) async {
      _audioCompleteSub?.cancel();

      await Future.delayed(const Duration(seconds: 1));

      final micOk = await _ensureMicPermission();
      if (micOk && mounted) {
        setState(() {
          _isMicReady = true;
        });

        _pulse.repeat(reverse: true);
        _bounce.repeat(reverse: true);

        _startListening();
      }
    });

    // Boshlang'ich ovozni JSON dan olib ishga tushirish
    await _audioPlayer.play(AssetSource(_cleanAudioPath(_config['start_voice'])));
  }

  void _startListening() {
    _noiseMeter ??= NoiseMeter();
    _noiseSub = _noiseMeter!.noise.listen(_onNoise);
  }

  void _onAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      if (_breathCount == 3) {
        _gameEnd();
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _hasBlown = false;
          });
        }
      });
    }
  }

  void _gameEnd() async {
    print("Game end");

    // ==========================================
    // PROVIDER ORQALI BALL QO'SHISH VA LEVEL OCHISH
    // ==========================================
    final provider = context.read<LevelProvider>();
    provider.addBall(10); // 10 ball qo'shish
    provider.unlock(stars: 3); // 3 yulduz bilan keyingi levelni ochish

    // Muvaffaqiyatli ovozni chalish
    await _audioPlayer.play(AssetSource('sound/success.mp3'));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameSuccessDialog(
          earnedScore: 10,
          onContinue: () {
            provider.clearCurrentLevel(); // Level state'ni tozalash
            Navigator.pop(context); // Dialogni yopish
            Navigator.pop(context); // O'yin sahifasidan chiqish
          },
        );
      },
    );
  }

  void _onNoise(NoiseReading reading) {
    if (!mounted || _breathCount >= 3) return;

    final db = reading.meanDecibel;
    int calculatedBars = ((db - 30) / 10).clamp(0, heights.length).toInt();

    if (db > _thresholdDb) {
      _blowStartTime ??= DateTime.now();
      final blowDuration = DateTime.now().difference(_blowStartTime!);

      setState(() {
        activeBars = calculatedBars;
        _isRecording = true;
      });

      if (blowDuration.inMilliseconds > 400) {
        if (!_lottieController.isAnimating && !_hasBlown) {
          _hasBlown = true;

          // JSON dan olingan puflash ovozini chalish
          _audioPlayer.play(AssetSource(_cleanAudioPath(_config['blow_voice'])));
          _lottieController.forward(from: 0.0);
          _breathCount++;
        }
      }
    } else {
      _blowStartTime = null;
      setState(() {
        activeBars = calculatedBars;
        _isRecording = false;
      });
    }
  }

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  void dispose() {
    _audioCompleteSub?.cancel();
    _noiseSub?.cancel();
    _lottieController.dispose();
    _pulse.dispose();
    _bounce.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PROVIDERDAN UMUMIY BALLNI KUZATISH
    final totalBall = context.watch<LevelProvider>().ball;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_config['background_image']), // JSON dan rasm
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50.h),

            // Yuqori qism
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                        _config['icon_arrow'], // JSON dan back knopka
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        _config['icon_star'], // JSON dan yulduzcha
                        width: 40.w,
                        height: 40.h,
                      ),
                      SizedBox(width: 8.w),
                      CustomTextWidget(
                        text: totalBall.toString(), // Provider balli chiziladi
                        sizeText: 32.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Lottie animatsiyasi
            Lottie.asset(
              _config['lottie_animation'], // JSON dan lottie animation
              controller: _lottieController,
              animate: _isMicReady,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
              },
              width: 300.w,
              height: 300.h,
              fit: BoxFit.contain,
            ),

            const Spacer(),

            SizedBox(height: 16.h),

            // Animatsiyali Mikrofon Widgeti
            AnimatedOpacity(
              opacity: (_isMicReady && !_isAskingGirl) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 6.w),
                  GestureDetector(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_pulse, _bounce]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnim.value),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110.w,
                                height: 110.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRecording
                                      ? _colorAnim.value?.withOpacity(0.25)
                                      : Colors.white.withOpacity(0.15),
                                ),
                              ),
                              Container(
                                width: 90.w,
                                height: 90.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRecording
                                      ? _colorAnim.value?.withOpacity(0.35)
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                              ScaleTransition(
                                scale: _scale,
                                child: CircleAvatar(
                                  radius: 40.r,
                                  backgroundImage: const AssetImage(
                                    "assets/icons/circle.png",
                                  ),
                                  child: Image.asset(
                                    "assets/icons/micrafon.png",
                                    width: 26.w,
                                    height: 38.h,
                                    color: _isRecording
                                        ? _colorAnim.value
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}