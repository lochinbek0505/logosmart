import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PuzzleGameWidget extends StatefulWidget {
  const PuzzleGameWidget({super.key});

  @override
  State<PuzzleGameWidget> createState() => _PuzzleGameWidgetState();
}

class _PuzzleGameWidgetState extends State<PuzzleGameWidget> {
  bool isLeftMerged = false;
  bool isRightMerged = false;

  final String puzzleImage = 'assets/game/puzzle_game/puzzle.png';

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Rasm eni (180.w) va uning o'ng/chap paddinglari (8.0 + 8.0 = 16.0)
    final double pieceWidth = 180.w + 16.0;

    // Ekranda qolgan jami bo'sh joyni 3 ta teng qismga bo'lamiz (chap, o'rta, o'ng)
    final double remainingSpace = screenWidth - (pieceWidth * 2);
    final double equalGap = remainingSpace > 0 ? remainingSpace / 3 : 0;

    // Y o'qi (Vertikal) joylashuvlar
    final double topUnmerged = 200.h;
    final double topMerged = 160.h;

    final double bottomUnmerged = 420.h;
    final double bottomMerged = 270.h;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Puzzle Game"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // ================= CHAP TOMON =================

          // 1. Pastki chap rasm
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: equalGap, // Chapdan aniq hisoblangan joy
            top: isLeftMerged ? bottomMerged : bottomUnmerged,
            child: _buildPuzzlePiece(
              color: Colors.green,
              onTap: () {
                setState(() {
                  isLeftMerged = !isLeftMerged;
                });
              },
            ),
          ),

          // 2. Yuqori chap rasm
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: equalGap, // Chapdan aniq hisoblangan joy
            top: isLeftMerged ? topMerged : topUnmerged,
            child: _buildPuzzlePiece(
              color: Colors.red,
              onTap: () {
                setState(() {
                  isLeftMerged = !isLeftMerged;
                });
              },
            ),
          ),

          // ================= O'NG TOMON =================

          // 3. Pastki o'ng rasm
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            right: equalGap, // O'ngdan aniq hisoblangan joy
            top: isRightMerged ? bottomMerged : bottomUnmerged,
            child: _buildPuzzlePiece(
              color: Colors.orange,
              onTap: () {
                setState(() {
                  isRightMerged = !isRightMerged;
                });
              },
            ),
          ),

          // 4. Yuqori o'ng rasm
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            right: equalGap, // O'ngdan aniq hisoblangan joy
            top: isRightMerged ? topMerged : topUnmerged,
            child: _buildPuzzlePiece(
              color: Colors.blue,
              onTap: () {
                setState(() {
                  isRightMerged = !isRightMerged;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzlePiece({
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Image.asset(
          puzzleImage,
          width: 180.w,
          height: 180.h,
          color: color,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}