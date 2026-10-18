import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

typedef OnDetections =
    void Function(List<Map<String, dynamic>> results, Size imageSize);

class YoloCameraWidget extends StatefulWidget {
  const YoloCameraWidget({
    super.key,
    required this.modelPath,
    this.useGpu = true,
    this.intervalMs = 450,
    this.confidenceThreshold = 0.25,
    required this.onDetections,
  });

  final String modelPath;
  final bool useGpu;
  final int intervalMs;
  final double confidenceThreshold;
  final OnDetections onDetections;

  @override
  State<YoloCameraWidget> createState() => _YoloCameraWidgetState();
}

class _YoloCameraWidgetState extends State<YoloCameraWidget> {
  final YOLOViewController _controller = YOLOViewController();

  @override
  Widget build(BuildContext context) {
    return YOLOView(
      modelPath: widget.modelPath,
      task: YOLOTask.detect,
      useGpu: widget.useGpu,
      confidenceThreshold: widget.confidenceThreshold,
      controller: _controller,
      showNativeUI: false,
      lensFacing: LensFacing.front,
      streamingConfig: YOLOStreamingConfig.custom(
        includeDetections: true,
        throttleInterval: Duration(milliseconds: widget.intervalMs),
      ),
      // Bo'sh natija ham yuboriladi: "kadrda hech narsa yo'q" holatini
      // CameraPage bilishi kerak, aks holda ushlab turish vaqti uzilishlar
      // orqali ham davom etib ketadi.
      onResult: (results) {
        if (!mounted) return;

        final mappedResults = results.map((r) {
          final rect = r.boundingBox;

          return {
            'box': [rect.left, rect.top, rect.right, rect.bottom],
            'tag': r.className,
            'class': r.className,
            'score': r.confidence,
          };
        }).toList();

        final size = MediaQuery.of(context).size;
        widget.onDetections(mappedResults, size);
      },
    );
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }
}
