import 'dart:async';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logosmart/ui/widgets/AICamera.dart';

class AICameraTestPage extends StatefulWidget {
  const AICameraTestPage({super.key});

  @override
  State<AICameraTestPage> createState() => _AICameraTestPageState();
}

class _AICameraTestPageState extends State<AICameraTestPage> {

  var sq=["o'ng","chap","o'ng","chap"];

  final String _modelPath = 'assets/models/model3.tflite';
  final String _labelsPath = 'assets/models/labels.txt';

  List<Detection> _detections = [];
  ui.Size _imageSize = ui.Size.zero;
  double _minConfidence = 0.5;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Camera Test'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Kamera
          AICamera(
            modelPath: _modelPath,
            labelsPath: _labelsPath,
            useGpu: true,
            numThreads: 2,
            lensDirection: CameraLensDirection.front,
            // intervalMs: 300,
            confThreshold: _minConfidence,
            iouThreshold: 0.45,
            onDetections: _onDetections,
            onError: (err) => print('Error: $err'),
            showLoadingIndicator: true,
          ),

          // Bounding boxes
          CustomPaint(
            painter: BoundingBoxPainter(
              detections: _detections,
              imageSize: _imageSize,
            ),
            child: Container(),
          ),

          // Natijalar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Topildi:  ${_detections.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: _detections.isEmpty
                        ? const Center(
                            child: Text(
                              'Hech narsa topilmadi',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _detections.length,
                            itemBuilder: (context, index) {
                              final det = _detections[index];
                              return Card(
                                color: Colors.grey.shade800,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: det.color,
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(
                                    det.tag.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Ishonch: ${(det.confidence * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: CircularProgressIndicator(
                                    value: det.confidence,
                                    backgroundColor: Colors.white24,
                                    valueColor: AlwaysStoppedAnimation(
                                      det.confidence > 0.7
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  String? checkEvenOdd(int number, {int durationSeconds = 5}) {
     int even = 0;
     int odd = 0;
     bool started = false;
     bool finished = false;

    // Birinchi chaqirilganda timer ishga tushadi
    if (!started) {
      started = true;

      Timer(Duration(seconds: durationSeconds), () {
        finished = true;
      });

    }

    // Vaqt tugamagan bo‘lsa sonni hisoblaymiz
    if (!finished) {
      if (number % 2 == 0) {
        even++;
      } else {
        odd++;
      }
    }

    // Agar vaqt tugagan bo‘lsa — natija qaytariladi
    if (finished) {
      if (even > odd) {
        return "Juft ko‘p ($even)";
      } else if (odd > even) {
        return "Toq ko‘p ($odd)";
      } else {
        return "Teng ($even / $odd)";
      }
    }

    // Hali vaqt tugamagan
    return null;
  }



  void _onDetections(List<Map<String, dynamic>> results, ui.Size imageSize) {
    setState(() {
      _detections = results.map((r) => Detection.fromMap(r)).toList();



      _imageSize = imageSize;
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Sozlamalar', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Minimal ishonch: ${(_minConfidence * 100).toInt()}%',
                style: const TextStyle(color: Colors.white),
              ),
              Slider(
                value: _minConfidence,
                min: 0.1,
                max: 0.9,
                divisions: 8,
                label: '${(_minConfidence * 100).toInt()}%',
                onChanged: (value) {
                  setDialogState(() => _minConfidence = value);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}


class Detection {
  final String tag;
  final double confidence;
  final double x1, y1, x2, y2;
  final Color color;

  Detection({
    required this.tag,
    required this.confidence,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.color,
  });

  factory Detection.fromMap(Map<String, dynamic> map) {
    final box = map['box'] as List<dynamic>;
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
    ];

    return Detection(
      tag: map['tag'] as String,
      confidence: (box[4] as num).toDouble(),
      x1: (box[0] as num).toDouble(),
      y1: (box[1] as num).toDouble(),
      x2: (box[2] as num).toDouble(),
      y2: (box[3] as num).toDouble(),
      color: colors[map['tag'].hashCode % colors.length],
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final ui.Size imageSize;

  BoundingBoxPainter({required this.detections, required this.imageSize});

  @override
  void paint(Canvas canvas, ui.Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final det in detections) {
      final rect = Rect.fromLTRB(
        det.x1 * scaleX,
        det.y1 * scaleY,
        det.x2 * scaleX,
        det.y2 * scaleY,
      );

      // Box
      final paint = Paint()
        ..color = det.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRect(rect, paint);

      // Fill
      final fillPaint = Paint()
        ..color = det.color.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      canvas.drawRect(rect, fillPaint);

      // Label
      final label = '${det.tag} ${(det.confidence * 100).toInt()}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRect = Rect.fromLTWH(
        rect.left,
        rect.top - textPainter.height - 8,
        textPainter.width + 12,
        textPainter.height + 8,
      );

      canvas.drawRect(labelRect, Paint()..color = det.color);
      textPainter.paint(
        canvas,
        Offset(rect.left + 6, rect.top - textPainter.height - 4),
      );
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) => true;
}
