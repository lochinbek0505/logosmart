import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logosmart/ui/pages/cv_model/widgets/detection_overlay.dart';
import 'package:logosmart/ui/pages/cv_model/widgets/instruction_text.dart';
import 'package:video_player/video_player.dart';

import '../../../core/storage/level_state.dart';
import '../main/widgets/Custom3dButton.dart';
import 'widgets/camera_box.dart';
import 'widgets/video_box.dart';

class CameraPage extends StatefulWidget {
  final LevelState data;

  const CameraPage({super.key, required this.data});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  // =========================================================================
  // ⚙️ ASOSIY SOZLAMALAR (KONFIGURATSIYA) - Oson o'zgartirish uchun
  // =========================================================================
  final int _totalCycles = 4; // Mashqlar sikli necha marta takrorlanishi kerak
  final int _holdDurationMs =
      450; // Harakatni qancha ushlab turish kerak (millisekund, 2000 = 2 sek)
  final int _processIntervalMs =
      50; // AI kadrlarni tahlil qilish oralig'i (ms). Telefon qotmasligi uchun
  final double _minConfidence =
      0.60; // Bitta kadrni "to'g'ri" deyish uchun minimal aniqlik (60%)
  final double _requiredAvgConfidence =
      0.50; // Yakuniy tasdiqlash uchun o'rtacha aniqlik
  final int _aboutStepDurationMs =
      4000; // "about" matni ekranda turish vaqti (4 soniya)
  // =========================================================================

  Key _camKey = UniqueKey();
  bool _cameraActive = true;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

  late List<ExerciseStep> _steps;
  int _currentStepIndex = 0;
  int _completedCycles = 0;

  Map<String, dynamic>? _currentBest;
  List<Map<String, dynamic>> _lastDetections = [];

  // AI va vaqt hisoblagichlari
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
  final int _toleranceMs = 600; // AI adashsa 600 millisekundgacha kechiramiz
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _steps = widget.data.exercise?.steps ?? [];
    if (_steps.isEmpty) return;

    _initializeVideo();
    _handleCurrentStep(); // Birinchi qadamni tekshirish (masalan "about" bo'lsa kutish)
  }

  // "about" kabi axborotli qadamlarni avtomat o'tkazish
  void _handleCurrentStep() {
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
    // 1. Kadrlarni filtrlaymiz (har _processIntervalMs da tekshiramiz)
    if (now.difference(_lastProcessTime).inMilliseconds < _processIntervalMs)
      return;
    _lastProcessTime = now;

    _lastDetections = results;
    final expectedAction = _steps[_currentStepIndex].action;
    // 2. Agar "about" qadami bo'lsa, AI ishlamay tursin
    if (expectedAction == "about") return;

    // 3. Eng yaxshi natijani topish
    _currentBest = results.first;

    final conf = _extractConfidence(_currentBest!);

    final label = _extractLabel(_currentBest!);

    // 4. Mantiq: To'g'ri harakat qilinyaptimi?

    if (_isLabelMatch(label, expectedAction) && conf >= _minConfidence) {
      // TO'G'RI KADR KELDI!
      if (_actionStartTime == null) _actionStartTime = now;
      _lastGoodFrameTime = now; // Yaxshi kadr kelgan vaqtni yozib qo'yamiz
      _confidenceVotes.add(conf);

      // Harakat uzluksiz 2 soniya ushlab turildimi?
      if (now.difference(_actionStartTime!).inMilliseconds >= _holdDurationMs) {
        _processFrameVotingResult();
      }
    } else {
      // XATO YOKI PAST FOIZ (masalan 37%) KELDI!
      // Darhol nolga tushirmaymiz. Agar so'nggi to'g'ri kadrdan 600ms (0.6 sekund)
      // o'tib ketgan bo'lsagina nolga tushiramiz (Reset).
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
    _lastGoodFrameTime = null; // Buni ham nolga tushiramiz
    _confidenceVotes.clear();
    _isProcessingVote = false;
  }

  void _onStepSuccess() {
    setState(() {
      _cameraBoxBorderColor = Colors.green;
      _feedbackMessage = '✅ Ajoyib!';
    });
    Fluttertoast.showToast(
      msg: '✅ To\'g\'ri bajarildi!',
      backgroundColor: Colors.green,
    );
    _moveToNextStep();
  }

  void _onStepFailure() {
    setState(() {
      _cameraBoxBorderColor = Colors.red;
      _feedbackMessage = '❌ Qayta urinib ko\'ring';
    });
    Fluttertoast.showToast(
      msg: '❌ Qayta urinib ko\'ring',
      backgroundColor: Colors.red,
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
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
        // Keyingi qadam
        _currentStepIndex++;
      } else {
        // Bir sikl tugadi
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
      _handleCurrentStep(); // Yangi qadam "about" emasligini tekshirish
    });
  }

  void _onAllCyclesCompleted() {
    setState(() {
      _cameraActive = false;
      _feedbackMessage = '';
    });
    _videoController?.pause();
    Fluttertoast.showToast(
      msg: '🎉 Barcha mashqlar yakunlandi!',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.green,
    );
  }

  // === YORDAMCHI FUNKSIYALAR ===
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
    final path = widget.data.exercise?.mediaPath;
    if (path == null) return;

    try {
      _videoController = VideoPlayerController.asset(path)
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

    return PopScope(
      // WillPopScope o'rniga zamonaviy PopScope
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Orqaga qaytish
                    SizedBox(
                      width: 50,
                      height: 50,
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
                    _buildCycleProgress(),
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/star.png",
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        Image.asset("assets/icons/namber_o.png", height: 35),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 180, width: size.width),

                VideoBox(
                  size: size,
                  isVideoInitialized:
                      !_isExerciseCompleted && _isVideoInitialized,
                  isVideoError: _isVideoError,
                  currentVideoPath: widget.data.exercise?.mediaPath,
                  videoController: _videoController,
                  onRetry: _initializeVideo,
                ),

                const SizedBox(height: 15),
                _buildCameraBox(size),
                const SizedBox(height: 15),

                if (!_isExerciseCompleted && _steps.isNotEmpty)
                  InstructionText(
                    stepNumber: _currentStepIndex + 1,
                    totalSteps: _steps.length,
                    instructionText: _steps[_currentStepIndex].text,
                  ),

                if (_isExerciseCompleted) const Custom3DButton(),
              ],
            ),

            if (_currentBest != null &&
                !_isExerciseCompleted &&
                _cameraActive &&
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _cameraBoxBorderColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _feedbackMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleProgress() {
    double progress = _totalCycles > 0 ? _completedCycles / _totalCycles : 0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            value: progress,
            color: _isExerciseCompleted
                ? Colors.greenAccent
                : const Color(0xff20B9E8),
          ),
          const SizedBox(width: 12),
          Text(
            _isExerciseCompleted
                ? "Yakunlandi"
                : "Bosqich: $_completedCycles/$_totalCycles",
            style: TextStyle(
              color: _isExerciseCompleted ? Colors.greenAccent : Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraBox(Size size) {
    final exercise = widget.data.exercise;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size.width * 0.6,
      height: size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isExerciseCompleted ? Colors.green : _cameraBoxBorderColor,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isExerciseCompleted ? Colors.green : _cameraBoxBorderColor)
                .withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: _isExerciseCompleted
            ? Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.celebration, color: Colors.green, size: 60),
                ),
              )
            : (_cameraActive && exercise != null
                  ? CameraBox(
                      size: Size(size.width * 0.6, size.width * 0.6),
                      cameraActive: true,
                      camKey: _camKey,
                      modelPath: exercise.modelPath,
                      labelsPath: exercise.labelsPath,
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
