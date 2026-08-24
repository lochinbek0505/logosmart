import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../../theme/app_colors.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class TrainGamePage extends StatefulWidget {
  const TrainGamePage({super.key});

  @override
  State<TrainGamePage> createState() => _TrainGamePageState();
}

class _TrainGamePageState extends State<TrainGamePage>
    with TickerProviderStateMixin {
  late Map<String, dynamic> _config;
  late List<Map<String, dynamic>> _gameList;
  late List<Map<String, dynamic>> _trains;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  bool _isRecording = false;
  bool _isLoading = false;
  bool _isPlayingAudio = false;
  bool _showErrorAnim = false;
  String? _recordedFilePath;

  int? _currentlyTestingIndex;
  final Set<int> _unlockedImages = {};
  final Set<int> _completedImages = {};

  Timer? _recordingTimer;

  // Mic animatsiyalari
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnim;
  late Animation<double> _bounceAnim;
  late Animation<Color?> _colorAnim;

  // Bolalar uchun drag (surish) animatsiyasi
  late AnimationController _dragHintController;
  late Animation<double> _dragHintMoveAnim;
  late Animation<double> _dragHintFadeAnim;

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
      _gameList = List<Map<String, dynamic>>.from(_config['items'] ?? []);
      _trains = List<Map<String, dynamic>>.from(_config['trains'] ?? []);
    } else {
      _config = {
        "start_voice": "assets/sound/train_game/train_start.mp3",
        "success_sound": "assets/sound/success.mp3",
        "incorrect_sound": "assets/sound/diagnostic_error.mp3",
        "icon_star": "assets/icons/star.png",
        "icon_arrow": "assets/icons/arrow_right_button.png",
        "icon_mic": "assets/icons/micrafon.png",
        "trains": [
          {
            "id": "main",
            "image": "assets/game/train_game/train_main.png",
            "syllable": 0,
            "sound": "assets/sound/train_game/train_start.mp3",
          },
          {
            "id": "1",
            "image": "assets/game/train_game/train_1.png",
            "syllable": 1,
            "sound": "assets/sound/train_game/train_1.mp3",
          },
          {
            "id": "2",
            "image": "assets/game/train_game/train_2.png",
            "syllable": 2,
            "sound": "assets/sound/train_game/train_2.mp3",
          },
          {
            "id": "3",
            "image": "assets/game/train_game/train_3.png",
            "syllable": 3,
            "sound": "assets/sound/train_game/train_3.mp3",
          },
        ],
        "items": [
          {
            "image": "assets/game/train_game/qor_1.png",
            "sound": "assets/sound/train_game/qor.mp3",
            "syllable": 1,
            "text": "qor",
          },
          {
            "image": "assets/game/train_game/arri_2.jpg",
            "sound": "assets/sound/train_game/ari.mp3",
            "syllable": 2,
            "text": "arri",
          },
          {
            "image": "assets/game/train_game/vertalyot_3.jpg",
            "sound": "assets/sound/train_game/vertalyot.mp3",
            "syllable": 3,
            "text": "vertolyot",
          },
        ],
      };
      _gameList = List<Map<String, dynamic>>.from(_config['items']);
      _trains = List<Map<String, dynamic>>.from(_config['trains']);
    }
  }

  void _initAnimations() {
    // Mikrofon uchun animatsiyalar
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

    // Yangi qo'shilgan: Bolalar uchun Drag qilish animatsiyasi (Tepaga suriluvchi qo'lcha)
    _dragHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Qo'lcha pastdan tepaga qarab harakatlanadi
    _dragHintMoveAnim = Tween<double>(begin: 20.0, end: -50.0).animate(
      CurvedAnimation(parent: _dragHintController, curve: Curves.easeOut),
    );

    // Qo'lcha tepaga yetganda asta-sekin yo'qoladi (Fade Out)
    _dragHintFadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dragHintController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );
  }

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

  Future<void> _onWagonTap(Map<String, dynamic> train) async {
    if (_isPlayingAudio || _isRecording || _isLoading) return;

    setState(() => _isPlayingAudio = true);
    await _playAudioAndWait(train["sound"]);
    if (mounted) setState(() => _isPlayingAudio = false);
  }

  Future<void> _onImageTap(int index) async {
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

    _currentlyTestingIndex = index;
    final item = _gameList[index];

    setState(() => _isPlayingAudio = true);
    await _playAudioAndWait(item["sound"]);
    if (!mounted) return;
    setState(() => _isPlayingAudio = false);

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
        '${tempDir.path}/train_game_${DateTime.now().millisecondsSinceEpoch}.wav';

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

    if (_recordedFilePath == null || _currentlyTestingIndex == null) {
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
        _evaluateRecognizedText(recognizedText, _currentlyTestingIndex!);
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

  void _evaluateRecognizedText(String text, int index) {
    final item = _gameList[index];
    if (_checkVoiceMatch(text, item["text"])) {
      setState(() {
        _unlockedImages.add(index);
      });
      // Qisqa yashil yorug'lik musiqasi (ixtiyoriy)
    } else {
      _handleWrongAnswer();
    }
  }

  bool _checkVoiceMatch(String recognizedText, String targetText) {
    String cleanRecognized = recognizedText.toLowerCase().replaceAll(
      RegExp(r"[^a-z'ʻ]"),
      "",
    );
    String cleanTarget = targetText.toLowerCase().replaceAll(
      RegExp(r"[^a-z'ʻ]"),
      "",
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

  Future<void> _handleCorrectDrop(int imageIndex) async {
    setState(() {
      _completedImages.add(imageIndex);
    });

    setState(() => _isPlayingAudio = true);
    await _playAudioAndWait(_config['success_sound']);
    if (mounted) setState(() => _isPlayingAudio = false);

    if (_completedImages.length == _gameList.length) {
      _gameEnd();
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
    _dragHintController.dispose(); // Yangi controllerni tozalash
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalBall = context.watch<LevelProvider>().ball;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backround/fon_q.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: AbsorbPointer(
              absorbing: _isPlayingAudio || _showErrorAnim,
              child: Column(
                children: [
                  SizedBox(height: 50.h),
                  _buildHeader(totalBall),
                  SizedBox(height: 50.h),

                  // VAGONLAR QISMI
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ..._trains.map((train) => _buildTrainItem(train)),
                      ],
                    ),
                  ),

                  // RASMLAR QISMI
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_gameList.length, (index) {
                            return _buildDraggableImage(
                              _gameList[index],
                              index,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  // MIKROFON HOLATI
                  _buildMicState(),
                ],
              ),
            ),
          ),

          // XATOLIK ANIMATSIYASI
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

  Widget _buildTrainItem(Map<String, dynamic> train) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (data) {
        if (data["syllable"] == train["syllable"]) {
          _handleCorrectDrop(data["index"]);
        } else {
          _handleWrongAnswer();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () => _onWagonTap(train),
          child: Image.asset(
            train["image"],
            height: 60.h,
            color: candidateData.isNotEmpty ? Colors.grey.shade400 : null,
            colorBlendMode: candidateData.isNotEmpty
                ? BlendMode.modulate
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDraggableImage(Map<String, dynamic> item, int index) {
    if (_completedImages.contains(index)) {
      return SizedBox(width: 100.w, height: 140.h);
    }

    bool isUnlocked = _unlockedImages.contains(index);

    Widget childWidget = Container(
      width: 100.w,
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        // Rasm to'g'ri topilsa yashil chiroyli nur effektli ramka bo'ladi
        border: isUnlocked ? Border.all(color: Colors.green, width: 3) : null,
        boxShadow: isUnlocked
            ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ]
            : [],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Image.asset(
              item["image"],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image, color: Colors.grey),
            ),
          ),

          // YANGA QO'SHILGAN BOLALAR UCHUN ANIMATSIYA
          if (isUnlocked)
            AnimatedBuilder(
              animation: _dragHintController,
              builder: (context, child) {
                return Positioned(
                  // Qo'lcha pastdan tepaga qarab siljiydi
                  top: _dragHintMoveAnim.value,
                  child: Opacity(
                    // Tepaga chiqqanida asta yo'qoladi
                    opacity: _dragHintFadeAnim.value,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.pan_tool_alt_rounded, // Qo'lcha (barmoq) ikonkasi
                        color: Colors.green,
                        size: 34.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );

    if (isUnlocked) {
      return Draggable<Map<String, dynamic>>(
        data: {
          ...item,
          "index": index,
        },
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.9,
            child: SizedBox(
              width: 110.w,
              height: 150.h,
              child: childWidget,
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: childWidget),
        child: childWidget,
      );
    } else {
      return GestureDetector(
        onTap: () => _onImageTap(index),
        child: childWidget,
      );
    }
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
                        _config['icon_mic'],
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
              child: Image.asset(
                _config['icon_arrow'],
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: Image.asset(
                  _config['icon_star'],
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.star, color: Colors.orange),
                ),
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