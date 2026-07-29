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
    required this.onDetections,
  });

  final String modelPath;
  final bool useGpu;
  final int intervalMs;
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
      controller: _controller,
      showNativeUI: false,
      lensFacing: LensFacing.front,
      streamingConfig: YOLOStreamingConfig.custom(
        includeDetections: true,
        throttleInterval: Duration(milliseconds: widget.intervalMs),
      ),
      onResult: (results) {
        if (results == null || results.isEmpty) return;

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
