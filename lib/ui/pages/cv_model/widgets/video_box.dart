import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBox extends StatelessWidget {
  final Size size;
  final bool isVideoInitialized;
  final bool isVideoError;
  final String? currentVideoPath;
  final VideoPlayerController? videoController;
  final VoidCallback onRetry;

  const VideoBox({
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
      width: size.width * 0.7,
      height: size.width * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xff20B9E8), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: const Offset(0, 4),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff20B9E8)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Video yuklanmoqda.. .',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    // 3. VIDEO TAYYOR
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: videoController!.value.aspectRatio,
            child: VideoPlayer(videoController!),
          ),
        ),
      ],
    );
  }
}
