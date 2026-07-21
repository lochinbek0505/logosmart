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

class FindImageGamePage extends StatefulWidget {
  const FindImageGamePage({super.key});

  @override
  State<FindImageGamePage> createState() => _FindImageGamePageState();
}

const String _backBtn = "assets/icons/arrow_right_button.png";
const String _starIcon = "assets/icons/star.png";
const String _micIcon = "assets/icons/micrafon.png";
const String _startVoice = "sound/find_image/game_1_start.mp3";
const String _successSound = "sound/success.mp3";
const String _incorrectSound = "sound/diagnostic_error.mp3";

const List<Map<String, dynamic>> _gameList = [
  {
    "image": "assets/game/find_image/ari.png",
    "sound": "assets/sound/find_image/ari.mp3",
    "text": "ari",
    "isCorrect": true,
  },
  {
    "image": "assets/game/find_image/pasha.png",
    "sound": "assets/sound/find_image/pashsha.mp3",
    "text": "pashsha",
    "isCorrect": false,
  },
  {
    "image": "assets/game/find_image/ninachi.png",
    "sound": "assets/sound/find_image/ninachi.mp3",
    "text": "ninachi",
    "isCorrect": false,
  },
  {
    "image": "assets/game/find_image/qongiz.png",
    "sound": "assets/sound/find_image/qongiz.mp3",
    "text": "qo'ng'iz",
    "isCorrect": false,
  },
];

class _FindImageGamePageState extends State<FindImageGamePage>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  bool _isRecording = false;
  bool _isLoading = false; // STT javobini kutayotganda true bo'ladi
  bool _isPlayingAudio = false; // Ovoz aytilayotganda true bo'ladi
  bool _showErrorAnim = false;
  String? _recordedFilePath;

  int _ball = 10;

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

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initPage() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _isPlayingAudio = true;
    });

    // Faqat o'yin sharti aytiladi, mikrofon yoqilmaydi
    await _playAudioAndWait(_startVoice);

    if (!mounted) return;
    setState(() {
      _isPlayingAudio = false;
    });
  }

  Future<void> _onItemTap(int index) async {
    // Agar STT (API) kutayotgan yoki yangi audio play bo'layotgan bo'lsa indamaymiz
    if (_isLoading || _isPlayingAudio) return;

    // MARK: Agar 3 sekund tugamay boshqasini bossa, avvalgi yozishni bekor qilamiz!
    if (_isRecording) {
      _recordingTimer?.cancel();
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
      setState(() {
        _isRecording = false; // Mikrofon shu joyning o'zida nofaol bo'ladi
        _pulseController.stop();
        _bounceController.stop();
      });
    }

    setState(() {
      _isPlayingAudio = true;
    });

    final item = _gameList[index];

    // 1. Rasm ovozini eshittirish va tugashini kutish
    await _playAudioAndWait(item["sound"]);

    // 2. Ovoz tugagach, mikrofon yozishga o'tish uchun holatni yangilaymiz
    if (!mounted) return;
    setState(() {
      _isPlayingAudio = false;
    });

    // 3. Mikrofonni ishga tushirish
    await _startRecording();

    // 4. Timer orqali roppa-rosa 3 soniya berish (Future.delayed o'rniga ishlatiladi)
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
          _isLoading = true; // STT API ga zapros ketyapti, endi loading chiqaramiz
        });
      }
    } else {
      return; // Agar yozib olish avvalroq bekor qilingan bo'lsa (boshqa rasm bosilganda)
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
        // Hech narsa eshitilmasa
        _handleWrongAnswer();
      }
    } catch (e) {
      debugPrint("STT Xatoligi: $e");
      _handleWrongAnswer();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Tekshiruv tugadi
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

    // Aytilgan matn hech biriga o'xshamasa
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
        _isPlayingAudio = true; // Xato ovozi chiqayotganda bloklash
      });
    }

    await _playAudioAndWait(_incorrectSound);

    if (mounted) {
      setState(() {
        _showErrorAnim = false;
        _isPlayingAudio = false;
      });
    }
  }

  void _gameEnd() async {
    if (mounted) {
      setState(() {
        _ball += 10;
        _isPlayingAudio = true; // Success ovozida bloklash
      });
    }
    await _audioPlayer.play(AssetSource(_successSound.replaceFirst('assets/', '')));

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
    return Scaffold(
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
                  Column(
                    children: [
                      SizedBox(height: 10.h),
                      _buildHeader(),
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
        child: SizedBox(
          width: 150.h,
          height: 150.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                item["image"]!,
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
        child: _isLoading // Faqatgina STT ga yuborilganda true bo'ladi
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
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