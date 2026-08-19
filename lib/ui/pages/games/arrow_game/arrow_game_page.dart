import 'dart:async';
import 'dart:convert'; // JSON o'qish uchun
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/arrow_game/widgets/arrow_line_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Provider importi
import 'package:record/record.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../../../models/target_node_model.dart';
import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class ArrowGamePage extends StatefulWidget {
  const ArrowGamePage({super.key});

  @override
  State<ArrowGamePage> createState() => _ArrowGamePageState();
}

class _ArrowGamePageState extends State<ArrowGamePage>
    with TickerProviderStateMixin {
  // JSON dan keladigan sozlamalar
  late Map<String, dynamic> _config;
  late String _centerLetter;
  late List<TargetNode> _outerNodes;

  final double innerRadius = 70.w;
  final double outerRadius = 135.w;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  Map<int, int> connectedLines = {};

  bool _isRecording = false;
  bool _isLoading = false;
  // O'yin tugab, dialog ochilish jarayonida yangi tap/record boshlanmasligi uchun
  bool _isGameEnding = false;
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

    // 1. Level ma'lumotlarini Providerdan o'qish va parse qilish
    final currentLevel = context.read<LevelProvider>().currentLevelData;
    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);
      _centerLetter = _config['center_letter'] ?? "R";

      // Node larni JSON dan ob'ektga aylantirish
      _outerNodes = (_config['outer_nodes'] as List).map<TargetNode>((node) {
        return TargetNode(
          node['id'],
          node['letter'],
          Color(int.parse(node['color'])), // Hex kodidan rang yaratamiz
          (node['angle'] as num).toDouble(),
          node['sound'],
          node['target_text'],
        );
      }).toList();
    } else {
      // Fallback xavfsizlik (Kutilmagan xatolik uchun)
      _config = {
        "start_voice": "assets/sound/arrow/arrow_start.mp3",
        "background_image": "assets/backround/arrow/arrow_back_1.jpg",
        "icon_star": "assets/icons/star.png",
        "icon_arrow": "assets/icons/arrow_right_button.png",
        "icon_mic": "assets/icons/micrafon.png",
      };
      _centerLetter = "R";
      _outerNodes = [];
    }

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

  String _cleanAudioPath(String path) {
    if (path.startsWith('assets/')) {
      return path.replaceFirst('assets/', '');
    }
    return path;
  }

  Future<void> _initPage() async {
    if (_config['start_voice'] != null) {
      await _playAudioAndWait(_config['start_voice']);
    }
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
          _isLoading = true;
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

      bool isMatched = _checkVoiceMatch(recognizedText, node.text);

      if (isMatched) {
        if (mounted) {
          setState(() {
            connectedLines[node.id] = node.id;
          });
        }

        // Level tugadimi yoki yo'qmi - shu yerda, bitta joyda hal qilamiz
        final bool isLastNode = connectedLines.length == _outerNodes.length;

        if (isLastNode) {
          // O'yin tugadi: loadingni yopamiz, keyin YAGONA marta
          // success ovozini chalib, dialogni ko'rsatamiz.
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isGameEnding = true;
            });
          }
          await _gameEnd();
          // _gameEnd() dialog ko'rsatib bo'lgach qaytadi (Navigator.pop
          // qilinganda sahifa allaqachon yopilgan bo'ladi), shuning uchun
          // pastdagi finally blokidagi setState'lar mounted tekshiruvi bilan
          // xavfsiz.
          return;
        } else {
          _showSnackbar("Barakalla! To'g'ri topildi.", Colors.green);
          await _audioPlayer.play(AssetSource('sound/success.mp3'));
        }
      } else {
        _handleWrongAnswer();
      }
    } catch (e) {
      debugPrint("STT Xatolik: $e");
      _handleWrongAnswer();
    } finally {
      if (mounted && !_isGameEnding) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _checkVoiceMatch(String recognizedText, String targetText) {
    String cleanRecognized = recognizedText.toLowerCase().replaceAll(
      RegExp(r"[^a-z']"),
      "",
    );
    String cleanTarget = targetText.toLowerCase().replaceAll(
      RegExp(r"[^a-z']"),
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

  void _handleWrongAnswer() {
    _showSnackbar("Xato eshitildi, qayta urinib ko'ring!", Colors.red);
  }

  Future<void> _onNodeTapped(TargetNode node) async {
    if (_isRecording ||
        _isLoading ||
        _isGameEnding ||
        connectedLines.containsKey(node.id) ||
        _activeVoiceItemId != null) {
      return;
    }

    setState(() {
      _activeVoiceItemId = node.id;
    });

    await _audioPlayer.stop();
    await _playAudioAndWait(node.sound);
    await _startRecording();
    await Future.delayed(const Duration(seconds: 3));
    await _stopAndCheckRecording(node);

    if (mounted) {
      setState(() {
        _activeVoiceItemId = null;
      });
    }
  }

  Future<void> _gameEnd() async {
    final provider = context.read<LevelProvider>();

    // Success ovozi FAQAT shu yerda, bir marta chalinadi.
    await _audioPlayer.play(AssetSource('sound/success.mp3'));

    if (!mounted) return;

    // MUHIM: avval dialogni ko'rsatamiz, natijada u ekranni to'liq
    // qoplab turadi. Ball/level holatini o'zgartiruvchi provider
    // metodlari (notifyListeners) esa dialog ALLAQACHON ustida
    // turgan paytda chaqiriladi — shu bilan asosiy sahifaning oraliq
    // (hali qayta chizilmagan/asset xatoligiga uchragan) holati
    // foydalanuvchiga hech qachon ko'rinmaydi.
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GameSuccessDialog(
            earnedScore: 10,
            onContinue: () {
              provider.clearCurrentLevel(); // Xotirani tozalaymiz
              Navigator.pop(context);
              Navigator.pop(context); // Xaritaga qaytish
            },
          );
        },
      ),
    );

    // Dialog animatsiyasi ekranni to'liq qoplashi uchun bir freym kutamiz,
    // so'ng orqa fonda ball/level holatini yangilaymiz.
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    provider.addBall(10);
    provider.unlock(stars: 3);
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

    final totalBall = context.watch<LevelProvider>().ball;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF8FD8F0), // fallback fon rangi
          image: (_config['background_image'] is String)
              ? DecorationImage(
            image: AssetImage(_config['background_image'] as String),
            fit: BoxFit.fill,
            onError: (error, stackTrace) {
              debugPrint("Background image yuklanmadi: $error");
            },
          )
              : null,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: _buildHeader(totalBall),
              ),

              // Game Area
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 360.w,
                    height: 440.h,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final Offset centerPoint = Offset(
                          constraints.maxWidth / 2,
                          constraints.maxHeight / 2,
                        );

                        return Stack(
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
                                outerNodes: _outerNodes,
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
                                    text: _centerLetter, // JSON
                                    sizeText: 96.sp,
                                    textColor: const Color(0xFF4A90E2),
                                    strokeWidth: 8.w,
                                  ),
                                ),
                              ),
                            ),

                            // Inner Circles
                            ...List.generate(_outerNodes.length, (index) {
                              final pos = _calculatePosition(
                                centerPoint,
                                innerRadius,
                                _outerNodes[index].angle,
                              );
                              return Positioned(
                                left: pos.dx - 12.w,
                                top: pos.dy - 12.w,
                                width: 24.w,
                                height: 24.w,
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
                            ..._outerNodes.map((node) {
                              final pos = _calculatePosition(
                                centerPoint,
                                outerRadius,
                                node.angle,
                              );
                              final bool isConnected = connectedLines
                                  .containsKey(node.id);

                              return Positioned(
                                left: pos.dx - 40.w,
                                top: pos.dy - 40.w,
                                width: 80.w,
                                height: 80.w,
                                child: GestureDetector(
                                  onTap: () => _onNodeTapped(node),
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
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
                                backgroundColor: Colors.white,
                                backgroundImage: const AssetImage(
                                  "assets/icons/circle.png",
                                ),
                                onBackgroundImageError: (_, __) {},
                                child: (_config['icon_mic'] is String)
                                    ? Image.asset(
                                  _config['icon_mic'] as String,
                                  width: 24.w,
                                  height: 32.h,
                                  color: _isRecording
                                      ? _colorAnim.value
                                      : null,
                                  // Asset topilmasa ham, xuddi shu
                                  // o'lchamdagi zaxira ikonka
                                  // ko'rsatiladi — layout hech qachon
                                  // "qulab tushmaydi".
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.mic,
                                      size: 28.sp,
                                      color: _isRecording
                                          ? (_colorAnim.value ??
                                          Colors.green)
                                          : const Color(0xFF4A90E2),
                                    );
                                  },
                                )
                                    : Icon(
                                  Icons.mic,
                                  size: 28.sp,
                                  color: _isRecording
                                      ? (_colorAnim.value ??
                                      Colors.green)
                                      : const Color(0xFF4A90E2),
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

  Widget _buildHeader(int currentBall) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              child: (_config['icon_arrow'] is String)
                  ? Image.asset(
                _config['icon_arrow'] as String,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white),
              )
                  : const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: (_config['icon_star'] is String)
                    ? Image.asset(
                  _config['icon_star'] as String,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.star, color: Colors.orange),
                )
                    : const Icon(Icons.star, color: Colors.orange),
              ),
              SizedBox(width: 8.w),
              CustomTextWidget(text: currentBall.toString(), sizeText: 32.sp),
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