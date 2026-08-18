import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GameVideoBox extends StatelessWidget {
  final Size size;
  final bool isVideoInitialized;
  final bool isVideoError;
  final String? currentVideoPath;
  final VideoPlayerController? videoController;
  final VoidCallback onRetry;

  const GameVideoBox({
    super.key,
    required this.size,
    required this.isVideoInitialized,
    required this.isVideoError,
    required this.currentVideoPath,
    required this.videoController,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xff20B9E8), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: _buildVideoContent(),
      ),
    );
  }

  Widget _buildVideoContent() {
    // 1. XATOLIK holati
    if (isVideoError) {
      return Container(
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Video yuklashda xatolik',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              currentVideoPath ?? 'Video yo\'li topilmadi',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Qayta yuklash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff20B9E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. YUKLANMOQDA holati
    if (!isVideoInitialized || videoController == null) {
      return Container(
        color: Colors.black12,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff20B9E8)),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Video yuklanmoqda...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // 3. VIDEO TAYYOR (Play/Pause, Replay va Fullscreen tugmalari bilan)
    return ValueListenableBuilder(
      valueListenable: videoController!,
      builder: (context, VideoPlayerValue value, child) {
        final isPlaying = value.isPlaying;
        final isFinished = value.position >= value.duration && value.duration.inMilliseconds > 0;

        return GestureDetector(
          // Ekran ustiga bosganda play/pause bo'lishi
          onTap: () {
            if (isFinished) {
              videoController!.seekTo(Duration.zero);
              videoController!.play();
            } else {
              isPlaying ? videoController!.pause() : videoController!.play();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- VIDEO (Bo'sh joy qoldirmasdan to'liq qoplash) ---
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: value.size.width == 0 ? 1 : value.size.width,
                  height: value.size.height == 0 ? 1 : value.size.height,
                  child: VideoPlayer(videoController!),
                ),
              ),

              // --- QORAYTIRILGAN FON (Faqat pauza bo'lganda) ---
              if (!isPlaying)
                Container(color: Colors.black26),

              // --- MARKAZDAGI PLAY/PAUSE TUGMASI ---
              Center(
                child: AnimatedOpacity(
                  opacity: isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      isFinished ? Icons.replay : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),

              // --- PASTKI BOSHQARUV PANELI ---
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Replay (Boshidan boshlash) tugmasi
                      IconButton(
                        icon: const Icon(Icons.replay, color: Colors.white, size: 28),
                        onPressed: () {
                          videoController!.seekTo(Duration.zero);
                          videoController!.play();
                        },
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}