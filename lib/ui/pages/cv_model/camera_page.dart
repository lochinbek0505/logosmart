import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/cv_model/widgets/detection_overlay.dart';
import 'package:logosmart/ui/pages/cv_model/widgets/instruction_text.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../core/storage/level_state.dart';
import '../games/alphabet_map/provider/level_provider.dart';
import '../games/widgets/game_success_dialog.dart';
import '../main/widgets/Custom3dButton.dart';
import '../main/widgets/custom_text_widget.dart';
import 'widgets/camera_box.dart';
import 'widgets/video_box.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

const String _starIcon = "assets/icons/star.png";

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final int _totalCycles = 5;
  final int _holdDurationMs = 450;
  final int _processIntervalMs = 50;
  final double _minConfidence = 0.60;
  final double _requiredAvgConfidence = 0.50;
  final int _aboutStepDurationMs = 4000;

  Key _camKey = UniqueKey();

  // O'ZGARTIRISH: Boshlanishida kamera o'chiq turadi (kutish jarayoni uchun)
  bool _cameraActive = false;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  List<ExerciseStep> _steps = [];
  String? _videoPath;
  String? _modelPath;
  String? sound;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final provider = context.read<LevelProvider>();
    final currentLevelData = provider.currentLevelData;

    if (currentLevelData != null && currentLevelData.exercise != null) {
      _steps = currentLevelData.exercise!.steps;
      _videoPath = currentLevelData.exercise!.mediaPath;
      _modelPath = currentLevelData.exercise!.modelPath;
      sound = currentLevelData.exercise!.sound;
    }

    if (_steps.isEmpty) return;

    // O'ZGARTIRISH: Barcha jarayonlarni tartib bilan ishga tushiruvchi funksiyani chaqiramiz
    _startSequence();
  }

  // YANGLIK: Tartibli ishga tushirish funksiyasi
  Future<void> _startSequence() async {
    // 1. Dastlabki ovozni kutish (video va kamera bloklangan turibdi)
    if (sound != null && sound!.isNotEmpty) {
      await _playAudioAndWait(sound!);
    }

    // 2. Ovoz tugagach, 500 millisoniya pauza
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Endi video va kamerani ishga tushiramiz
    if (mounted) {
      await _initializeVideo(); // Video yuklanadi va play bo'ladi

      setState(() {
        _cameraActive = true; // Kamera stream endi ishga tushadi
      });

      _handleCurrentStep(); // Mashq mantiqlari boshlanadi
    }
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

  void _onStepSuccess() {
    setState(() {
      _cameraBoxBorderColor = Colors.greenAccent;
      _feedbackMessage = '🌟 Barakalla! Juda yaxshi!';
    });

    _moveToNextStep();
  }

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

  void _onAllCyclesCompleted() async {
    final provider = context.read<LevelProvider>();

    setState(() {
      _cameraActive = false;
      _feedbackMessage = '';
    });
    _videoController?.pause();

    try {
      await _audioPlayer.play(AssetSource('sound/success.mp3'));
    } catch (e) {
      print("Ovoz chalishda xatolik: $e");
    }

    provider.addBall(10);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameSuccessDialog(
          earnedScore: 10,
          onContinue: () async {
            await provider.unlock(stars: 3);
            Navigator.pop(context);
            Navigator.pop(context);
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
        // O'ZGARTIRISH: Videoning ovozi chiqishi uchun 0.0 o'rniga 1.0 qildim
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
                  SizedBox(height: 130.h, width: size.width),

                  VideoBox(
                    size: size,
                    isVideoInitialized:
                        !_isExerciseCompleted && _isVideoInitialized,
                    isVideoError: _isVideoError,
                    currentVideoPath: _videoPath,
                    videoController: _videoController,
                    onRetry: _initializeVideo,
                  ),

                  SizedBox(height: 20.h),
                  _buildCameraBox(size),
                  SizedBox(height: 20.h),

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
      width: size.width * 0.70,
      height: size.width * 0.70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: _isExerciseCompleted
              ? AppColors.green_900
              : _cameraBoxBorderColor,
          width: 4.w,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (_isExerciseCompleted
                        ? AppColors.green_900
                        : _cameraBoxBorderColor)
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
                  ),
                ),
              )
            : (_cameraActive && _modelPath != null && sound != null
                  ? CameraBox(
                      size: Size(size.width * 0.8, size.width * 0.8),
                      cameraActive: true,
                      camKey: _camKey,
                      modelPath: _modelPath!,
                      labelsPath: sound!,
                      onDetections: _onDetections,
                      borderColor: _isExerciseCompleted
                          ? AppColors.green_900
                          : _cameraBoxBorderColor,
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )),
      ),
    );
  }
}
