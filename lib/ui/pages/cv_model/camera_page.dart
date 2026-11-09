import 'dart:async';
import 'dart:math';

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
import '../games/widgets/game_fail_dialog.dart';
import '../games/widgets/game_success_dialog.dart';
import '../main/widgets/custom_text_widget.dart';
import 'widgets/camera_box.dart';
import 'widgets/SuccessGifPlaceholder.dart';
import 'widgets/celebration_overlay.dart';
import 'widgets/cycle_success_badge.dart';
import 'widgets/video_box.dart';
import 'package:logosmart/core/resources/app_resources.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

const String _starIcon = "assets/icons/star.webp";
const String _clapSound = "sound/cv/clap.mp3";

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final int _totalCycles = 5;
  // Model har ~200 ms da natija beradi (≈5 kadr/s)
  final int _inferenceIntervalMs = 200;
  // Harakat shuncha vaqt ushlab turilishi kerak (≈4 kadr)
  final int _holdDurationMs = 800;
  // Qaror chiqarish uchun kamida shuncha mos kadr kerak
  final int _minVotes = 3;
  final int _processIntervalMs = 50;
  // Kadr hisobga olinadigan eng past ishonch
  final double _minConfidence = 0.40;
  // Muvaffaqiyat uchun mos kadrlarning o'rtacha ishonchi
  final double _requiredAvgConfidence = 0.60;
  final int _failureCooldownMs = 1500;
  final int _aboutStepDurationMs = 4000;

  // --- O'tkazib yuborish (o'yinlardagi kMaxGameMistakes bilan bir xil g'oya) ---
  // Bola kadrda turib shuncha vaqt ichida qadamni bajara olmasa — bitta
  // muvaffaqiyatsiz urinish (sekin telefonda cho'ziladi, lekin 30 s dan oshmaydi)
  static const int _stepTimeLimitMs = 15000;
  static const int _maxStepTimeLimitMs = 30000;
  // Butun mashqdagi qadamlarning shuncha qismi o'tkazib yuborilsa — mashq ballsiz tugaydi
  static const double _failSkipRatio = 0.5;
  // Shu ulushgacha o'tkazilgan bo'lsa — 2 yulduz, undan ko'p — 1 yulduz
  static const double _twoStarSkipRatio = 0.25;
  static const int _fullScore = 10;

  /// Joriy qadamdagi muvaffaqiyatsiz urinishlar
  int _stepFails = 0;

  /// Butun mashqda o'tkazib yuborilgan qadamlar
  int _skippedSteps = 0;

  /// Joriy urinishda bola kadrda turgan vaqt (ms) — kadrda yo'q bo'lsa sanalmaydi
  int _presentMs = 0;
  DateTime? _lastPresenceTime;

  /// Mashq ballsiz yakunlandi ("Hechqisi yo'q" dialogi)
  bool _exerciseFailed = false;

  final Key _camKey = UniqueKey();

  // O'ZGARTIRISH: Boshlanishida kamera o'chiq turadi (kutish jarayoni uchun)
  bool _cameraActive = false;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _showCelebration = false;
  bool _showCycleBadge = false;
  int _badgeCycle = 0;
  Timer? _cycleBadgeTimer;

  List<ExerciseStep> _steps = [];
  String? _videoPath;
  String? _modelPath;
  String? sound;

  int _currentStepIndex = 0;
  int _completedCycles = 0;

  final ValueNotifier<Map<String, dynamic>?> _currentBest = ValueNotifier(null);

  DateTime? _actionStartTime;
  DateTime _lastProcessTime = DateTime.now();
  final List<double> _confidenceVotes = [];
  bool _isProcessingVote = false;
  // "Yana urinib ko'ramiz" xabari ko'rinib turganda yangi ovoz yig'ilmaydi
  bool _isInFailureCooldown = false;
  Timer? _aboutTimer;

  Color _cameraBoxBorderColor = const Color(0xff20B9E8);
  String _feedbackMessage = '';
  bool _waitingForNextStep = false;

  bool get _isExerciseCompleted => _completedCycles >= _totalCycles;

  DateTime? _lastGoodFrameTime;
  final int _toleranceMs = 600;

  // Kuchsiz qurilmalarda model 200 ms emas, 700–1500 ms da bir natija
  // beradi. Shuning uchun uzilish chegarasi va kerakli kadrlar soni
  // haqiqiy kadr oralig'iga qarab moslashadi — aks holda har bir kadr
  // oldingi ovozlarni o'chirib yuborib, mashq hech qachon hisoblanmaydi.
  DateTime? _lastResultTime;
  double _avgFrameGapMs = 200;

  int get _effectiveToleranceMs =>
      max(_toleranceMs, (_avgFrameGapMs * 2.5).round());

  int get _effectiveMinVotes => _avgFrameGapMs > 400 ? 2 : _minVotes;

  int get _effectiveStepTimeLimitMs => min(
    _maxStepTimeLimitMs,
    (_stepTimeLimitMs * max(1.0, _avgFrameGapMs / _inferenceIntervalMs))
        .round(),
  );

  /// Butun mashqda baholanadigan qadamlar soni ("about" hisobga kirmaydi)
  int get _countableSteps =>
      _steps.where((s) => s.action != "about").length * _totalCycles;

  Future<void> _playAudioAndWait(String path) async {
    final completer = Completer<void>();
    StreamSubscription<void>? subscription;

    subscription = _audioPlayer.onPlayerComplete.listen((_) {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await _audioPlayer.play(appAudioSource(path));
    } catch (e) {
      // Ovoz ochilmasa mashq baribir boshlanaveradi
      debugPrint("Audio xatosi ($path): $e");
      subscription.cancel();
      return;
    }
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => subscription?.cancel(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final provider = context.read<LevelProvider>();
    final currentLevelData = provider.currentLevelData;

    if (currentLevelData != null && currentLevelData.exercise != null) {
      // Birinchi "about" bosqichi StartTextPage'da ko'rsatib bo'lingan —
      // uni bu yerda o'tkazib yuboramiz (ro'yxatning o'zi o'zgartirilmaydi,
      // level qayta ochilganda intro yana chiqadi)
      final steps = currentLevelData.exercise!.steps;
      _steps = steps.isNotEmpty && steps.first.action == "about"
          ? steps.sublist(1)
          : List.of(steps);
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
      // Model qurilmada bo'lmasa (orqa fonda hali yuklanmagan) — shu yerda yuklab olinadi
      final modelPath = _modelPath;
      if (modelPath != null && modelPath.isNotEmpty) {
        _modelPath = await appModelPath(modelPath);
      }
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
        _waitingForNextStep ||
        _isExerciseCompleted ||
        _exerciseFailed ||
        !_cameraActive) {
      return;
    }

    final now = DateTime.now();

    // Kadrlar orasidagi haqiqiy vaqtni kuzatamiz (sekin sakrashlar —
    // fon/pauza — o'rtachani buzmasligi uchun cheklanadi)
    if (_lastResultTime != null) {
      final gap = now.difference(_lastResultTime!).inMilliseconds.toDouble();
      if (gap > 0 && gap < 3000) {
        _avgFrameGapMs = _avgFrameGapMs * 0.8 + gap * 0.2;
      }
    }
    _lastResultTime = now;

    if (now.difference(_lastProcessTime).inMilliseconds < _processIntervalMs) {
      return;
    }
    _lastProcessTime = now;

    final expectedAction = _steps[_currentStepIndex].action;

    if (expectedAction == "about") return;

    // Uzoq uzilishdan keyin (kadrda yuz yo'q edi) hisob boshidan boshlanadi
    if (_lastGoodFrameTime != null &&
        now.difference(_lastGoodFrameTime!).inMilliseconds >
            _effectiveToleranceMs) {
      _resetVoting();
    }

    final expectedBest = _bestDetection(
      results,
      (r) => _isLabelMatch(_extractLabel(r), expectedAction),
    );
    // Faqat pastdagi aniqlash paneli yangilanadi — butun sahifa har kadrda
    // qayta chizilmaydi (video, kamera, matnlar)
    _currentBest.value = expectedBest ?? _bestDetection(results, (_) => true);

    if (_isInFailureCooldown) return;

    // Kadrda bola bormi (istalgan aniqlash) — bor bo'lsa urinish vaqti sanaladi
    if (_trackPresence(results.isNotEmpty, now)) return;

    final conf = expectedBest == null ? 0.0 : _extractConfidence(expectedBest);

    if (expectedBest != null && conf >= _minConfidence) {
      _actionStartTime ??= now;
      _lastGoodFrameTime = now;
      _confidenceVotes.add(conf);

      if (now.difference(_actionStartTime!).inMilliseconds >= _holdDurationMs &&
          _confidenceVotes.length >= _effectiveMinVotes) {
        _processFrameVotingResult();
      }
    }
  }

  /// Bola kadrda turgan vaqtni yig'adi. Vaqt tugasa urinish muvaffaqiyatsiz
  /// hisoblanadi va true qaytadi (shu kadr boshqa ishlanmaydi).
  bool _trackPresence(bool present, DateTime now) {
    if (!present) {
      _lastPresenceTime = null;
      return false;
    }
    final last = _lastPresenceTime;
    _lastPresenceTime = now;
    if (last != null) {
      final gap = now.difference(last).inMilliseconds;
      // Uzoq uzilish (kadrda yo'q edi, ilova fonda edi) — sanalmaydi
      if (gap <= _effectiveToleranceMs) _presentMs += gap;
    }
    if (_presentMs < _effectiveStepTimeLimitMs) return false;
    _registerFailedAttempt(timedOut: true);
    return true;
  }

  void _resetStepAttempts() {
    _stepFails = 0;
    _presentMs = 0;
    _lastPresenceTime = null;
  }

  /// Shartga mos natijalar ichidan eng ishonchlisini qaytaradi
  Map<String, dynamic>? _bestDetection(
    List<Map<String, dynamic>> results,
    bool Function(Map<String, dynamic>) test,
  ) {
    Map<String, dynamic>? best;
    for (final r in results) {
      if (!test(r)) continue;
      if (best == null || _extractConfidence(r) > _extractConfidence(best)) {
        best = r;
      }
    }
    return best;
  }

  void _processFrameVotingResult() {
    if (_isProcessingVote || _confidenceVotes.isEmpty) return;
    _isProcessingVote = true;

    final avgConfidence =
        _confidenceVotes.reduce((a, b) => a + b) / _confidenceVotes.length;

    _resetVoting();
    if (avgConfidence >= _requiredAvgConfidence) {
      _onStepSuccess();
    } else {
      _onStepFailure();
    }
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
      // Cycle oxirgi bosqichida "Barakalla" badge chiqadi, oddiy xabar emas
      _feedbackMessage = _currentStepIndex < _steps.length - 1
          ? '👍 Zo\'r! Davom etamiz!'
          : '';
    });

    _moveToNextStep();
  }

  void _onStepFailure() => _registerFailedAttempt();

  /// Kuchsiz bajarildi yoki vaqt tugadi. Qadamda [kMaxGameMistakes] marta
  /// bo'lsa — qadam o'tkazib yuboriladi, aks holda yana urinib ko'riladi.
  void _registerFailedAttempt({bool timedOut = false}) {
    _resetVoting();
    _stepFails++;
    _presentMs = 0;
    _lastPresenceTime = null;
    if (_stepFails >= kMaxGameMistakes) {
      _skipCurrentStep();
      return;
    }

    // Namuna videosi boshidan — bola harakatni yana bir bor ko'radi
    _videoController?.seekTo(Duration.zero);
    _isInFailureCooldown = true;
    setState(() {
      _cameraBoxBorderColor = Colors.orangeAccent;
      _feedbackMessage = timedOut
          ? '🤗 Videoga qarab, yana bir bor urinib ko\'ramiz!'
          : '🤗 Yana bir bor urinib ko\'ramiz!';
    });

    Future.delayed(Duration(milliseconds: _failureCooldownMs), () {
      if (!mounted) return;
      _isInFailureCooldown = false;
      _resetVoting();
      // Shu orada keyingi qadamga o'tilgan bo'lsa, uning xabariga tegmaymiz
      if (_waitingForNextStep || _exerciseFailed) return;
      setState(() {
        _cameraBoxBorderColor = const Color(0xff20B9E8);
        _feedbackMessage = '';
      });
    });
  }

  void _skipCurrentStep() {
    _skippedSteps++;
    final total = _countableSteps;
    if (total > 0 && _skippedSteps >= (total * _failSkipRatio).ceil()) {
      _onExerciseFailed();
      return;
    }
    setState(() {
      _cameraBoxBorderColor = Colors.orangeAccent;
      // Sikl oxirida sikl badge'i chiqadi — xabar uning ustiga tushmasin
      _feedbackMessage = _currentStepIndex < _steps.length - 1
          ? '💪 Hechqisi yo\'q, keyingisiga o\'tamiz!'
          : '';
    });
    _moveToNextStep();
  }

  /// Qadamlarning yarmi o'tkazib yuborildi — o'yinlardagidek ballsiz yakun,
  /// keyingi level baribir ochiladi
  void _onExerciseFailed() {
    _aboutTimer?.cancel();
    _cycleBadgeTimer?.cancel();
    setState(() {
      _exerciseFailed = true;
      _cameraActive = false;
      _feedbackMessage = '';
      _showCycleBadge = false;
    });
    _videoController?.pause();
    showGameFailDialog(context);
  }

  void _moveToNextStep() {
    _waitingForNextStep = true;
    _resetVoting();

    final completesCycle = _currentStepIndex == _steps.length - 1;
    final isFinalCycle = completesCycle && _completedCycles + 1 >= _totalCycles;
    if (completesCycle && !isFinalCycle) {
      _showCycleSuccess();
    }

    Future.delayed(Duration(milliseconds: completesCycle ? 1800 : 1000), () {
      if (!mounted || _exerciseFailed) return;
      _resetStepAttempts();

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

  void _showCycleSuccess() {
    _cycleBadgeTimer?.cancel();
    setState(() {
      _badgeCycle = _completedCycles + 1;
      _showCycleBadge = true;
    });
    _cycleBadgeTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showCycleBadge = false);
    });
  }

  void _onAllCyclesCompleted() async {
    final provider = context.read<LevelProvider>();

    setState(() {
      _cameraActive = false;
      _feedbackMessage = '';
      _showCelebration = true;
    });
    _videoController?.pause();

    // Qarsak ovozi animatsiya bilan birga chalinadi
    await Future.wait([
      _playClapSound(),
      Future.delayed(const Duration(milliseconds: 2800)),
    ]);

    // O'tkazib yuborilgan qadamlar bo'lsa — qisman mukofot
    final total = _countableSteps;
    final skipRatio = total == 0 ? 0.0 : _skippedSteps / total;
    final stars = _skippedSteps == 0
        ? 3
        : skipRatio <= _twoStarSkipRatio
        ? 2
        : 1;
    final earned = total == 0
        ? _fullScore
        : (_fullScore * (total - _skippedSteps) / total).round();
    provider.addBall(earned);

    if (!mounted) return;
    setState(() => _showCelebration = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameSuccessDialog(
          earnedScore: earned,
          onContinue: () async {
            await provider.unlock(stars: stars);
            if (!context.mounted) return;
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _playClapSound() async {
    try {
      await _playAudioAndWait(
        _clapSound,
      ).timeout(const Duration(seconds: 4), onTimeout: () {});
    } catch (e) {
      debugPrint("Ovoz chalishda xatolik: $e");
    }
  }

  double _extractConfidence(Map<String, dynamic> r) {
    final conf = r['score'] ?? 0.0;
    if (conf > 1.0 && conf <= 255.0) return conf / 255.0;
    return conf.toDouble().clamp(0.0, 1.0);
  }

  String _extractLabel(Map<String, dynamic> r) {
    return (r['class'] ?? '').toString();
  }

  // Aniq moslik: "past" endi "ichki_past" ni ham qabul qilib yubormaydi
  bool _isLabelMatch(String label, String expectedAction) {
    return label.trim().toLowerCase() == expectedAction.trim().toLowerCase();
  }

  Future<void> _initializeVideo() async {
    if (_videoPath == null) return;

    try {
      _videoController = (await appVideoController(_videoPath!))
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
    _cycleBadgeTimer?.cancel();
    _videoController?.dispose();
    _audioPlayer.dispose();
    _currentBest.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Kamerani fonga o'tishda to'xtatish/qayta yoqishni YOLOView plaginining
  // o'zi lifecycle orqali qiladi — bu yerda faqat video va ovoz hisobi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _videoController?.pause();
      _resetVoting();
      // Fonda o'tgan vaqt urinish vaqtiga qo'shilmaydi
      _lastPresenceTime = null;
    } else if (state == AppLifecycleState.resumed &&
        !_isExerciseCompleted &&
        !_exerciseFailed &&
        _isVideoInitialized) {
      _videoController?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    // Header (orqaga tugmasi + ball) tugaydigan joy
    final double topOffset = media.padding.top + 20.h + 50.h + 12.h;
    final double gap = 14.h;

    int displayCycle = _completedCycles + 1;
    if (displayCycle > _totalCycles) {
      displayCycle = _totalCycles;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _cameraActive = false;
        _videoController?.pause();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AppImage.asset(
                'assets/backround/fon_q.webp',
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
                        child: AppImage.asset(
                          "assets/icons/arrow_right_button.webp",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        AppImage.asset(_starIcon, width: 32.w, height: 32.h),
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
                  SizedBox(height: topOffset, width: size.width),

                  // Video va kamera bo'sh joyni to'liq egallaydi
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double boxSide = min(
                          size.width * 0.88,
                          (constraints.maxHeight - gap) / 2,
                        );
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            VideoBox(
                              size: size,
                              dimension: boxSide,
                              isVideoInitialized: _isVideoInitialized,
                              isVideoError: _isVideoError,
                              currentVideoPath: _videoPath,
                              videoController: _videoController,
                              onRetry: _initializeVideo,
                            ),
                            SizedBox(height: gap),
                            _buildCameraBox(boxSide),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(height: gap),

                  if (!_isExerciseCompleted && _steps.isNotEmpty)
                    InstructionText(
                      stepNumber: displayCycle,
                      totalSteps: _totalCycles,
                      instructionText: _steps[_currentStepIndex].text,
                    ),

                  SizedBox(height: media.padding.bottom + 12.h),
                ],
              ),

            if (!_isExerciseCompleted &&
                _cameraActive &&
                _steps.isNotEmpty &&
                _steps[_currentStepIndex].action != "about" &&
                _currentStepIndex == 0)
              ValueListenableBuilder<Map<String, dynamic>?>(
                valueListenable: _currentBest,
                builder: (context, best, _) => best == null
                    ? const SizedBox.shrink()
                    : DetectionOverlay(
                        currentBest: best,
                        onExtractLabel: _extractLabel,
                        onExtractConfidence: _extractConfidence,
                      ),
              ),

            if (_feedbackMessage.isNotEmpty)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: _cameraBoxBorderColor.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: _cameraBoxBorderColor.withValues(alpha: 0.5),
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

            if (_showCycleBadge)
              Positioned.fill(
                child: Center(
                  child: CycleSuccessBadge(
                    key: ValueKey(_badgeCycle),
                    completedCycles: _badgeCycle,
                    totalCycles: _totalCycles,
                  ),
                ),
              ),

            if (_showCelebration)
              const Positioned.fill(child: CelebrationOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraBox(double side) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: side,
      height: side,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: _isExerciseCompleted
              ? AppColors.green_700
              : _cameraBoxBorderColor,
          width: 4.w,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (_isExerciseCompleted
                        ? AppColors.green_700
                        : _cameraBoxBorderColor)
                    .withValues(alpha: 0.6),
            blurRadius: 15.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19.r),
        child: _isExerciseCompleted
            ? const SuccessGifPlaceholder()
            : (_cameraActive && (_modelPath?.isNotEmpty ?? false)
                  ? CameraBox(
                      key: _camKey,
                      modelPath: _modelPath!,
                      intervalMs: _inferenceIntervalMs,
                      confidenceThreshold: _minConfidence,
                      onDetections: _onDetections,
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
