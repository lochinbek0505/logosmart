import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../widgets/game_success_dialog.dart';

const String _bgImage = "assets/backround/cooking/cooking.png";
const String _backBtn = "assets/icons/arrow_right_button.png";
const String _starIcon = "assets/icons/star.png";
const String _micIcon = "assets/icons/micrafon.png";
const String _girlImage = "assets/game/cooking/chef_girl.png";
const String _startVoice = "sound/cooking/cooking_start.mp3";

final List<Map<String, dynamic>> _initialItems = [
  {
    "id": "soup",
    "asset": "assets/game/cooking/shorva.png",
    "text": "sho\'rva",
    "sound": "sound/cooking/shorva.mp3",
  },
  {
    "id": "tomato",
    "asset": "assets/game/cooking/pamidor.png",
    "text": "pamidor",
    "sound": "sound/cooking/pamidor.mp3",
  },
  {
    "id": "cucumber",
    "asset": "assets/game/cooking/bodring.png",
    "text": "bodring",
    "sound": "sound/cooking/bodring.mp3",
  },
  {
    "id": "radish",
    "asset": "assets/game/cooking/rediska.png",
    "text": "rediska",
    "sound": "sound/cooking/rediska.mp3",
  },
  {
    "id": "pomegranate",
    "asset": "assets/game/cooking/anor.png",
    "text": "anor",
    "sound": "sound/cooking/anor.mp3",
  },
];

class CookingPage extends StatefulWidget {
  const CookingPage({super.key});

  @override
  State<CookingPage> createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage>
    with TickerProviderStateMixin {
  int _ball = 20;
  List<Map<String, dynamic>> _products = [];
  String? _eatingItemId;
  bool _isGirlEating = false;
  bool _isDragEnabled = false;

  // Qaysi elementning ovozi chalinayotganini kuzatish uchun
  String? _activeVoiceItemId;
  StreamSubscription<void>? _audioCompleteSubscription;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false; // Fake recording holati uchun

  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnim;
  late Animation<double> _bounceAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initAudioListener();
    initPage();
  }

  // Ovoz tugaganini eshitib turuvchi funksiya
  void _initAudioListener() {
    _audioCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _activeVoiceItemId = null; // Ovoz tugadi, qolganlarini ochamiz
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

  Future<void> initPage() async {
    await _playAudioAndWait(_startVoice);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _products = List.from(_initialItems);
        _isDragEnabled = true;
      });
    }
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

  void _startFakeRecording() {
    setState(() {
      _isRecording = true;
      _pulseController.repeat(reverse: true);
      _bounceController.repeat(reverse: true);
    });
  }

  Future<void> _processAcceptedItem(Map<String, dynamic> item) async {
    setState(() {
      _activeVoiceItemId =
          'success'; // Qizcha yeyotganda boshqa narsalarni qulflash
      _isRecording = false;
      _pulseController.stop();
      _bounceController.stop();
    });

    await _audioPlayer.stop(); // Avvalgi sabzavot ovozini to'xtatamiz
    await _audioPlayer.play(AssetSource('sound/success.mp3'));

    setState(() {
      _eatingItemId = item['id'];
      _isGirlEating = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _products.removeWhere((p) => p['id'] == item['id']);
          _ball += 5;
          _isGirlEating = false;
          _eatingItemId = null;
        });
        _checkGameEnd();
      }
    });
  }

  void _checkGameEnd() {
    if (_products.isEmpty) {
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage(_bgImage), fit: BoxFit.fill),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10.h,
                left: 17.w,
                right: 17.w,
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
                        const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: CustomTextWidget(
                            key: ValueKey<int>(_ball),
                            text: '$_ball',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ..._products.map((item) {
                final isBeingEaten = _eatingItemId == item['id'];

                return AnimatedPositioned(
                  duration: Duration(milliseconds: isBeingEaten ? 500 : 0),
                  bottom: isBeingEaten ? 250.h : _getYPosition(item['id']),
                  right: isBeingEaten ? 80.w : _getXPosition(item['id']),
                  child: AnimatedScale(
                    duration: Duration(milliseconds: isBeingEaten ? 500 : 0),
                    scale: isBeingEaten ? 0.0 : 1.0,
                    child: IgnorePointer(
                      // SHU YERDA QULF: Ovoz tugamaguncha boshqa elementlarni ushlab bo'lmaydi
                      ignoring:
                          !_isDragEnabled ||
                          (_activeVoiceItemId != null &&
                              _activeVoiceItemId != item['id']),
                      child: Draggable<Map<String, dynamic>>(
                        data: item,
                        onDragStarted: () async {
                          // QO'SHILGAN QISM: Agar bosilgan sabzavot ovozi allaqachon chalinayotgan bo'lsa,
                          // ovozni qayta ishga tushirmaymiz.
                          if (_activeVoiceItemId == item['id']) {
                            // Agar animatsiya to'xtab qolgan bo'lsa, davom ettirib qo'yamiz
                            if (!_isRecording) _startFakeRecording();
                            return;
                          }

                          setState(() {
                            _activeVoiceItemId = item['id'];
                          });

                          // Bir-biriga ustma-ust tushib qolmasligi uchun stop() chaqiramiz
                          await _audioPlayer.stop();
                          _audioPlayer.play(
                            AssetSource(
                              item['sound'].toString().replaceFirst(
                                'assets/',
                                '',
                              ),
                            ),
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
                        _girlImage,
                        width: 180.w,
                        height: 320.h,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
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
                                _micIcon,
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

  double _getXPosition(String id) {
    switch (id) {
      case "soup":
        return 220.w;
      case "tomato":
        return 40.w;
      case "cucumber":
        return 130.w;
      case "radish":
        return 230.w;
      case "pomegranate":
        return 220.w;
      default:
        return 0.0;
    }
  }

  double _getYPosition(String id) {
    switch (id) {
      case "soup":
        return 550.h;
      case "tomato":
        return 520.h;
      case "cucumber":
        return 420.h;
      case "radish":
        return 320.h;
      case "pomegranate":
        return 200.h;
      default:
        return 0.0;
    }
  }
}
