import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../main/widgets/custom_text_widget.dart';

// 1. JSON Modeli
class PuzzlePieceData {
  final String id;
  final int pairId;
  final Color color;
  final bool isTop;
  String currentSide; // 'left' yoki 'right'
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
enum GamePhase { idle, checking, error, resolvingMatch }

class PuzzleGameWidget extends StatefulWidget {
  const PuzzleGameWidget({super.key});

  @override
  State<PuzzleGameWidget> createState() => _PuzzleGameWidgetState();
}

const String _backImage = "assets/backround/puzzle_game/puzzle_back_3.jpg";
const String _backBtn = "assets/icons/arrow_right_button.png";

class _PuzzleGameWidgetState extends State<PuzzleGameWidget> {
  List<PuzzlePieceData> pieces = [
    PuzzlePieceData(
      id: "t1",
      pairId: 1,
      color: Color(0xFFFFFFFF),
      isTop: true,
      currentSide: "left",
      image: "assets/game/puzzle_game/puzzle_1_game_1.png",
      sound: "assets/sound/puzzle_game/daraxtlar.mp3",
    ),
    PuzzlePieceData(
      id: "t2",
      pairId: 2,
      color: Color(0xFFFFFFFF),
      isTop: true,
      currentSide: "right",
      image: "assets/game/puzzle_game/puzzle_1_game_4.png",
      sound: "assets/sound/puzzle_game/daraxt.mp3",
    ),
    PuzzlePieceData(
      id: "b1",
      pairId: 2,
      color: Color(0xFFFFFFFF),
      isTop: false,
      currentSide: "left",
      image: "assets/game/puzzle_game/puzzle_1_game_3.png",
      sound: "assets/sound/puzzle_game/ari.mp3",
    ),
    PuzzlePieceData(
      id: "b2",
      pairId: 1,
      color: Color(0xFFFFFFFF),
      isTop: false,
      currentSide: "right",
      image: "assets/game/puzzle_game/puzzle_1_game_2.png",
      sound: "assets/sound/puzzle_game/arilar.mp3",
    ),
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();

  PuzzlePieceData? selectedTop;
  PuzzlePieceData? selectedBottom;

  List<int> matchedPairIds = []; // Topilgan juftliklar ID lari
  GamePhase _phase = GamePhase.idle;

  final String puzzleImage = 'assets/game/puzzle_game/puzzle.png';

  @override
  void initState() {
    super.initState();
  }

  // Pazzl bosilganda ishlaydi
  void _onPieceTap(PuzzlePieceData piece)async {
    // Agar animatsiya ketayotgan bo'lsa yoki allaqachon topilgan bo'lsa, teginishni bekor qilish
    if (_phase != GamePhase.idle || matchedPairIds.contains(piece.pairId))
      return;
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

    await _audioPlayer.play(AssetSource(cleanPath));
    return completer.future;
  }
  Future<void> _checkMatch() async {
    setState(() {
      _phase = GamePhase.checking; // Markazga uchishni boshlash
    });

    // Markazga borib birlashishi uchun kutish
    // await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // === TO'G'RI TOPILDI ===
    if (selectedTop!.pairId == selectedBottom!.pairId) {
      await _playAudioAndWait("assets/sound/success.mp3");
      setState(() {
        _phase = GamePhase.resolvingMatch;
      });

      // Markazda qisqa vaqt birlashib turishini ko'rsatish
      // await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      setState(() {
        matchedPairIds.add(selectedTop!.pairId);

        // Tanlangan ustunni aniqlaymiz (masalan, chap tomon bo'lsa)
        String targetSide = selectedTop!.currentSide;
        String oppositeSide = targetSide == 'left' ? 'right' : 'left';

        // 1. Topilgan juftliklarni tanlangan tomonga yuboramiz
        selectedTop!.currentSide = targetSide;
        selectedBottom!.currentSide = targetSide;

        // 2. Qolgan ochiq juftliklarni qarama-qarshi tomonga suramiz
        for (var p in pieces) {
          if (!matchedPairIds.contains(p.pairId)) {
            p.currentSide = oppositeSide;
          }
        }

        // Holatni tozalash
        selectedTop = null;
        selectedBottom = null;
        _phase = GamePhase.idle;
      });
    }

    else {

      setState(() {
        _phase = GamePhase.error;
      });

      // Xato yozuvi turish vaqti
      await _playAudioAndWait("assets/sound/diagnostic_error.mp3");
      if (!mounted) return;

      setState(() {
        // Joylariga qaytarish
        selectedTop = null;
        selectedBottom = null;
        _phase = GamePhase.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double pieceWidth = 180.w + 16.0;

    final double remainingSpace = screenWidth - (pieceWidth * 2);
    final double equalGap = remainingSpace > 0 ? remainingSpace / 3 : 0;

    final double leftColumnX = equalGap;
    final double rightColumnX = screenWidth - equalGap - pieceWidth;
    final double centerColumnX = (screenWidth - pieceWidth) / 2;

    final double topUnmergedY = 200.h;
    final double topMergedY = 160.h;
    final double bottomUnmergedY = 420.h;
    final double bottomMergedY = 270.h;
    final double mergedGapY = bottomMergedY - topMergedY;

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
            // 1. HEADER (Tepada joylashadi)
            Positioned(
              top:
                  MediaQuery.of(context).padding.top +
                  10.h, // Status bardan pastroqda
              left: 0,
              right: 0,
              child: _buildHeader(),
            ),

            // Pazzl qismlari
            ...pieces.map((piece) {
              return _buildAnimatedPiece(
                piece: piece,
                leftColumnX: leftColumnX,
                rightColumnX: rightColumnX,
                centerColumnX: centerColumnX,
                topUnmergedY: topUnmergedY,
                topMergedY: topMergedY,
                bottomUnmergedY: bottomUnmergedY,
                bottomMergedY: bottomMergedY,
                mergedGapY: mergedGapY,
              );
            }),

            // 2. MIKROFON (Pastki markazda joylashadi)
            Positioned(
              bottom: 24.h, // Pastdan biroz teparoqda
              left: 0,
              right: 0,
              child: Center(
                child: CircleAvatar(
                  radius: 40.r,
                  backgroundImage: const AssetImage("assets/icons/circle.png"),
                  child: Image.asset(
                    "assets/icons/micrafon.png",
                    width: 24.w,
                    height: 32.h,
                  ),
                ),
              ),
            ),

            // XATOLIK XABARI ANIMATSIYASI
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              top: _phase == GamePhase.error
                  ? (topMergedY + bottomMergedY) / 2
                  : (topMergedY + bottomMergedY) / 2 + 50.h,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _phase == GamePhase.error ? 1.0 : 0.0,
                child: const Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Chip(
                      backgroundColor: Colors.redAccent,
                      label: Text(
                        "Xato juftlik!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
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
    required double centerColumnX,
    required double topUnmergedY,
    required double topMergedY,
    required double bottomUnmergedY,
    required double bottomMergedY,
    required double mergedGapY,
  }) {
    final bool isSelected = piece == selectedTop || piece == selectedBottom;
    final bool isMatched = matchedPairIds.contains(piece.pairId);
    final bool isChecking =
        _phase == GamePhase.checking || _phase == GamePhase.error;

    // Tanlanmagan va topilmagan qismlarni xiralashtirish
    final bool isOtherFade = isChecking && !isSelected && !isMatched;

    // X O'qi hisobi
    double targetX = piece.currentSide == 'left' ? leftColumnX : rightColumnX;
    if (isSelected && isChecking) {
      targetX = centerColumnX; // Tanlanganlar markazga keladi
    }

    // Y O'qi hisobi
    double targetY;
    if (isSelected && isChecking) {
      // Markazga kelganda birlashadi
      targetY = piece.isTop ? topMergedY : bottomMergedY;
    } else if (isMatched) {
      // Topilgan bo'lsa, tepadagi qism va pastdagi qism birlashgan holatda joylashadi
      targetY = piece.isTop ? topUnmergedY : topUnmergedY + mergedGapY;
    } else {
      // Odatiy (ochiq) joylashuv
      targetY = piece.isTop ? topUnmergedY : bottomUnmergedY;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      left: targetX,
      top: targetY,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isOtherFade ? 0.2 : 1.0,
        child: GestureDetector(
          onTap: () => _onPieceTap(piece),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            // Pazzl tanlanib juftini kutayotganda ozgina kattalashadi
            transform: Matrix4.identity()
              ..scale(isSelected && _phase == GamePhase.idle ? 1.08 : 1.0),
            transformAlignment: Alignment.center,
            child: Container(
              width: 180.w,
              height: 180.h,
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
    );
  }

  // Image.asset(
  // puzzleImage,
  // width: 180.w,
  // height: 180.h,
  // // color: piece.color,
  // fit: BoxFit.contain,
  // ),
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
