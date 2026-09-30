import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DebugPanel extends StatelessWidget {
  final bool isVideoInitialized;
  final bool isVideoError;
  final VideoPlayerController? videoController;
  final Map<String, dynamic>? currentBest;
  final List<Map<String, dynamic>> lastDetections;

  const DebugPanel({
    super.key,
    required this.isVideoInitialized,
    required this.isVideoError,
    required this.videoController,
    required this.currentBest,
    required this.lastDetections,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 90,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.withValues(alpha: 0.5), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video status
            _statusDot(
              isVideoInitialized ? Colors.green : Colors.orange,
              isVideoInitialized ? "📹" : "⏳",
            ),

            const SizedBox(height: 3),

            // Error indicator
            if (isVideoError) _statusDot(Colors.red, "⚠️"),

            // Playing status
            if (videoController != null && isVideoInitialized) ...[
              const SizedBox(height: 3),
              _statusDot(
                videoController!.value.isPlaying ? Colors.green : Colors.grey,
                videoController!.value.isPlaying ? "▶️" : "⏸️",
              ),
            ],

            const SizedBox(height: 3),

            // Detections count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: lastDetections.isEmpty
                    ? Colors.grey.withValues(alpha: 0.3)
                    : Colors.cyan.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                "${lastDetections.length}",
                style: TextStyle(
                  color: lastDetections.isEmpty ? Colors.grey : Colors.cyan,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(Color color, String emoji) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: 10.sp))),
    );
  }
}
