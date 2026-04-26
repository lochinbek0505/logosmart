import 'dart:math' as math;
import 'package:flutter/material.dart';

class YoloV8TFLiteDecoder {
  /// Model config
  static const int inputSize = 640;
  static const int numClasses = 3; // ogiz, tish, lab
  static const int numChannels = 4 + numClasses; // 7
  static const int numCandidates = 8400;

  /// Thresholdlar (ehtiyotkor defaultlar)
  final double confThreshold;
  final double iouThreshold;

  /// Label tartibi model exportdagi class tartibiga mos bo'lishi shart
  final List<String> labels;

  const YoloV8TFLiteDecoder({
    this.confThreshold = 0.35,
    this.iouThreshold = 0.45,
    this.labels = const ['ogiz', 'tish', 'lab'],
  });

  /// rawOutput kutilgan format:
  /// output[0] => [7][8400] yoki flatten bo'lsa [58800]
  ///
  /// imageSize = kamera preview/input frame o'lchami (UI dagi ko'rsatish size emas, real frame size)
  /// letterboxScale, padX, padY = preprocessda ishlatilgan qiymatlar
  ///   newX = (x - padX) / scale
  ///   newY = (y - padY) / scale
  List<Map<String, dynamic>> decode({
    required dynamic rawOutput,
    required Size imageSize,
    required double letterboxScale,
    required double padX,
    required double padY,
  }) {
    final List<List<double>> t = _toChannelMajor(rawOutput); // [7][8400]
    final List<_Det> candidates = [];

    for (int i = 0; i < numCandidates; i++) {
      final double cx = t[0][i];
      final double cy = t[1][i];
      final double w = t[2][i];
      final double h = t[3][i];

      // class max
      int bestClass = -1;
      double bestScore = -1.0;
      for (int c = 0; c < numClasses; c++) {
        final s = t[4 + c][i];
        if (s > bestScore) {
          bestScore = s;
          bestClass = c;
        }
      }

      if (bestClass < 0) continue;
      if (bestScore < confThreshold) continue;

      // xywh (640x640 letterbox space) -> xyxy
      double left = cx - w / 2;
      double top = cy - h / 2;
      double right = cx + w / 2;
      double bottom = cy + h / 2;

      // de-letterbox -> original image space
      left = (left - padX) / letterboxScale;
      right = (right - padX) / letterboxScale;
      top = (top - padY) / letterboxScale;
      bottom = (bottom - padY) / letterboxScale;

      // clamp
      left = left.clamp(0.0, imageSize.width);
      right = right.clamp(0.0, imageSize.width);
      top = top.clamp(0.0, imageSize.height);
      bottom = bottom.clamp(0.0, imageSize.height);

      if (right <= left || bottom <= top) continue;

      candidates.add(
        _Det(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          score: bestScore,
          classId: bestClass,
          label: labels[bestClass],
        ),
      );
    }

    // NMS per class (barqarorroq)
    final List<_Det> finalDets = [];
    for (int c = 0; c < numClasses; c++) {
      final classDets = candidates.where((d) => d.classId == c).toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      finalDets.addAll(_nms(classDets, iouThreshold));
    }

    // Sizning mavjud tizimga mos format
    return finalDets.map((d) {
      return <String, dynamic>{
        'label': d.label,
        'confidence': d.score,
        // _extractConfidence fallback'i uchun 5-element ham qo'shildi:
        'box': [d.left, d.top, d.right, d.bottom, d.score],
      };
    }).toList();
  }

  /// outputni [7][8400] ko'rinishga keltiradi
  List<List<double>> _toChannelMajor(dynamic rawOutput) {
    // 1) [1,7,8400]
    if (rawOutput is List &&
        rawOutput.isNotEmpty &&
        rawOutput[0] is List &&
        (rawOutput[0] as List).length == numChannels) {
      final ch = rawOutput[0] as List;
      return List.generate(numChannels, (c) {
        final row = ch[c] as List;
        return row.map((e) => (e as num).toDouble()).toList();
      });
    }

    // 2) [7,8400]
    if (rawOutput is List &&
        rawOutput.length == numChannels &&
        rawOutput[0] is List) {
      return List.generate(numChannels, (c) {
        final row = rawOutput[c] as List;
        return row.map((e) => (e as num).toDouble()).toList();
      });
    }

    // 3) flatten [58800]
    if (rawOutput is List && rawOutput.length == numChannels * numCandidates) {
      final flat = rawOutput.map((e) => (e as num).toDouble()).toList();
      return List.generate(numChannels, (c) {
        final start = c * numCandidates;
        return flat.sublist(start, start + numCandidates);
      });
    }

    throw StateError(
      'Unsupported output format. Expected [1,7,8400] or [7,8400] or [58800]',
    );
  }

  List<_Det> _nms(List<_Det> dets, double iouThr) {
    final kept = <_Det>[];
    final removed = List<bool>.filled(dets.length, false);

    for (int i = 0; i < dets.length; i++) {
      if (removed[i]) continue;
      final a = dets[i];
      kept.add(a);

      for (int j = i + 1; j < dets.length; j++) {
        if (removed[j]) continue;
        final b = dets[j];
        if (_iou(a, b) > iouThr) {
          removed[j] = true;
        }
      }
    }
    return kept;
  }

  double _iou(_Det a, _Det b) {
    final x1 = math.max(a.left, b.left);
    final y1 = math.max(a.top, b.top);
    final x2 = math.min(a.right, b.right);
    final y2 = math.min(a.bottom, b.bottom);

    final iw = math.max(0.0, x2 - x1);
    final ih = math.max(0.0, y2 - y1);
    final inter = iw * ih;

    final areaA = (a.right - a.left) * (a.bottom - a.top);
    final areaB = (b.right - b.left) * (b.bottom - b.top);
    final union = areaA + areaB - inter;
    if (union <= 0) return 0.0;
    return inter / union;
  }
}

class _Det {
  final double left, top, right, bottom, score;
  final int classId;
  final String label;

  _Det({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.score,
    required this.classId,
    required this.label,
  });
}