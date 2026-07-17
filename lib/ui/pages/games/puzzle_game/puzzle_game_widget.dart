import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../main/widgets/custom_text_widget.dart';
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

const String _backImage = "assets/backround/puzzle_game/puzzle_back_4.jpg";
const String _backBtn = "assets/icons/arrow_right_button.png";

// Lottie animatsiya fayllari
const String _correctAnim = "assets/animation/correct.json";
const String _incorrectAnim = "assets/animation/xato.json";

class _PuzzleGameWidgetState extends State<PuzzleGameWidget> {
  List<PuzzlePieceData> pieces = [
    PuzzlePieceData(
      id: "t1",
      pairId: 1,
      color: const Color(0xFFFFFFFF),
      isTop: true,
      currentSide: "left",
      image: "assets/game/puzzle_game/puzzle_1_game_3.png",
      sound: "assets/sound/puzzle_game/ari.mp3",
    ),
    PuzzlePieceData(
      id: "t2",
      pairId: 2,
      color: const Color(0xFFFFFFFF),
      isTop: true,
      currentSide: "right",
      image: "assets/game/puzzle_game/puzzle_1_game_4.png",
      sound: "assets/sound/puzzle_game/daraxt.mp3",
    ),
    PuzzlePieceData(
      id: "b1",
      pairId: 2,
      color: const Color(0xFFFFFFFF),
      isTop: false,
      currentSide: "left",
      image: "assets/game/puzzle_game/puzzle_1_game_1.png",
      sound: "assets/sound/puzzle_game/daraxtlar.mp3",
    ),
    PuzzlePieceData(
      id: "b2",
      pairId: 1,
      color: const Color(0xFFFFFFFF),
      isTop: false,
      currentSide: "right",
      image: "assets/game/puzzle_game/puzzle_1_game_2.png",
      sound: "assets/sound/puzzle_game/arilar.mp3",
    ),
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  PuzzlePieceData? selectedTop;
  PuzzlePieceData? selectedBottom;

  List<int> matchedPairIds = [];
  GamePhase _phase = GamePhase.starting;

  bool _showCorrectAnim = false;
  bool _showIncorrectAnim = false;

  final String puzzleImage = 'assets/game/puzzle_game/puzzle.png';

  int get _totalPairs => pieces.where((p) => p.isTop).length;

  @override
  void initState() {
    super.initState();
    _playStartSequence();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playStartSequence() async {
    await _playAudioAndWait("assets/sound/puzzle_game/puzzle_start_1.mp3");
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

    String cleanPath = path.replaceFirst('assets/', '');

    subscription = _audioPlayer.onPlayerComplete.listen((_) {
      subscription?.cancel();
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await _audioPlayer.play(AssetSource(cleanPath));
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

      await Future.wait([
        _playAudioAndWait("assets/sound/success.mp3"),
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

        // Qolgan topilmagan qismlarni ikkinchi ustunga o'tkazamiz (grid buzilmasligi uchun)
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
        _playAudioAndWait("assets/sound/diagnostic_error.mp3"),
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

    // Tepa va pastki qism aynan o'rtada vertikal birlashishi uchun Y masofalari
    // Original kodingizdagi farq 110.h edi (270 - 160). Shu farqni saqlaymiz:
    final double topMergedY = 255.h;
    final double bottomMergedY = 365.h;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_backImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 0,
              right: 0,
              child: _buildHeader(),
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

            // === To'g'ri va xato lottie animatsiyalari markazda kattalashgan holatda ===
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showCorrectAnim ? 1.0 : 0.0,
                child: Center(
                  child: _showCorrectAnim
                      ? Lottie.asset(
                          _correctAnim,
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
                          _incorrectAnim,
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

    // Animatsiya holatlari (Hajmi o'zgarmasdan turadi)
    if (isSelected) {
      if (_phase == GamePhase.idle) {
        currentScale = 1.08;
      } else if (_phase == GamePhase.checking) {
        currentScale = 1.0; // Tekshirilayotganda asl holatiga qaytadi
      } else if (_phase == GamePhase.resolvingMatch) {
        currentScale = 1.1; // Topilganda sal kattalashib "pop" effekti beradi
      } else if (_phase == GamePhase.error) {
        currentScale = 1.0;
        currentRotation = piece.isTop ? -0.05 : 0.05; // Xatoda qiyshayadi
      }
    }

    // --- JOYLASHTIRISH KOORDINATALARINI HISBLASH ---

    // 1. X O'qi (Yonma-yon emas, aynan chap yoki o'ng ustunni tanlash)
    double targetX;
    if (isSelected && isCheckingPhase) {
      // Tanlangan qismlar har doim tepadagi qism joylashgan ustunga kelib birlashadi
      targetX = selectedTop!.currentSide == 'left' ? leftColumnX : rightColumnX;
    } else {
      // Topilgan yoki tinch holatda o'z ustunida (gridda) turadi
      targetX = piece.currentSide == 'left' ? leftColumnX : rightColumnX;
    }

    // 2. Y O'qi (Tepa-past, ya'ni Vertikal birlashish)
    double targetY;
    if ((isSelected && isCheckingPhase) || isMatched) {
      // Birlashayotgan va Topib bo'linganlar vertikal yopishgan holda turadi
      targetY = piece.isTop ? topMergedY : bottomMergedY;
    } else {
      // Hali topilmaganlar o'z joyida tarqoq turadi
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
                    image: AssetImage(puzzleImage),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
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
                CustomTextWidget(text: "10", sizeText: 32.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
