import 'dart:async';
import 'dart:convert'; // JSON o'qish uchun

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../main/widgets/custom_text_widget.dart';
import '../alphabet_map/provider/level_provider.dart';
import '../widgets/game_success_dialog.dart';

class PuzzlePieceData {
  final String id;
  final int pairId;
  final Color color;
  final bool isTop;
  String currentSide;
  final String image;
  final String sound;

  PuzzlePieceData({
    required this.id,
    required this.pairId,
    required this.color,
    required this.isTop,
    required this.currentSide,
    required this.image,
    required this.sound,
  });

  factory PuzzlePieceData.fromJson(Map<String, dynamic> json) {
    return PuzzlePieceData(
      id: json['id'],
      pairId: json['pairId'],
      color: Color(int.parse(json['color'])),
      isTop: json['isTop'],
      currentSide: json['side'],
      image: json['image'],
      sound: json['sound'],
    );
  }
}

// O'yin bosqichlari
enum GamePhase { starting, idle, checking, error, resolvingMatch }

class PuzzleGameWidget extends StatefulWidget {
  const PuzzleGameWidget({super.key});

  @override
  State<PuzzleGameWidget> createState() => _PuzzleGameWidgetState();
}

class _PuzzleGameWidgetState extends State<PuzzleGameWidget> {
  // JSON dan keladigan sozlamalar
  late Map<String, dynamic> _config;

  List<PuzzlePieceData> pieces = [];

  final AudioPlayer _audioPlayer = AudioPlayer();

  PuzzlePieceData? selectedTop;
  PuzzlePieceData? selectedBottom;

  List<int> matchedPairIds = [];
  GamePhase _phase = GamePhase.starting;

  bool _showCorrectAnim = false;
  bool _showIncorrectAnim = false;

  int get _totalPairs => pieces.where((p) => p.isTop).length;

  @override
  void initState() {
    super.initState();
    _initLevelConfig();
    _playStartSequence();
  }

  void _initLevelConfig() {
    final currentLevel = context.read<LevelProvider>().currentLevelData;

    if (currentLevel != null && currentLevel.game != null) {
      _config = jsonDecode(currentLevel.game!.jsonConfig);

      // JSON ichidagi 'pieces' array'ни ob'ektlar ro'yxatiga o'tkazish
      List dynamicPieces = _config['pieces'] ?? [];
      pieces = dynamicPieces.map((p) => PuzzlePieceData.fromJson(p)).toList();

    } else {
      // Fallback: Xavfsizlik uchun default qiymatlar
      _config = {
        "start_voice": "assets/sound/puzzle_game/puzzle_start_1.mp3",
        "success_sound": "assets/sound/success.mp3",
        "error_sound": "assets/sound/diagnostic_error.mp3",
        "background_image": "assets/backround/puzzle_game/puzzle_back_4.jpg",
        "icon_arrow": "assets/icons/arrow_right_button.png",
        "icon_star": "assets/icons/star.png",
        "puzzle_frame": "assets/game/puzzle_game/puzzle.png",
        "correct_anim": "assets/animation/correct.json",
        "incorrect_anim": "assets/animation/xato.json",
      };

      pieces = [
        PuzzlePieceData(id: "t1", pairId: 1, color: const Color(0xFFFFFFFF), isTop: true, currentSide: "left", image: "assets/game/puzzle_game/puzzle_1_game_3.png", sound: "assets/sound/puzzle_game/ari.mp3"),
        PuzzlePieceData(id: "t2", pairId: 2, color: const Color(0xFFFFFFFF), isTop: true, currentSide: "right", image: "assets/game/puzzle_game/puzzle_1_game_4.png", sound: "assets/sound/puzzle_game/daraxt.mp3"),
        PuzzlePieceData(id: "b1", pairId: 2, color: const Color(0xFFFFFFFF), isTop: false, currentSide: "left", image: "assets/game/puzzle_game/puzzle_1_game_1.png", sound: "assets/sound/puzzle_game/daraxtlar.mp3"),
        PuzzlePieceData(id: "b2", pairId: 1, color: const Color(0xFFFFFFFF), isTop: false, currentSide: "right", image: "assets/game/puzzle_game/puzzle_1_game_2.png", sound: "assets/sound/puzzle_game/arilar.mp3"),
      ];
    }
  }

  String _cleanAudioPath(String path) {
    if (path.startsWith('assets/')) {
      return path.replaceFirst('assets/', '');
    }
    return path;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playStartSequence() async {
    if (_config['start_voice'] != null) {
      await _playAudioAndWait(_config['start_voice']);
    }
    if (mounted) {
      setState(() {
        _phase = GamePhase.idle;
      });
    }
  }

  void _onPieceTap(PuzzlePieceData piece) async {
    if (_phase != GamePhase.idle || matchedPairIds.contains(piece.pairId)) {
      return;
    }

    setState(() {
      if (piece.isTop) {
        selectedTop = selectedTop == piece ? null : piece;
      } else {
        selectedBottom = selectedBottom == piece ? null : piece;
      }
    });

    await _playAudioAndWait(piece.sound);

    if (selectedTop != null && selectedBottom != null) {
      _checkMatch();
    }
  }

  Future<void> _playAudioAndWait(String path) async {
    final completer = Completer<void>();
    StreamSubscription<void>? subscription;

    subscription = _audioPlayer.onPlayerComplete.listen((_) {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await _audioPlayer.play(AssetSource(_cleanAudioPath(path)));
    } catch (e) {
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  Future<void> _checkMatch() async {
    setState(() {
      _phase = GamePhase.checking;
    });

    // Qismlar vertikal birlashishini kutamiz
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // === TO'G'RI TOPILDI ===
    if (selectedTop!.pairId == selectedBottom!.pairId) {
      setState(() {
        _phase = GamePhase.resolvingMatch;
        _showCorrectAnim = true;
      });

      // To'g'ri topilgani uchun qo'shimcha ball beramiz (ixtiyoriy)
      context.read<LevelProvider>().addBall(5);

      await Future.wait([
        _playAudioAndWait(_config['success_sound']),
        Future.delayed(const Duration(milliseconds: 1100)),
      ]);

      if (!mounted) return;

      setState(() {
        _showCorrectAnim = false;
        matchedPairIds.add(selectedTop!.pairId);

        // Tanlangan ustun qaysi tomonda ekanini topamiz
        String targetSide = selectedTop!.currentSide;
        String oppositeSide = targetSide == 'left' ? 'right' : 'left';

        selectedTop!.currentSide = targetSide;
        selectedBottom!.currentSide = targetSide;

        // Qolgan topilmagan qismlarni ikkinchi ustunga o'tkazamiz
        for (var p in pieces) {
          if (!matchedPairIds.contains(p.pairId)) {
            p.currentSide = oppositeSide;
          }
        }

        selectedTop = null;
        selectedBottom = null;
        _phase = GamePhase.idle;
      });

      _maybeShowGameFinishedDialog();
    }
    // === XATO TOPILDI ===
    else {
      setState(() {
        _phase = GamePhase.error;
        _showIncorrectAnim = true;
      });

      await Future.wait([
        _playAudioAndWait(_config['error_sound']),
        Future.delayed(const Duration(milliseconds: 1100)),
      ]);

      if (!mounted) return;

      setState(() {
        _showIncorrectAnim = false;
        selectedTop = null;
        selectedBottom = null;
        _phase = GamePhase.idle;
      });
    }
  }

  void _maybeShowGameFinishedDialog() {
    if (matchedPairIds.length >= _totalPairs) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _gameEnd();
      });
    }
  }

  void _gameEnd() async {
    // PROVIDER ORQALI YAKUNIY BALL QO'SHISH VA LEVEL OCHISH
    final provider = context.read<LevelProvider>();
    provider.addBall(10);
    provider.unlock(stars: 3);

    await _audioPlayer.play(AssetSource(_cleanAudioPath(_config['success_sound'])));

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double pieceWidth = 180.w + 16.0;

    final double remainingSpace = screenWidth - (pieceWidth * 2);
    final double equalGap = remainingSpace > 0 ? remainingSpace / 3 : 0;

    // X va Y koordinatalari
    final double leftColumnX = equalGap;
    final double rightColumnX = screenWidth - equalGap - pieceWidth;

    final double topUnmergedY = 200.h;
    final double bottomUnmergedY = 420.h;

    final double topMergedY = 255.h;
    final double bottomMergedY = 365.h;

    // PROVIDER BALL
    final totalBall = context.watch<LevelProvider>().ball;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_config['background_image']), // JSON
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 0,
              right: 0,
              child: _buildHeader(totalBall),
            ),

            ...pieces.map((piece) {
              return _buildAnimatedPiece(
                piece: piece,
                leftColumnX: leftColumnX,
                rightColumnX: rightColumnX,
                topUnmergedY: topUnmergedY,
                bottomUnmergedY: bottomUnmergedY,
                topMergedY: topMergedY,
                bottomMergedY: bottomMergedY,
              );
            }),

            // === To'g'ri va xato lottie animatsiyalari ===
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showCorrectAnim ? 1.0 : 0.0,
                child: Center(
                  child: _showCorrectAnim
                      ? Lottie.asset(
                    _config['correct_anim'], // JSON
                    width: 250.w,
                    height: 250.h,
                    repeat: false,
                  )
                      : SizedBox(width: 400.w, height: 400.h),
                ),
              ),
            ),

            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showIncorrectAnim ? 1.0 : 0.0,
                child: Center(
                  child: _showIncorrectAnim
                      ? Lottie.asset(
                    _config['incorrect_anim'], // JSON
                    width: 250.w,
                    height: 250.h,
                    repeat: false,
                  )
                      : SizedBox(width: 400.w, height: 400.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPiece({
    required PuzzlePieceData piece,
    required double leftColumnX,
    required double rightColumnX,
    required double topUnmergedY,
    required double bottomUnmergedY,
    required double topMergedY,
    required double bottomMergedY,
  }) {
    final bool isSelected = piece == selectedTop || piece == selectedBottom;
    final bool isMatched = matchedPairIds.contains(piece.pairId);
    final bool isCheckingPhase =
        _phase == GamePhase.checking ||
            _phase == GamePhase.resolvingMatch ||
            _phase == GamePhase.error;

    final bool isOtherFade = isCheckingPhase && !isSelected && !isMatched;

    double currentScale = 1.0;
    double currentRotation = 0.0;

    if (isSelected) {
      if (_phase == GamePhase.idle) {
        currentScale = 1.08;
      } else if (_phase == GamePhase.checking) {
        currentScale = 1.0;
      } else if (_phase == GamePhase.resolvingMatch) {
        currentScale = 1.1;
      } else if (_phase == GamePhase.error) {
        currentScale = 1.0;
        currentRotation = piece.isTop ? -0.05 : 0.05;
      }
    }

    double targetX;
    if (isSelected && isCheckingPhase) {
      targetX = selectedTop!.currentSide == 'left' ? leftColumnX : rightColumnX;
    } else {
      targetX = piece.currentSide == 'left' ? leftColumnX : rightColumnX;
    }

    double targetY;
    if ((isSelected && isCheckingPhase) || isMatched) {
      targetY = piece.isTop ? topMergedY : bottomMergedY;
    } else {
      targetY = piece.isTop ? topUnmergedY : bottomUnmergedY;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      left: targetX,
      top: targetY,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isOtherFade ? 0.3 : 1.0,
        child: GestureDetector(
          onTap: () => _onPieceTap(piece),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 400),
            curve: Curves.bounceOut,
            scale: currentScale,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: currentRotation,
              child: Container(
                width: 180.w,
                height: 180.h,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_config['puzzle_frame']), // JSON
                    fit: BoxFit.contain,
                  ),
                ),
                child: Image.asset(piece.image, scale: 8.w),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int currentBall) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                context.read<LevelProvider>().clearCurrentLevel();
                Navigator.of(context).pop();
              },
              child: Image.asset(
                _config['icon_arrow'], // JSON
                width: 48.w,
                height: 48.h,
                fit: BoxFit.fill,
              ),
            ),
            Row(
              children: [
                Image.asset(_config['icon_star'], width: 40.w, height: 40.h), // JSON
                SizedBox(width: 8.w),
                CustomTextWidget(text: currentBall.toString(), sizeText: 32.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}