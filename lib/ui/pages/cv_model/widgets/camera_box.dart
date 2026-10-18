import 'package:flutter/material.dart';
import 'package:logosmart/ui/widgets/yolo_camera_widget.dart';

/// Kamera + YOLO aniqlash. Ramka, soya va o'lcham CameraPage dagi
/// konteynerda — bu widget faqat unga berilgan joyni to'ldiradi.
class CameraBox extends StatelessWidget {
  final String modelPath;

  /// Inference'lar orasidagi eng kam vaqt (ms)
  final int intervalMs;

  /// Plagin bundan past ishonchli natijalarni umuman yubormaydi
  final double confidenceThreshold;

  final OnDetections onDetections;

  const CameraBox({
    super.key,
    required this.modelPath,
    required this.onDetections,
    this.intervalMs = 200,
    this.confidenceThreshold = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: YoloCameraWidget(
        modelPath: modelPath,
        useGpu: false,
        intervalMs: intervalMs,
        confidenceThreshold: confidenceThreshold,
        onDetections: onDetections,
      ),
    );
  }
}
