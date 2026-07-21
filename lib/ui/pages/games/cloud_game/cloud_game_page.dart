import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../widgets/game_success_dialog.dart';

class CloudGamePage extends StatefulWidget {
  const CloudGamePage({super.key});

  @override
  State<CloudGamePage> createState() => _CloudGamePageState();
}

// Kerakli asset yo'llari
const String _backBtn = "assets/icons/arrow_right_button.png";
const String _starIcon = "assets/icons/star.png";
const String _micIcon = "assets/icons/micrafon.png";
const String _startVoice = "sound/find_image/game_1_start.mp3";
const String _successSound = "sound/success.mp3";
const String _incorrectSound = "sound/diagnostic_error.mp3";
const String _helicopterImage = "assets/game/cloud_game/helicopter.png";
const String _cloudImage = "assets/game/cloud_game/cloud.png";

class _CloudGamePageState extends State<CloudGamePage>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  bool _isRecording = false;
  bool _isLoading = false;
  bool _showErrorAnim = false;
  String? _recordedFilePath;

  int _ball = 10;

  // Bulutlar ro'yxati (har biriga holat qo'shildi)
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
    _initClouds();
    _initAnimations();
    _initPage();
  }

  void _initClouds() {
    // isMatched: true bo'lsa ekrandan g'oyib bo'ladi
    _cloudList = [
      {"id": 1, "text": "ar", "music": "assets/sound/cloud_game/ar.mp3", "isMatched": false},
      {"id": 2, "text": "ir", "music": "assets/sound/cloud_game/ir.mp3", "isMatched": false},
      {"id": 3, "text": "ur", "music": "assets/sound/cloud_game/ur.mp3", "isMatched": false},
      {"id": 4, "text": "er", "music": "assets/sound/cloud_game/er.mp3", "isMatched": false},
      {"id": 5, "text": "re", "music": "assets/sound/cloud_game/re.mp3", "isMatched": false},
      {"id": 6, "text": "or", "music": "assets/sound/cloud_game/or.mp3", "isMatched": false},
      {"id": 7, "text": "ru", "music": "assets/sound/cloud_game/ru.mp3", "isMatched": false},
      {"id": 8, "text": "ro", "music": "assets/sound/cloud_game/ro.mp3", "isMatched": false},
      {"id": 9, "text": "ri", "music": "assets/sound/cloud_game/ri.mp3", "isMatched": false},
      {"id": 10, "text": "ra", "music": "assets/sound/cloud_game/ra.mp3", "isMatched": false},
    ];
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

  Future<void> _initPage() async {
    // Faqat o'yin qoidasini aytadi, mikrofon yoqilmaydi
    await Future.delayed(const Duration(milliseconds: 500));
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

  // MARK: - O'yin jarayoni mantiqlari
  Future<void> _onDragStarted(Map<String, dynamic> cloud) async {
    // Sudrash boshlanganda ovoz qo'yamiz va ovoz tugashini kuzatamiz
    await _audioPlayer.stop();
    _audioCompleter = Completer<void>();
    _audioSub?.cancel();

    _audioSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (_audioCompleter != null && !_audioCompleter!.isCompleted) {
        _audioCompleter!.complete();
      }
    });

    String cleanPath = cloud["music"].replaceFirst('assets/', '');
    await _audioPlayer.play(AssetSource(cleanPath));
  }

  Future<void> _onCloudDropped(Map<String, dynamic> cloud) async {
    if (_isRecording || _isLoading) return;

    setState(() {
      _activeCloud = cloud;
    });

    // Musiqa aytilib bo'lishini kutamiz
    if (_audioCompleter != null && !_audioCompleter!.isCompleted) {
      await _audioCompleter!.future;
    }

    // Ovoz tugagach, mikrofonni yoqib 3 soniya kutamiz
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
          _isLoading = true; // STT API javobini kutamiz
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
        // Barakalla! To'g'ri topildi
        await _audioPlayer.play(AssetSource(_successSound.replaceFirst('assets/', '')));
        setState(() {
          cloud["isMatched"] = true;
          _activeCloud = null;
          _ball += 10;
        });
        _checkGameEnd();
      } else {
        // Noto'g'ri topildi
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
    // Masalan, STT "u u u r r r" deb eshitsa, buni birlashtirib "uuurrr" qiladi.
    String cleanRecognized = recognizedText.toLowerCase().replaceAll(RegExp(r"[^a-z'ʻ]"), "");
    String cleanTarget = targetText.toLowerCase().replaceAll(RegExp(r"[^a-z'ʻ]"), "");
    print("Clean Recognized: $cleanRecognized, Clean Target: $cleanTarget");
    if (cleanTarget.isEmpty || cleanRecognized.isEmpty) return false;

    // 2. Target matndan "qolip" (Regex) yasaymiz
    String patternString = "";
    for (int i = 0; i < cleanTarget.length; i++) {
      if (i == 0 || cleanTarget[i] != cleanTarget[i - 1]) {
        // Har bir harfning oxiriga "+" belgisini qo'shamiz
        // Regex'da "+" belgisi "shu harf kamida 1 marta yoki undan ko'p marta kelishi mumkin" degani
        patternString += "${cleanTarget[i]}+";
      }
    }

    // Masalan: "ur" kelsa -> patternString "u+r+" ga aylanadi.
    // "ru" kelsa -> patternString "r+u+" ga aylanadi.

    RegExp regExp = RegExp(patternString);

    // .hasMatch() orqali tekshiramiz.
    // "u+r+" qolipi "uuurrrr", "urrr", "uuuur" kabilarni HAMMASINI to'g'ri (true) deb qabul qiladi.
    return regExp.hasMatch(cleanRecognized);
  }
  Future<void> _handleWrongAnswer() async {
    setState(() {
      _showErrorAnim = true;
    });

    await _playAudioAndWait(_incorrectSound);

    if (mounted) {
      setState(() {
        _showErrorAnim = false;
        // _activeCloud null qilinganda u yana pastdagi o'z joyiga (Wrap) qaytadi
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F5),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backround/fon_q.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeader(),
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
                                      _helicopterImage,
                                      height: 140.h,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  // Agar bulut tashlangan bo'lsa, vertolyot tepasida ko'rsatib turamiz
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
                              // topilmagan va hozir vertolyotda emas bo'lganlarini ko'rsatadi
                              return cloud["isMatched"] == false && cloud != _activeCloud;
                            }).map((cloud) {
                              int index = _cloudList.indexOf(cloud);

                              return Draggable<Map<String, dynamic>>(
                                data: cloud,
                                onDragStarted: () => _onDragStarted(cloud),
                                // Asl ko'rinishi
                                child: _buildCloudItem(cloud, index),
                                // Sudrayotgandagi ko'rinishi (bir oz shaffof)
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Opacity(
                                    opacity: 0.8,
                                    child: _buildCloudItem(cloud, index),
                                  ),
                                ),
                                // Sudrayotganda joyida nima qolishi
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_cloudImage),
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
          decoration: TextDecoration.none, // Draggable feedback'da xunuk chiziq tushmasligi uchun
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
                        _micIcon,
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
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
              Image.asset(_starIcon, width: 32.w, height: 32.h),
              SizedBox(width: 8.w),
              CustomTextWidget(text: _ball.toString(), sizeText: 32.sp),
            ],
          ),
        ],
      ),
    );
  }
}