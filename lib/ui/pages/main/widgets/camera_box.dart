import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logosmart/ui/widgets/AICamera.dart';

import '../widgets/SuccessGifPlaceholder.dart';

class CameraBox extends StatelessWidget {
  final Size size;
  final bool cameraActive;
  final Key camKey;
  final String modelPath;
  final String labelsPath;
  final Function(List<Map<String, dynamic>>, Size) onDetections;

  const CameraBox({
    super.key,
    required this.size,
    required this.cameraActive,
    required this.camKey,
    required this.modelPath,
    required this.labelsPath,
    required this.onDetections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.6,
      height: size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xff20B9E8), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff20B9E8).withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: cameraActive
            ? AICamera(
                key: camKey,
                modelPath: modelPath,
                labelsPath: labelsPath,
                useGpu: true,
                numThreads: 2,
                lensDirection: CameraLensDirection.front,
                // intervalMs: 400,
                iouThreshold: 0.45,
                confThreshold: 0.35,
                classThreshold: 0.5,
                onDetections: onDetections,
              )
            : const SuccessGifPlaceholder(),
      ),
    );
  }
}
