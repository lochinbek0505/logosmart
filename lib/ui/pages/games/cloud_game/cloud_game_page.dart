import 'dart:async';
import 'dart:convert'; // JSON o'qish uchun
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Provider importi
import 'package:record/record.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class CloudGamePage extends StatefulWidget {
  const CloudGamePage({super.key});

  @override
  State<CloudGamePage> createState() => _CloudGamePageState();
}

class _CloudGamePageState extends State<CloudGamePage>
    with TickerProviderStateMixin {

  // JSON dan keladigan sozlamalar
  late Map<String, dynamic> _config;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  bool _isRecording = false;
  bool _isLoading = false;
  bool _showErrorAnim = false;
  String? _recordedFilePath;

  // Bulutlar ro'yxati (har biriga isMatched holati qo'shiladi)
  late List<Map<String, dynamic>> _cloudList;
  Map<String, dynamic>? _activeCloud; // Vertolyotga tashlangan joriy bulut

  Completer<void>? _audioCompleter;
  StreamSubscription<void>? _audioSub;

  // Mic animatsiyalari uchun
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnim;
  late Animation<double> _bounceAnim;
  late Animation<Color?> _colorAnim;

  // Rasmlar animatsiyasi uchun
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _initLevelConfig();
    _initAnimations();
    _initPage();
  }

  void _initLevelConfig() {
    // 1. Level ma'lumotlarini Providerdan o'qish va parse qilish
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);

      // JSON'dagi bulutlarga `isMatched: false` xususiyatini qo'shamiz
      List dynamicClouds = _config['clouds'] ?? [];
      _cloudList = dynamicClouds.map((cloud) {
        return {
          "id": cloud["id"],
          "text": cloud["text"],
          "music": cloud["music"],
          "isMatched": false,
        };
      }).toList();

    } else {
      // Fallback (Xavfsizlik uchun qoldirildi, agar Provider orqali ochilmasa ishlayveradi)
      _config = {
        "start_voice": "assets/sound/find_image/game_1_start.mp3",
        "success_sound": "assets/sound/success.mp3",
        "incorrect_sound": "assets/sound/diagnostic_error.mp3",
        "background_image": "assets/backround/fon_q.png",
        "icon_star": "assets/icons/star.png",
        "icon_arrow": "assets/icons/arrow_right_button.png",
        "icon_mic": "assets/icons/micrafon.png",
        "helicopter_image": "assets/game/cloud_game/helicopter.png",
        "cloud_image": "assets/game/cloud_game/cloud.png",
      };
      _cloudList = []; // Xatolik bo'lsa bo'sh ro'yxat
    }
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

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  // AudioPathdagi assets/ so'zini tozalash funksiyasi
  String _cleanAudioPath(String path) {
    if (path.startsWith('assets/')) {
      return path.replaceFirst('assets/', '');
    }
    return path;
  }

  Future<void> _initPage() async {
    // Faqat o'yin qoidasini aytadi, mikrofon yoqilmaydi
    await Future.delayed(const Duration(milliseconds: 500));
    if (_config['start_voice'] != null) {
      await _playAudioAndWait(_config['start_voice']);
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

  // MARK: - O'yin jarayoni mantiqlari
  Future<void> _onDragStarted(Map<String, dynamic> cloud) async {
    await _audioPlayer.stop();
    _audioCompleter = Completer<void>();
    _audioSub?.cancel();

    _audioSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (_audioCompleter != null && !_audioCompleter!.isCompleted) {
        _audioCompleter!.complete();
      }
    });

    String cleanPath = _cleanAudioPath(cloud["music"]);
    await _audioPlayer.play(AssetSource(cleanPath));
  }

  Future<void> _onCloudDropped(Map<String, dynamic> cloud) async {
    if (_isRecording || _isLoading) return;

    setState(() {
      _activeCloud = cloud;
    });

    if (_audioCompleter != null && !_audioCompleter!.isCompleted) {
      await _audioCompleter!.future;
    }

    await _startRecording();
    await Future.delayed(const Duration(seconds: 3));
    await _stopAndCheckRecording(cloud);
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _recordedFilePath =
        '${tempDir.path}/cloud_game_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: _recordedFilePath!,
        );

        if (mounted) {
          setState(() {
            _isRecording = true;
            _pulseController.repeat(reverse: true);
            _bounceController.repeat(reverse: true);
          });
        }
      }
    } catch (e) {
      debugPrint("Mikrofonni yoqishda xatolik: $e");
    }
  }

  Future<void> _stopAndCheckRecording(Map<String, dynamic> cloud) async {
    if (_isRecording) {
      await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _pulseController.stop();
          _bounceController.stop();
          _isLoading = true;
        });
      }
    }

    if (_recordedFilePath == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      String recognizedText = await _sttService.transcribe(
        audioPath: _recordedFilePath!,
        language: 'uz',
      );

      debugPrint("Tizim eshitgan matn: $recognizedText");

      bool isMatched = _checkVoiceMatch(recognizedText, cloud["text"]);

      if (isMatched) {
        await _audioPlayer.play(AssetSource(_cleanAudioPath(_config['success_sound'])));
        setState(() {
          cloud["isMatched"] = true;
          _activeCloud = null;
        });
        _checkGameEnd();
      } else {
        _handleWrongAnswer();
      }
    } catch (e) {
      debugPrint("STT Xatolik: $e");
      _handleWrongAnswer();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _checkVoiceMatch(String recognizedText, String targetText) {
    String cleanRecognized = recognizedText.toLowerCase().replaceAll(RegExp(r"[^a-z'ʻ]"), "");
    String cleanTarget = targetText.toLowerCase().replaceAll(RegExp(r"[^a-z'ʻ]"), "");

    if (cleanTarget.isEmpty || cleanRecognized.isEmpty) return false;

    String patternString = "";
    for (int i = 0; i < cleanTarget.length; i++) {
      if (i == 0 || cleanTarget[i] != cleanTarget[i - 1]) {
        patternString += "${cleanTarget[i]}+";
      }
    }

    RegExp regExp = RegExp(patternString);
    return regExp.hasMatch(cleanRecognized);
  }

  Future<void> _handleWrongAnswer() async {
    setState(() {
      _showErrorAnim = true;
    });

    await _playAudioAndWait(_config['incorrect_sound']);

    if (mounted) {
      setState(() {
        _showErrorAnim = false;
        _activeCloud = null;
      });
    }
  }

  void _checkGameEnd() {
    bool allMatched = _cloudList.every((cloud) => cloud["isMatched"] == true);
    if (allMatched) {
      _gameEnd();
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
            provider.clearCurrentLevel(); // Xotirani tozalash
            Navigator.pop(context);
            Navigator.pop(context); // Xaritaga qaytish
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UMUMIY BALLNI PROVIDERDAN OLAMIZ
    final totalBall = context.watch<LevelProvider>().ball;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F5),
      body: Stack(
        children: [
          Container(
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
                  _buildHeader(totalBall),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // MARK: Vertolyot (DragTarget)
                        DragTarget<Map<String, dynamic>>(
                          onWillAccept: (data) =>
                          _activeCloud == null && !_isRecording && !_isLoading,
                          onAccept: (data) {
                            _onCloudDropped(data);
                          },
                          builder: (context, candidateData, rejectedData) {
                            return SizedBox(
                              width: 180.w,
                              height: 180.h,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _floatingController,
                                    builder: (context, child) {
                                      double offset =
                                          sin(_floatingController.value * pi * 2) * 8;
                                      return Transform.translate(
                                        offset: Offset(0, offset),
                                        child: child,
                                      );
                                    },
                                    child: Image.asset(
                                      _config['helicopter_image'], // JSON
                                      height: 140.h,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  if (_activeCloud != null)
                                    Positioned(
                                      bottom: 20.h,
                                      child: _buildCloudItem(_activeCloud!, 0),
                                    )
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

                        // MARK: Bulutlar zonasi (Draggable)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12.w,
                            runSpacing: 10.h,
                            children: _cloudList.where((cloud) {
                              return cloud["isMatched"] == false && cloud != _activeCloud;
                            }).map((cloud) {
                              int index = _cloudList.indexOf(cloud);

                              return Draggable<Map<String, dynamic>>(
                                data: cloud,
                                onDragStarted: () => _onDragStarted(cloud),
                                child: _buildCloudItem(cloud, index),
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: _buildCloudItem(cloud, index),
                                  ),
                                ),
                                childWhenDragging: SizedBox(width: 100.w, height: 60.h),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMicState(),
                ],
              ),
            ),
          ),

          // Xato bo'lgandagi Qizil Animatsiya
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

  Widget _buildCloudItem(Map<String, dynamic> item, int index) {
    double topMargin = index % 2 == 0 ? 0 : 20.h;

    return Container(
      margin: EdgeInsets.only(top: topMargin),
      width: 100.w,
      height: 60.h,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_config['cloud_image']), // JSON
          fit: BoxFit.contain,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        item["text"],
        style: TextStyle(
          fontSize: 26.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF004466),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildMicState() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: SizedBox(
        height: 110.h,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AnimatedBuilder(
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
                          : Colors.transparent,
                    ),
                  ),
                  Container(
                    width: 90.w,
                    height: 90.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? _colorAnim.value?.withOpacity(0.35)
                          : Colors.transparent,
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
    );
  }

  Widget _buildHeader(int currentBall) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
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