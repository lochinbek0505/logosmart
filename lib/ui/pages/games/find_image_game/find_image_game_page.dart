import 'dart:async';
import 'dart:convert'; // JSON o'qish uchun
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:record/record.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class FindImageGamePage extends StatefulWidget {
  const FindImageGamePage({super.key});

  @override
  State<FindImageGamePage> createState() => _FindImageGamePageState();
}

class _FindImageGamePageState extends State<FindImageGamePage>
    with TickerProviderStateMixin {

  // JSON dan keladigan sozlamalar
  late Map<String, dynamic> _config;
  late List<Map<String, dynamic>> _gameList;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  bool _isRecording = false;
  bool _isLoading = false;
  bool _isPlayingAudio = false;
  bool _showErrorAnim = false;
  String? _recordedFilePath;

  // 3 soniyalik intervalni boshqarish uchun taymer
  Timer? _recordingTimer;

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
    // 1. Joriy levelni Providerdan o'qib JSON ni parse qilamiz
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);

      // JSON ichidagi elementlarni listga olamiz
      List dynamicItems = _config['items'] ?? [];
      _gameList = List<Map<String, dynamic>>.from(dynamicItems);
    } else {
      // Fallback
      _config = {
        "start_voice": "assets/sound/find_image/game_1_start.mp3",
        "success_sound": "assets/sound/success.mp3",
        "incorrect_sound": "assets/sound/diagnostic_error.mp3",
        "background_image": "assets/backround/fon_q.png",
        "icon_star": "assets/icons/star.png",
        "icon_arrow": "assets/icons/arrow_right_button.png",
        "icon_mic": "assets/icons/micrafon.png",
      };
      _gameList = [
        {"image": "assets/game/find_image/ari.png", "sound": "assets/sound/find_image/ari.mp3", "text": "ari", "isCorrect": true},
        {"image": "assets/game/find_image/pasha.png", "sound": "assets/sound/find_image/pashsha.mp3", "text": "pashsha", "isCorrect": false},
        {"image": "assets/game/find_image/ninachi.png", "sound": "assets/sound/find_image/ninachi.mp3", "text": "ninachi", "isCorrect": false},
        {"image": "assets/game/find_image/qongiz.png", "sound": "assets/sound/find_image/qongiz.mp3", "text": "qo'ng'iz", "isCorrect": false},
      ];
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
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _isPlayingAudio = true;
    });

    if (_config['start_voice'] != null) {
      await _playAudioAndWait(_config['start_voice']);
    }

    if (!mounted) return;
    setState(() {
      _isPlayingAudio = false;
    });
  }

  Future<void> _onItemTap(int index) async {
    if (_isLoading || _isPlayingAudio) return;

    if (_isRecording) {
      _recordingTimer?.cancel();
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
      setState(() {
        _isRecording = false;
        _pulseController.stop();
        _bounceController.stop();
      });
    }

    setState(() {
      _isPlayingAudio = true;
    });

    final item = _gameList[index];

    await _playAudioAndWait(item["sound"]);

    if (!mounted) return;
    setState(() {
      _isPlayingAudio = false;
    });

    await _startRecording();

    _recordingTimer = Timer(const Duration(seconds: 3), () {
      _stopAndCheckRecording();
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _recordedFilePath =
        '${tempDir.path}/find_image_${DateTime.now().millisecondsSinceEpoch}.wav';

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

  Future<void> _stopAndCheckRecording() async {
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
    } else {
      return;
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

      debugPrint("STT natijasi: $recognizedText");

      if (recognizedText.isNotEmpty) {
        _evaluateRecognizedText(recognizedText);
      } else {
        _handleWrongAnswer();
      }
    } catch (e) {
      debugPrint("STT Xatoligi: $e");
      _handleWrongAnswer();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _evaluateRecognizedText(String text) {
    bool isMatchedAtAll = false;

    for (int i = 0; i < _gameList.length; i++) {
      final item = _gameList[i];
      if (_checkVoiceMatch(text, item["text"])) {
        isMatchedAtAll = true;
        if (item["isCorrect"] == true) {
          _gameEnd();
        } else {
          _handleWrongAnswer();
        }
        break;
      }
    }

    if (!isMatchedAtAll) {
      _handleWrongAnswer();
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
    if (mounted) {
      setState(() {
        _showErrorAnim = true;
        _isPlayingAudio = true;
      });
    }

    await _playAudioAndWait(_config['incorrect_sound']);

    if (mounted) {
      setState(() {
        _showErrorAnim = false;
        _isPlayingAudio = false;
      });
    }
  }

  void _gameEnd() async {
    // PROVIDER ORQALI BALL QO'SHISH VA LEVEL OCHISH
    final provider = context.read<LevelProvider>();
    provider.addBall(10);
    provider.unlock(stars: 3);

    if (mounted) {
      setState(() {
        _isPlayingAudio = true;
      });
    }

    await _audioPlayer.play(AssetSource(_cleanAudioPath(_config['success_sound'])));

    if (!mounted) return;
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

  @override
  void dispose() {
    _recordingTimer?.cancel();
    if (_isRecording) {
      _audioRecorder.stop();
    }
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
                        itemCount: _gameList.length,
                        itemBuilder: (context, index) {
                          final item = _gameList[index];
                          return _imageItem(item, index);
                        },
                      ),
                    ),
                  ),
                  _buildMicState(),
                ],
              ),
            ),
          ),

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

  Widget _imageItem(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () => _onItemTap(index),
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          double offset = sin(_floatingController.value * pi * 2) * 4;
          return Transform.translate(
            offset: Offset(0, offset),
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r)
          ),
          width: 150.h,
          height: 150.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                item["image"]!, // JSON
                width: 120.w,
                height: 120.h,
              ),
            ],
          ),
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
                        color: _isRecording
                            ? _colorAnim.value
                            :  null,
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