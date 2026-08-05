import 'dart:async';
import 'dart:convert'; // JSON o'qish uchun

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart'; // Provider

import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class CookingPage extends StatefulWidget {
  const CookingPage({super.key});

  @override
  State<CookingPage> createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage>
    with TickerProviderStateMixin {

  // JSON'dan olinadigan sozlamalar
  late Map<String, dynamic> _config;

  List<Map<String, dynamic>> _products = [];
  String? _eatingItemId;
  bool _isGirlEating = false;
  bool _isDragEnabled = false;

  String? _activeVoiceItemId;
  StreamSubscription<void>? _audioCompleteSubscription;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;

  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnim;
  late Animation<double> _bounceAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _initLevelConfig();
    _initAnimations();
    _initAudioListener();
    _initPage();
  }

  void _initLevelConfig() {
    // 1. Joriy levelni Providerdan o'qib JSON ni parse qilamiz
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);

      // JSON ichidagi mahsulotlarni listga olib olamiz
      List dynamicProducts = _config['products'] ?? [];
      _products = List<Map<String, dynamic>>.from(dynamicProducts);
    } else {
      // Fallback
      _config = {
        "start_voice": "assets/sound/cooking/cooking_start.mp3",
        "success_sound": "assets/sound/success.mp3",
        "bg_image": "assets/backround/cooking/cooking.png",
        "icon_arrow": "assets/icons/arrow_right_button.png",
        "icon_star": "assets/icons/star.png",
        "icon_mic": "assets/icons/micrafon.png",
        "chef_image": "assets/game/cooking/chef_girl.png",
      };
      _products = [];
    }
  }

  void _initAudioListener() {
    _audioCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _activeVoiceItemId = null;
          _isRecording = false;
          _pulseController.stop();
          _bounceController.stop();
        });
      }
    });
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bounceAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _colorAnim = ColorTween(begin: Colors.green, end: Colors.lightGreenAccent)
        .animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
    if (mounted) {
      setState(() {
        _isDragEnabled = true;
      });
    }
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

  void _startFakeRecording() {
    setState(() {
      _isRecording = true;
      _pulseController.repeat(reverse: true);
      _bounceController.repeat(reverse: true);
    });
  }

  Future<void> _processAcceptedItem(Map<String, dynamic> item) async {
    setState(() {
      _activeVoiceItemId = 'success';
      _isRecording = false;
      _pulseController.stop();
      _bounceController.stop();
    });

    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(_cleanAudioPath(_config['success_sound'])));

    setState(() {
      _eatingItemId = item['id'];
      _isGirlEating = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Har safar yeganda Provider orqali 5 ball qo'shamiz
        context.read<LevelProvider>().addBall(5);

        setState(() {
          _products.removeWhere((p) => p['id'] == item['id']);
          _isGirlEating = false;
          _eatingItemId = null;
        });
        _checkGameEnd();
      }
    });
  }

  void _checkGameEnd() {
    if (_products.isEmpty) {
      // O'yin tugadi: Yana yakuniy ball va Levelni qulfdan chiqarish
      final provider = context.read<LevelProvider>();
      provider.addBall(10); // Qo'shimcha 10 ball (yoki xohlaganingizcha)
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
  }

  @override
  void dispose() {
    _audioCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalBall = context.watch<LevelProvider>().ball; // Provider balli

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(_config['bg_image']), // JSON
              fit: BoxFit.fill
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // HEADER (Top-Bar)
              Positioned(
                top: 10.h,
                left: 17.w,
                right: 17.w,
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
                        Image.asset(
                            _config['icon_star'], // JSON
                            width: 32.w,
                            height: 32.h
                        ),
                        const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: CustomTextWidget(
                            key: ValueKey<int>(totalBall),
                            text: '$totalBall', // Providerdan olingan ball
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // SABZAVOTLAR
              ..._products.map((item) {
                final isBeingEaten = _eatingItemId == item['id'];

                // Endi x va y koordinatalari JSON dan olinadi
                final double itemRight = (item['x'] as num).toDouble();
                final double itemBottom = (item['y'] as num).toDouble();

                return AnimatedPositioned(
                  duration: Duration(milliseconds: isBeingEaten ? 500 : 0),
                  bottom: isBeingEaten ? 250.h : itemBottom.h,
                  right: isBeingEaten ? 80.w : itemRight.w,
                  child: AnimatedScale(
                    duration: Duration(milliseconds: isBeingEaten ? 500 : 0),
                    scale: isBeingEaten ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring:
                      !_isDragEnabled ||
                          (_activeVoiceItemId != null &&
                              _activeVoiceItemId != item['id']),
                      child: Draggable<Map<String, dynamic>>(
                        data: item,
                        onDragStarted: () async {
                          if (_activeVoiceItemId == item['id']) {
                            if (!_isRecording) _startFakeRecording();
                            return;
                          }

                          setState(() {
                            _activeVoiceItemId = item['id'];
                          });

                          await _audioPlayer.stop();
                          _audioPlayer.play(
                            AssetSource(_cleanAudioPath(item['sound'])),
                          );
                          _startFakeRecording();
                        },
                        onDragEnd: (details) {
                          if (!details.wasAccepted && _isRecording) {
                            setState(() {
                              _isRecording = false;
                              _pulseController.stop();
                              _bounceController.stop();
                            });
                          }
                        },
                        feedback: Image.asset(
                          item['asset'],
                          width: 80.w,
                          height: 80.h,
                        ),
                        childWhenDragging: const SizedBox.shrink(),
                        child: Image.asset(
                          item['asset'],
                          width: 85.w,
                          height: 85.h,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // OSHPAZ QIZ
              Positioned(
                bottom: 20.h,
                right: 10.w,
                child: DragTarget<Map<String, dynamic>>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    final acceptedItem = details.data;
                    _processAcceptedItem(acceptedItem);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()
                        ..scale(
                          candidateData.isNotEmpty || _isGirlEating
                              ? 1.05
                              : 1.0,
                        ),
                      transformAlignment: Alignment.bottomCenter,
                      child: Image.asset(
                        _config['chef_image'], // JSON
                        width: 180.w,
                        height: 320.h,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),

              // MIC ANIMATION (Pastki qism)
              Positioned(
                bottom: 20.h,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseController,
                    _bounceController,
                  ]),
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
                                  : Colors.grey.withOpacity(0.15),
                            ),
                          ),
                          Container(
                            width: 90.w,
                            height: 90.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording
                                  ? _colorAnim.value?.withOpacity(0.35)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          ScaleTransition(
                            scale: _scaleAnim,
                            child: CircleAvatar(
                              radius: 40.r,
                              backgroundImage: const AssetImage(
                                "assets/icons/circle.png",
                              ),
                              child: Image.asset(
                                _config['icon_mic'], // JSON
                                width: 24.w,
                                height: 32.h,
                                color: _isRecording ? _colorAnim.value : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}