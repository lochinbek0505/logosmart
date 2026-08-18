import 'dart:async';
import 'dart:convert'; // JSON uchun

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/iafp_widget.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/path_drag_game_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:record/record.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class ItemAndFinishPathGamePage extends StatefulWidget {
  const ItemAndFinishPathGamePage({super.key});

  @override
  State<ItemAndFinishPathGamePage> createState() =>
      _ItemAndFinishPathGamePageState();
}

class _ItemAndFinishPathGamePageState extends State<ItemAndFinishPathGamePage>
    with TickerProviderStateMixin {
  // JSON dan keladigan sozlamalar
  late Map<String, dynamic> _config;

  bool _startPainting = true;
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
    _initLevelConfig();
    _initAnimations();
    _initPage();
  }

  void _initLevelConfig() {
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);
    } else {
      // Fallback: Agar tasodifan noto'g'ri ochilsa xato bermasligi uchun default qiymatlar
      _config = {
        "start_voice": "assets/sound/paint/paint_start.mp3",
        "item_sound": "assets/sound/paint/RRRRA.mp3",
        "error_sound": "assets/sound/paint/paint_end.mp3",
        "success_sound": "assets/sound/success.mp3",
        "image": "assets/game/paint/tiger.png",
        "target_text": "rrrra",
        "icon_arrow": "assets/icons/arrow_right_button.png",
        "icon_star": "assets/icons/star.png",
        "icon_mic": "assets/icons/micrafon.png",
        "path_config": {
          "startPoint": {"x": 0.15, "y": 0.9},
          "segments": [
            {
              "cp1": {"x": 1.5, "y": 0.7},
              "cp2": {"x": -0.5, "y": 0.3},
              "endPoint": {"x": 0.8, "y": 0},
            },
          ],
        },
      };
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
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  String _cleanAudioPath(String path) {
    if (path.startsWith('assets/')) {
      return path.replaceFirst('assets/', '');
    }
    return path;
  }

  Future<void> _playAudioAndWait(String path) async {
    final completer = Completer<void>();
    StreamSubscription<void>? subscription;

    subscription = _audioPlayer.onPlayerComplete.listen((_) {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete();
    });

    await _audioPlayer.play(AssetSource(_cleanAudioPath(path)));
    return completer.future;
  }

  Future<void> _initPage() async {
    if (_config['start_voice'] != null) {
      await _playAudioAndWait(_config['start_voice']);
    }
    if (_config['item_sound'] != null) {
      await _playAudioAndWait(_config['item_sound']);
    }

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
        _recordedFilePath =
            '${tempDir.path}/speech_input_${DateTime.now().millisecondsSinceEpoch}.wav';

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
      if (mounted) {
        setState(() {
          _isRecording = false;
          _pulseController.stop();
          _bounceController.stop();
          _isLoading = true;
        });
      }
    }

    if (_recordedFilePath == null) return;

    try {
      String recognizedText = await _sttService.transcribe(
        audioPath: _recordedFilePath!,
        language: 'uz',
      );

      debugPrint("Tizim eshitgan matn: $recognizedText");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      bool isMatched = _checkVoiceMatch(recognizedText, _config['target_text']);

      if (isMatched) {
        await _audioPlayer.play(
          AssetSource(_cleanAudioPath(_config['success_sound'])),
        );
        _gameEnd();
      } else {
        _handleWrongAnswer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _handleWrongAnswer();
    }
  }

  void _handleWrongAnswer() async {
    setState(() {
      _iafpKey = UniqueKey();
      _startPainting = true;
    });

    await _playAudioAndWait(_config['error_sound']);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _startPainting = false;
      });
      _startRecording();
    }
  }

  void _gameEnd() async {
    // PROVIDER ORQALI BALL QO'SHISH VA LEVEL OCHISH
    final provider = context.read<LevelProvider>();
    provider.addBall(10);
    provider.unlock(stars: 3);

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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final totalBall = context.watch<LevelProvider>().ball; // UMUMIY BALL

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  _config['background'],
                ),
                fit: BoxFit.cover,
              ),
            ),
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
                          SizedBox(
                            width: 48.w,
                            height: 48.h,
                            child: GestureDetector(
                              onTap: () {
                                context
                                    .read<LevelProvider>()
                                    .clearCurrentLevel();
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                _config['icon_arrow'], // JSON
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                _config['icon_star'], // JSON
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
                                      key: ValueKey<int>(totalBall),
                                      text: '$totalBall', // JSON
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
                                pathConfig: PathConfig.fromJson(
                                  _config['path_config'],
                                ),
                                // JSON'dan yuboriladi
                                image: _config['image'],
                                // JSON
                                sound: _config['target_text'],
                                // JSON
                                isLocked: _startPainting,
                                onFinished: _onPathFinished,
                              ),
                      ),

                      SizedBox(height: 30.h),

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
