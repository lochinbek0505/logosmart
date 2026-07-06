import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/iafp_widget.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/path_drag_game_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../widgets/game_success_dialog.dart';

class ItemAndFinishPathGamePage extends StatefulWidget {
  const ItemAndFinishPathGamePage({super.key});

  @override
  State<ItemAndFinishPathGamePage> createState() =>
      _ItemAndFinishPathGamePageState();
}

// {
//   "image":"assets/images/paint/tiger.png",
//   "sound":"assets/sound/paint/rrrra.mp3",
//   "soundText":"rrra",
//   "startSound":"assets/paint/paint_start.mp3",
//   "error_sound":"assets/paint/paint_error.mp3"
//   "shape_number":1
// }

class _ItemAndFinishPathGamePageState extends State<ItemAndFinishPathGamePage>
    with TickerProviderStateMixin {
  final level1 = {
    "startPoint": {"x": 0.15, "y": 0.9},
    "segments": [
      {
        "cp1": {"x": 1.5, "y": 0.7},
        "cp2": {"x": -0.5, "y": 0.3},
        "endPoint": {"x": 0.8, "y": 0},
      },
    ],
  };

  final level2 = {
    "startPoint": {"x": 0.40, "y": 0.05},
    "segments": [
      {
        "type": "line",
        "endPoint": {"x": 0.85, "y": 0.02},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.35, "y": 0.25},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.95, "y": 0.35},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.15, "y": 0.45},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.90, "y": 0.60},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.05, "y": 0.70},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.80, "y": 0.85},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.40, "y": 0.95},
      },
    ],
  };

  final level3 = {
    "startPoint": {"x": 0.10, "y": 0.05},
    "segments": [
      {
        "type": "line",
        "endPoint": {"x": 0.95, "y": 0.05},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.95, "y": 0.95},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.20, "y": 0.95},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.20, "y": 0.25},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.75, "y": 0.25},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.75, "y": 0.75},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.40, "y": 0.75},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.40, "y": 0.45},
      },
      {
        "type": "line",
        "endPoint": {"x": 0.60, "y": 0.45},
      },
    ],
  };

  final level4 = {
    "startPoint": {"x": 0.60, "y": 0.05},
    "segments": [
      {
        "type": "curve",
        "cp1": {"x": 0.00, "y": 0.05},
        "cp2": {"x": 0.00, "y": 0.35},
        "endPoint": {"x": 0.90, "y": 0.35},
      },
      {
        "type": "curve",
        "cp1": {"x": 1.0, "y": 0.35},
        "cp2": {"x": 1.30, "y": 0.65},
        "endPoint": {"x": 0.10, "y": 0.65},
      },
      {
        "type": "curve",
        "cp1": {"x": 0, "y": 0.65},
        "cp2": {"x": -0.30, "y": 0.95},
        "endPoint": {"x": 0.90, "y": 0.90},
      },
      {
        "type": "curve",
        "cp1": {"x": 1.10, "y": 0.90},
        "cp2": {"x": 0.60, "y": 0.95},
        "endPoint": {"x": 0.30, "y": 1},
      },
    ],
  };

  final level5 = {
    "startPoint": {"x": 0.60, "y": 0.05},
    "segments": [
      {
        "type": "curve",
        "cp1": {"x": 0.85, "y": 0.05},
        "cp2": {"x": 0.95, "y": 0.25},
        "endPoint": {"x": 0.95, "y": 0.45},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.95, "y": 0.75},
        "cp2": {"x": 0.75, "y": 0.90},
        "endPoint": {"x": 0.50, "y": 0.90},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.25, "y": 0.90},
        "cp2": {"x": 0.10, "y": 0.70},
        "endPoint": {"x": 0.10, "y": 0.45},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.10, "y": 0.20},
        "cp2": {"x": 0.25, "y": 0.2},
        "endPoint": {"x": 0.50, "y": 0.25},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.70, "y": 0.3},
        "cp2": {"x": 0.75, "y": 0.50},
        "endPoint": {"x": 0.75, "y": 0.50},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.75, "y": 0.65},
        "cp2": {"x": 0.60, "y": 0.70},
        "endPoint": {"x": 0.55, "y": 0.70},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.25, "y": 0.70},
        "cp2": {"x": 0.2, "y": 0.60},
        "endPoint": {"x": 0.25, "y": 0.50},
      },
      {
        "type": "curve",
        "cp1": {"x": 0.3, "y": 0.40},
        "cp2": {"x": 0.45, "y": 0.40},
        "endPoint": {"x": 0.55, "y": 0.45},
      },
    ],
  };

  bool _startPainting = true;
  String planeSound = "rrrra";
  int _ball = 12;
  Key _iafpKey = UniqueKey();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  String? _recordedFilePath;
  bool _isRecording = false;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnim;
  late Animation<double> _bounceAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initPage();
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _playAudioAndWait(String path) async {
    final completer = Completer<void>();
    StreamSubscription<void>? subscription;

    subscription = _audioPlayer.onPlayerComplete.listen((_) {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete();
    });

    await _audioPlayer.play(AssetSource(path));
    return completer.future;
  }

  Future<void> _initPage() async {
    await _playAudioAndWait('sound/paint/paint_start.mp3');
    await _playAudioAndWait('sound/paint/RRRRA.mp3');
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _startPainting = false;
      });
      _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _recordedFilePath = '${tempDir.path}/speech_input.wav';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: _recordedFilePath!,
        );

        setState(() {
          _isRecording = true;
          _pulseController.repeat(reverse: true);
          _bounceController.repeat(reverse: true);
        });
      }
    } catch (e) {
      debugPrint("Mikrofonni yoqishda xatolik: $e");
    }
  }

  bool _checkVoiceMatch(String recognizedText, String targetText) {
    String cleanRecognized = recognizedText.toLowerCase().replaceAll(
      RegExp(r'[^a-z]'),
      '',
    );
    String cleanTarget = targetText.toLowerCase().replaceAll(
      RegExp(r'[^a-z]'),
      '',
    );

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

  Future<void> _onPathFinished() async {
    setState(() {
      _startPainting = true;
    });

    if (_isRecording) {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _pulseController.stop();
        _bounceController.stop();
        _isLoading = true;
      });
    }

    if (_recordedFilePath == null) return;

    try {
      String recognizedText = await _sttService.transcribe(
        audioPath: _recordedFilePath!,
        language: 'uz',
      );

      debugPrint("Tizim eshitgan matn: $recognizedText");

      setState(() {
        _isLoading = false;
      });

      bool isMatched = _checkVoiceMatch(recognizedText, planeSound);

      if (isMatched) {
        await _audioPlayer.play(AssetSource('sound/success.mp3'));
        _gameEnd();
      } else {
        _handleWrongAnswer();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _handleWrongAnswer();
    }
  }

  void _handleWrongAnswer() async {
    // Xato eshitilganda qahramonni darhol boshiga qaytaramiz (reset qilinadi)
    setState(() {
      _iafpKey = UniqueKey();
      _startPainting = true; // Hali harakatlana olmaydi
    });

    // paint_end ovozini chalishni kutamiz
    await _playAudioAndWait('sound/paint/paint_end.mp3');

    // Ovoz tugagach, biroz kutamiz
    await Future.delayed(const Duration(milliseconds: 500));

    // Keyin mikrofonni va harakatlanish imkonini yoqamiz
    if (mounted) {
      setState(() {
        _startPainting = false;
      });
      _startRecording();
    }
  }

  void _gameEnd() async {
    setState(() {
      _ball += 10;
    });

    await _audioPlayer.play(AssetSource('sound/success.mp3'));

    if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            color: AppColors.grey_50,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Orqaga qaytish tugmasi kichraytirildi
                          SizedBox(
                            width: 48.w,
                            height: 48.h,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Image.asset(
                                "assets/icons/arrow_right_button.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              // Yulduzcha kichraytirildi
                              Image.asset(
                                "assets/icons/star.png",
                                width: 32.w,
                                height: 32.h,
                              ),
                              const SizedBox(width: 8),
                              Stack(
                                alignment: Alignment.center,
                                children: [
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
                        ],
                      ),

                      SizedBox(height: 100.h),

                      SizedBox(
                        height: 430.h,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : IafpWidget(
                                key: _iafpKey,
                                pathConfig: PathConfig.fromJson(level1),
                                image: "assets/game/paint/tiger.png",
                                sound: "Rrrra",
                                isLocked: _startPainting,
                                onFinished: _onPathFinished,
                              ),
                      ),

                      SizedBox(height: 30.h),

                      // Mikrofon widgetlari kichraytirildi
                      AnimatedBuilder(
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
                                  width: 110.w, // 100 dan 110 ga kattalashdi
                                  height: 110.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isRecording
                                        ? _colorAnim.value?.withOpacity(0.25)
                                        : Colors.grey.withOpacity(0.15),
                                  ),
                                ),
                                Container(
                                  width: 90.w, // 80 dan 90 ga kattalashdi
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
                                    radius: 40.r, // 35 dan 40 ga kattalashdi
                                    backgroundImage: const AssetImage(
                                      "assets/icons/circle.png",
                                    ),
                                    child: Image.asset(
                                      "assets/icons/micrafon.png",
                                      width: 24.w, // 20 dan 24 ga kattalashdi
                                      height: 32.h, // 28 dan 32 ga kattalashdi
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
