import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/arrow_game/widgets/arrow_line_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../../../models/target_node_model.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../widgets/game_success_dialog.dart';

class ArrowGamePage extends StatefulWidget {
  const ArrowGamePage({super.key});

  @override
  State<ArrowGamePage> createState() => _ArrowGamePageState();
}

const String _micIcon = "assets/icons/micrafon.png";
const String _startVoice = "sound/arrow/arrow_start.mp3";
const String _backBtn = "assets/icons/arrow_right_button.png";

class _ArrowGamePageState extends State<ArrowGamePage>
    with TickerProviderStateMixin {
  final double innerRadius = 70.w;
  final double outerRadius = 150.w;
  final String centerLetter = "R";

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  final List<TargetNode> outerNodes = [
    // Izoh: Oxirgi parametr (masalan "AGGG") _checkVoiceMatch da solishtirish uchun ishlatiladi
    TargetNode(
      0,
      "A",
      AppColors.orange_400,
      -180,
      "assets/sound/arrow/ar.mp3",
      "aarr",
    ),
    TargetNode(
      1,
      "O",
      AppColors.green_600,
      -90,
      "assets/sound/arrow/or.mp3",
      "oorr",
    ),
    TargetNode(
      2,
      "U",
      AppColors.pink_400,
      0,
      "assets/sound/arrow/ur.mp3",
      "uurr",
    ),
    // TargetNode(
    //   3,
    //   "I",
    //   const Color(0xFFF2C860),
    //   30,
    //   "assets/sound/arrow/ir.mp3",
    //   "iirr",
    // ),
    TargetNode(
      4,
      "E",
      const Color(0xFF7FD8F7),
      90,
      "assets/sound/arrow/er.mp3",
      "ERRR",
    ),
    // TargetNode(
    //   5,
    //   "O'",
    //   AppColors.red_300,
    //   150,
    //   "assets/sound/arrow/o1r.mp3",
    //   "o'r",
    // ),
  ];



  Map<int, int> connectedLines = {};

  int _ball = 20;
  bool _isRecording = false;
  bool _isLoading = false;
  String? _recordedFilePath;
  int? _activeVoiceItemId;

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

  Future<void> _initPage() async {
    await _playAudioAndWait(_startVoice);
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

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _recordedFilePath = '${tempDir.path}/speech_input_arrow.wav';

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

  Future<void> _stopAndCheckRecording(TargetNode node) async {
    if (_isRecording) {
      await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _pulseController.stop();
          _bounceController.stop();
          _isLoading = true; // STT API javobini kutishni boshlaymiz
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

      // Node ning 'matchText' qiymati TargetNode dagi oxirgi parametr,
      // sizning kodingizda uning nomi qanday bo'lsa (masalan: targetText), shuni bering.
      // Hozirgi faraz: node.matchText yoki node.targetText
      bool isMatched = _checkVoiceMatch(recognizedText, node.text);

      if (isMatched) {
        if (mounted) {
          setState(() {
            connectedLines[node.id] = node.id;
          });
        }
        await _audioPlayer.play(AssetSource('sound/success.mp3'));
        _showSnackbar("Barakalla! To'g'ri topildi.", Colors.green);
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
    // 1. Probel va ortiqcha belgilarni olib tashlaymiz.
    // O'zbek tilidagi O' va G' uchun tutuq belgisi (') ni ham qoldiramiz.
    String cleanRecognized = recognizedText.toLowerCase().replaceAll(RegExp(r"[^a-z']"), "");
    String cleanTarget = targetText.toLowerCase().replaceAll(RegExp(r"[^a-z']"), "");
    print("Clean Recognized: $cleanRecognized, Clean Target: $cleanTarget");
    if (cleanTarget.isEmpty || cleanRecognized.isEmpty) return false;

    // 2. Target matndan qolib (pattern) yasaymiz
    // Masalan: Target "arrr" bo'lsa, u "a+r+" qolipiga aylanadi.
    String patternString = "";
    for (int i = 0; i < cleanTarget.length; i++) {
      // Faqat yonma-yon takrorlanmagan harflarni olamiz
      if (i == 0 || cleanTarget[i] != cleanTarget[i - 1]) {
        // Har bir harf orqasiga "+" qo'shamiz (ma'nosi: shu harfdan 1 ta yoki undan ko'p bo'lsin)
        patternString += "${cleanTarget[i]}+";
      }
    }

    // 3. Tizim eshitgan matnni shu qolibga solib tekshiramiz
    RegExp regExp = RegExp(patternString);

    // .hasMatch() agar matn ichida biz yasagan qolib (masalan "a+r+") topilsa true qaytaradi.
    return regExp.hasMatch(cleanRecognized);
  }
  void _handleWrongAnswer() async {
    _showSnackbar("Xato eshitildi, qayta urinib ko'ring!", Colors.red);
    // Agar xato javob uchun alohida audio bo'lsa:
    // await _playAudioAndWait('sound/error.mp3');
  }

  Future<void> _onNodeTapped(TargetNode node) async {
    // Agar chiziq tortilgan bo'lsa, mikrofon yozayotgan yoki yuklanayotgan bo'lsa bloklaymiz
    if (_isRecording ||
        _isLoading ||
        connectedLines.containsKey(node.id) ||
        _activeVoiceItemId != null) {
      return;
    }

    setState(() {
      _activeVoiceItemId = node.id;
    });

    // 1. Harf ovozini chalish
    await _audioPlayer.stop();
    await _playAudioAndWait(node.sound);

    // 2. Yozib olishni boshlash
    await _startRecording();

    // 3. Bolaga gapirish uchun 3 soniya vaqt berish
    await Future.delayed(const Duration(seconds: 3));

    // 4. To'xtatish va tekshirish
    await _stopAndCheckRecording(node);

    if (mounted) {
      setState(() {
        _activeVoiceItemId = null;
      });
    }
  }

  void _checkGameEnd() {
    if (connectedLines.length == outerNodes.length) {
      _gameEnd();
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
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backround/arrow/arrow_back_1.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: _buildHeader(),
              ),

              // Game Area
              Expanded(
                child: Center(
                  child: SizedBox(
                    // Maydonni kattalashtiramiz, harflar bemalol sig'ishi uchun
                    width: 360.w,
                    height: 380.h,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final Offset centerPoint = Offset(
                          constraints.maxWidth / 2,
                          constraints.maxHeight / 2,
                        );

                        return Stack(
                          // Tashqariga chiqqan elementlar kesilib qolmasligi uchun qo'shiladi:
                          clipBehavior: Clip.none,
                          children: [
                            // Lines Painter
                            CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: ArrowLinePainter(
                                centerPoint: centerPoint,
                                innerRadius: innerRadius,
                                outerRadius: outerRadius,
                                // Agar baribir chetga chiqsa, yuqorida buni 120.w yoki 130.w qilib kamaytiring
                                outerNodes: outerNodes,
                                connectedLines: connectedLines,
                                activeInnerNode: null,
                                currentDragPosition: null,
                              ),
                            ),

                            // Center Letter
                            Positioned(
                              left: centerPoint.dx - innerRadius,
                              top: centerPoint.dy - innerRadius,
                              width: innerRadius * 2,
                              height: innerRadius * 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CustomTextWidget(
                                    text: centerLetter,
                                    sizeText: 96.sp,
                                    textColor: const Color(0xFF4A90E2),
                                    strokeWidth: 8.w,
                                  ),
                                ),
                              ),
                            ),

                            // Inner Circles
                            ...List.generate(outerNodes.length, (index) {
                              final pos = _calculatePosition(
                                centerPoint,
                                innerRadius,
                                outerNodes[index].angle,
                              );
                              return Positioned(
                                left: pos.dx - 12.w,
                                // 36 / 2
                                top: pos.dy - 15.w,
                                width: 30.w,
                                // Aniq o'lcham
                                height: 30.w,
                                // Aniq o'lcham
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                            // Outer Letters
                            ...outerNodes.map((node) {
                              final pos = _calculatePosition(
                                centerPoint,
                                outerRadius,
                                node.angle,
                              );
                              final bool isConnected = connectedLines
                                  .containsKey(node.id);

                              return Positioned(
                                // 80.w lik konteynerning roppa-rosa yarmini ayiramiz
                                left: pos.dx - 40.w,
                                top: pos.dy - 40.h,
                                width: 80.w,
                                // Aniq o'lcham beramiz
                                height: 80.h,
                                // Aniq o'lcham beramiz
                                child: GestureDetector(
                                  onTap: () => _onNodeTapped(node),
                                  child: Container(
                                    color: Colors.transparent,
                                    // Tap zonani butun quti bo'ylab ishlatish uchun
                                    alignment: Alignment.center,
                                    // Harfni markazga aniq tushiradi
                                    child: CustomTextWidget(
                                      text: node.letter,
                                      sizeText: 64.sp,
                                      textColor: isConnected
                                          ? Colors.grey
                                          : node.color,
                                      strokeWidth: 6.w,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Mic / Loading State
              Padding(
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
                                        _micIcon,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              Image.asset("assets/icons/star.png", width: 40.w, height: 40.h),
              SizedBox(width: 8.w),
              CustomTextWidget(text: _ball.toString(), sizeText: 32.sp),
            ],
          ),
        ],
      ),
    );
  }

  Offset _calculatePosition(Offset center, double radius, double angleDegree) {
    final double angleRadian = angleDegree * (pi / 180);
    return Offset(
      center.dx + radius * cos(angleRadian),
      center.dy + radius * sin(angleRadian),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
