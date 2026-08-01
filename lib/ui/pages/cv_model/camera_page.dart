import 'dart:async';

import 'package:audioplayers/audioplayers.dart'; // <-- Ovoz uchun qo'shildi
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/cv_model/widgets/detection_overlay.dart';
import 'package:logosmart/ui/pages/cv_model/widgets/instruction_text.dart';
// Yo'llarni o'z loyihangiz papkalariga moslaysiz:
// import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:provider/provider.dart'; // <-- Provider ishlatish uchun
import 'package:video_player/video_player.dart';

import '../../../core/storage/level_state.dart';
import '../games/alphabet_map/provider/level_provider.dart';
import '../games/widgets/game_success_dialog.dart';
import '../main/widgets/Custom3dButton.dart';
import '../main/widgets/custom_text_widget.dart';
import 'widgets/camera_box.dart';
import 'widgets/video_box.dart';

// Yo'lni proyektga moslab o'zgartirasiz.
// Yuqorida yozilgan LevelProvider'ni import qilish kerak
// import 'path/to/level_provider.dart';

class CameraPage extends StatefulWidget {
  // Konstruktor endi HECH NARSA qabul qilmaydi!
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

const String _starIcon = "assets/icons/star.png";

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  // =========================================================================
  // ⚙️ ASOSIY SOZLAMALAR (KONFIGURATSIYA)
  // =========================================================================
  final int _totalCycles = 3;
  final int _holdDurationMs = 450;
  final int _processIntervalMs = 50;
  final double _minConfidence = 0.60;
  final double _requiredAvgConfidence = 0.50;
  final int _aboutStepDurationMs = 4000;

  // =========================================================================

  Key _camKey = UniqueKey();
  bool _cameraActive = true;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

  final AudioPlayer _audioPlayer = AudioPlayer(); // <-- Ovoz pleyeri

  List<ExerciseStep> _steps = [];
  String? _videoPath;
  String? _modelPath;
  String? _labelsPath;

  int _currentStepIndex = 0;
  int _completedCycles = 0;

  Map<String, dynamic>? _currentBest;
  List<Map<String, dynamic>> _lastDetections = [];

  DateTime? _actionStartTime;
  DateTime _lastProcessTime = DateTime.now();
  List<double> _confidenceVotes = [];
  bool _isProcessingVote = false;
  Timer? _aboutTimer;

  Color _cameraBoxBorderColor = const Color(0xff20B9E8);
  String _feedbackMessage = '';
  bool _waitingForNextStep = false;

  bool get _isExerciseCompleted => _completedCycles >= _totalCycles;

  DateTime? _lastGoodFrameTime;
  final int _toleranceMs = 600;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Barcha kerakli ma'lumotlarni Provider'dan darhol olib olamiz
    // read() yordamida olamiz, chunki initState da build qilinmayapti.
    final provider = context.read<LevelProvider>();
    final currentLevelData = provider.currentLevelData;

    if (currentLevelData != null && currentLevelData.exercise != null) {
      _steps = currentLevelData.exercise!.steps;
      _videoPath = currentLevelData.exercise!.mediaPath;
      _modelPath = currentLevelData.exercise!.modelPath;
      _labelsPath = currentLevelData.exercise!.labelsPath;
    }

    if (_steps.isEmpty)
      return; // Agar bosh bo'lsa, xato bo'ladi. Hozircha oddiy qaytadi.

    _initializeVideo();
    _handleCurrentStep();
  }

  void _handleCurrentStep() {
    if (_steps.isEmpty) return;
    if (_steps[_currentStepIndex].action == "about") {
      _aboutTimer?.cancel();
      _aboutTimer = Timer(Duration(milliseconds: _aboutStepDurationMs), () {
        _moveToNextStep();
      });
    }
  }

  void _onDetections(List<Map<String, dynamic>> results, Size imgSize) {
    if (!mounted ||
        results.isEmpty ||
        _waitingForNextStep ||
        _isExerciseCompleted ||
        !_cameraActive)
      return;

    final now = DateTime.now();
    if (now.difference(_lastProcessTime).inMilliseconds < _processIntervalMs)
      return;
    _lastProcessTime = now;

    _lastDetections = results;
    final expectedAction = _steps[_currentStepIndex].action;

    if (expectedAction == "about") return;

    _currentBest = results.first;

    final conf = _extractConfidence(_currentBest!);
    final label = _extractLabel(_currentBest!);

    if (_isLabelMatch(label, expectedAction) && conf >= _minConfidence) {
      if (_actionStartTime == null) _actionStartTime = now;
      _lastGoodFrameTime = now;
      _confidenceVotes.add(conf);

      if (now.difference(_actionStartTime!).inMilliseconds >= _holdDurationMs) {
        _processFrameVotingResult();
      }
    } else {
      if (_lastGoodFrameTime != null &&
          now.difference(_lastGoodFrameTime!).inMilliseconds > _toleranceMs) {
        _resetVoting();
      }
    }

    if (mounted) setState(() {});
  }

  void _processFrameVotingResult() {
    if (_isProcessingVote || _confidenceVotes.isEmpty) return;
    _isProcessingVote = true;

    final avgConfidence =
        _confidenceVotes.reduce((a, b) => a + b) / _confidenceVotes.length;

    if (avgConfidence >= _requiredAvgConfidence) {
      _onStepSuccess();
    } else {
      _onStepFailure();
    }
    _resetVoting();
  }

  void _resetVoting() {
    _actionStartTime = null;
    _lastGoodFrameTime = null;
    _confidenceVotes.clear();
    _isProcessingVote = false;
  }

  // BOLALAR UCHUN MOSLASHTIRILGAN SUCCESS
  void _onStepSuccess() {
    setState(() {
      _cameraBoxBorderColor = Colors.greenAccent;
      _feedbackMessage = '🌟 Barakalla! Juda yaxshi!';
    });

    _moveToNextStep();
  }

  // BOLALAR UCHUN MOSLASHTIRILGAN FAILURE
  void _onStepFailure() {
    setState(() {
      _cameraBoxBorderColor = Colors.orangeAccent;
      _feedbackMessage = '🤗 Yana bir bor urinib ko\'ramiz!';
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _cameraBoxBorderColor = const Color(0xff20B9E8);
          _feedbackMessage = '';
        });
      }
    });
  }

  void _moveToNextStep() {
    _waitingForNextStep = true;
    _resetVoting();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      if (_currentStepIndex < _steps.length - 1) {
        _currentStepIndex++;
      } else {
        _completedCycles++;
        if (_completedCycles < _totalCycles) {
          _currentStepIndex = 0;
        } else {
          _onAllCyclesCompleted();
          return;
        }
      }

      setState(() {
        _cameraBoxBorderColor = const Color(0xff20B9E8);
        _feedbackMessage = '';
        _waitingForNextStep = false;
      });
      _handleCurrentStep();
    });
  }

  // BAROAR TUGAGANDA DIALOG VA OVOZ (Provider Bilan)
  void _onAllCyclesCompleted() async {
    final provider = context.read<LevelProvider>();

    setState(() {
      _cameraActive = false;
      _feedbackMessage = '';
    });
    _videoController?.pause();

    // 1. Muvaffaqiyatli ovozni chalish
    try {
      await _audioPlayer.play(AssetSource('sound/success.mp3'));
    } catch (e) {
      print("Ovoz chalishda xatolik: $e");
    }

    // 2. Ball qo'shish va Backend sinxron funksiyasini qo'zg'atish
    provider.addBall(10);

    if (!mounted) return;

    // 3. Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameSuccessDialog(
          earnedScore: 10,
          onContinue: () async {
            // Yulduz berib (masalan: 3 ta) keyingi levelni ochamiz
            await provider.unlock(stars: 3);

            Navigator.pop(context); // Dialogni yopish
            Navigator.pop(context); // O'yin sahifasidan chiqish
          },
        );
      },
    );
  }

  double _extractConfidence(Map<String, dynamic> r) {
    final conf = r['score'] ?? 0.0;
    if (conf > 1.0 && conf <= 255.0) return conf / 255.0;
    return conf.toDouble().clamp(0.0, 1.0);
  }

  String _extractLabel(Map<String, dynamic> r) {
    return (r['class'] ?? '').toString();
  }

  bool _isLabelMatch(String label, String expectedAction) {
    return label.trim().toLowerCase().contains(
      expectedAction.trim().toLowerCase(),
    );
  }

  Future<void> _initializeVideo() async {
    if (_videoPath == null) return;

    try {
      _videoController = VideoPlayerController.asset(_videoPath!)
        ..setLooping(true)
        ..setVolume(0.0);
      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoError = false;
        });
        _videoController!.play();
      }
    } catch (e) {
      if (mounted) setState(() => _isVideoError = true);
    }
  }

  @override
  void dispose() {
    _cameraActive = false;
    _aboutTimer?.cancel();
    _videoController?.dispose();
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraActive = false;
      _videoController?.pause();
    } else if (state == AppLifecycleState.resumed && !_isExerciseCompleted) {
      _videoController?.play();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted)
          setState(() {
            _camKey = UniqueKey();
            _cameraActive = true;
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Cycle'ni ko'rsatish uchun hisob
    int displayCycle = _completedCycles + 1;
    if (displayCycle > _totalCycles) {
      displayCycle = _totalCycles;
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        _cameraActive = false;
        _videoController?.pause();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Fon
            Positioned.fill(
              child: Image.asset(
                'assets/backround/fon_q.png',
                fit: BoxFit.fill,
              ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Orqaga qaytish
                    SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: GestureDetector(
                        onTap: () {
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
                        // Umumiy ball uchun Consumer (yoki watch)
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

            // Xatolik oldini olish: agar steps bo'lmasa xato beradi (masalan noto'g'ri id yuborilsa)
            if (_steps.isEmpty)
              const Center(
                child: Text(
                  "Ma'lumotlar topilmadi!",
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(height: 160.h, width: size.width),

                  VideoBox(
                    size: size,
                    isVideoInitialized:
                        !_isExerciseCompleted && _isVideoInitialized,
                    isVideoError: _isVideoError,
                    currentVideoPath: _videoPath,
                    videoController: _videoController,
                    onRetry: _initializeVideo,
                  ),

                  SizedBox(height: 30.h),
                  _buildCameraBox(size),
                  SizedBox(height: 30.h),

                  if (!_isExerciseCompleted && _steps.isNotEmpty)
                    InstructionText(
                      stepNumber: displayCycle,
                      totalSteps: _totalCycles,
                      instructionText: _steps[_currentStepIndex].text,
                    ),

                  if (_isExerciseCompleted) const Custom3DButton(),
                ],
              ),

            if (_currentBest != null &&
                !_isExerciseCompleted &&
                _cameraActive &&
                _steps.isNotEmpty &&
                _steps[_currentStepIndex].action != "about" &&
                _currentStepIndex == 0)
              DetectionOverlay(
                currentBest: _currentBest,
                onExtractLabel: _extractLabel,
                onExtractConfidence: _extractConfidence,
              ),

            // O'YIN MATNLARI (Feedback) CHIQISH QISMI
            if (_feedbackMessage.isNotEmpty)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: _cameraBoxBorderColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: _cameraBoxBorderColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    _feedbackMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraBox(Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size.width * 0.6,
      height: size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: _isExerciseCompleted ? Colors.green : _cameraBoxBorderColor,
          width: 4.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isExerciseCompleted ? Colors.green : _cameraBoxBorderColor)
                .withOpacity(0.6),
            blurRadius: 15.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19.r),
        child: _isExerciseCompleted
            ? Container(
                color: Colors.black,
                child: Center(
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.yellow,
                    size: 80.sp,
                  ), // <-- Kichkintoylar uchun yulduzcha
                ),
              )
            : (_cameraActive && _modelPath != null && _labelsPath != null
                  ? CameraBox(
                      size: Size(size.width * 0.6, size.width * 0.6),
                      cameraActive: true,
                      camKey: _camKey,
                      modelPath: _modelPath!,
                      labelsPath: _labelsPath!,
                      onDetections: _onDetections,
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(child: CircularProgressIndicator()),
                    )),
      ),
    );
  }
}
