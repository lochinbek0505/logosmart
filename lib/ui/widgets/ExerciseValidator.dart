import 'dart:async';
import 'package:flutter/foundation.dart';

/// Mashqni tekshiruvchi - ma'lum vaqt davomida deteksiyalarni yig'adi
/// va kutilgan natija bilan solishtiradi
class ExerciseValidator {
  final String expectedLabel; // Kutilgan natija
  final int durationMs; // Tekshirish davomiyligi (millisekund)
  final double minConfidenceThreshold; // Minimal ishonch darajasi
  final int minSuccessfulDetections; // Minimal muvaffaqiyatli deteksiyalar soni
  final double successRate; // Muvaffaqiyat foizi (0.0 - 1.0)

  final List<_DetectionEntry> _detections = [];
  Timer? _validationTimer;
  Completer<ValidationResult>? _completer;
  DateTime? _startTime;
  bool _isRunning = false;

  ExerciseValidator({
    required this.expectedLabel,
    this.durationMs = 1000, // 1 sekund
    this.minConfidenceThreshold = 0.5,
    this.minSuccessfulDetections = 5,
    this.successRate = 0.7, // 70% to'g'ri bo'lishi kerak
  });

  /// Validatsiyani boshlash va natijani kutish
  Future<ValidationResult> startValidation() {
    if (_isRunning) {
      throw StateError('Validatsiya allaqachon ishlamoqda!');
    }

    _reset();
    _isRunning = true;
    _startTime = DateTime.now();
    _completer = Completer<ValidationResult>();

    debugPrint(
      '🎯 Validatsiya boshlandi: "$expectedLabel" | '
          'Davomiyligi: ${durationMs}ms | '
          'Min deteksiya: $minSuccessfulDetections',
    );

    // Timer - vaqt tugaganda natijani hisoblash
    _validationTimer = Timer(Duration(milliseconds: durationMs), () {
      _finishValidation();
    });

    return _completer!.future;
  }

  /// Deteksiyani qo'shish (validation davomida chaqiriladi)
  void addDetection(Map<String, dynamic>? detection) {
    if (!_isRunning || detection == null) {
      return;
    }

    final label = _extractLabel(detection);
    final confidence = _extractConfidence(detection);

    if (label.isEmpty || confidence < minConfidenceThreshold) {
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_startTime! ).inMilliseconds;

    _detections.add(_DetectionEntry(
      label: label,
      confidence: confidence,
      timestamp: elapsed,
    ));

    debugPrint(
      '📊 Deteksiya qo\'shildi: $label (${(confidence * 100).toStringAsFixed(1)}%) | '
          'Jami: ${_detections.length}',
    );
  }

  /// Bir nechta deteksiyalardan eng yaxshisini qo'shish
  void addBestDetection(List<Map<String, dynamic>> detections) {
    if (detections.isEmpty) return;

    Map<String, dynamic>? best;
    double bestConf = -1;

    for (final detection in detections) {
      final conf = _extractConfidence(detection);
      if (conf > bestConf) {
        bestConf = conf;
        best = detection;
      }
    }

    addDetection(best);
  }

  /// Validatsiyani tugatish va natijani hisoblash
  void _finishValidation() {
    if (! _isRunning) return;

    _isRunning = false;
    _validationTimer?.cancel();

    final result = _calculateResult();

    debugPrint(
      '✅ Validatsiya tugadi: ${result.isSuccess ? "MUVAFFAQIYATLI" : "MUVAFFAQIYATSIZ"} | '
          'To\'g\'ri: ${result.correctDetections}/${result.totalDetections} | '
          'Foiz: ${(result.accuracy * 100).toStringAsFixed(1)}%',
    );

    _completer?. complete(result);
  }

  /// Natijani hisoblash
  ValidationResult _calculateResult() {
    if (_detections.isEmpty) {
      return ValidationResult(
        isSuccess: false,
        expectedLabel: expectedLabel,
        totalDetections: 0,
        correctDetections: 0,
        incorrectDetections: 0,
        accuracy: 0.0,
        averageConfidence: 0.0,
        durationMs: durationMs,
        message: 'Hech qanday deteksiya topilmadi',
        detectionTimeline: [],
      );
    }

    int correctCount = 0;
    int incorrectCount = 0;
    double totalConfidence = 0.0;
    final List<DetectionPoint> timeline = [];

    for (final detection in _detections) {
      final isCorrect = detection.label. toLowerCase() ==
          expectedLabel.toLowerCase();

      if (isCorrect) {
        correctCount++;
        totalConfidence += detection. confidence;
      } else {
        incorrectCount++;
      }

      timeline.add(DetectionPoint(
        label: detection.label,
        confidence: detection.confidence,
        timestamp: detection.timestamp,
        isCorrect: isCorrect,
      ));
    }

    final totalDetections = _detections.length;
    final accuracy = totalDetections > 0 ? correctCount / totalDetections : 0.0;
    final avgConfidence = correctCount > 0 ? totalConfidence / correctCount : 0.0;

    // Muvaffaqiyat shartlari
    final hasEnoughDetections = totalDetections >= minSuccessfulDetections;
    final hasEnoughAccuracy = accuracy >= successRate;
    final isSuccess = hasEnoughDetections && hasEnoughAccuracy;

    String message;
    if (! hasEnoughDetections) {
      message = 'Kam deteksiya:  $totalDetections/$minSuccessfulDetections';
    } else if (!hasEnoughAccuracy) {
      message = 'Kam aniqlik: ${(accuracy * 100).toStringAsFixed(1)}%/${(successRate * 100).toStringAsFixed(1)}%';
    } else {
      message = 'Muvaffaqiyatli! ';
    }

    return ValidationResult(
      isSuccess: isSuccess,
      expectedLabel: expectedLabel,
      totalDetections:  totalDetections,
      correctDetections: correctCount,
      incorrectDetections: incorrectCount,
      accuracy: accuracy,
      averageConfidence: avgConfidence,
      durationMs: durationMs,
      message: message,
      detectionTimeline:  timeline,
    );
  }

  /// Ma'lumotlarni tozalash
  void _reset() {
    _detections.clear();
    _validationTimer?.cancel();
    _validationTimer = null;
    _completer = null;
    _startTime = null;
  }

  /// Validatsiyani bekor qilish
  void cancel() {
    if (_isRunning) {
      debugPrint('⚠️ Validatsiya bekor qilindi');
      _isRunning = false;
      _validationTimer?.cancel();

      if (_completer != null && !_completer!.isCompleted) {
        _completer!.complete(ValidationResult(
          isSuccess: false,
          expectedLabel: expectedLabel,
          totalDetections: _detections.length,
          correctDetections: 0,
          incorrectDetections: _detections.length,
          accuracy: 0.0,
          averageConfidence: 0.0,
          durationMs:  durationMs,
          message:  'Bekor qilindi',
          detectionTimeline:  [],
        ));
      }
    }
  }

  /// Validatsiya ishlamoqdami?
  bool get isRunning => _isRunning;

  /// Qolgan vaqt (millisekund)
  int?  get remainingTimeMs {
    if (!_isRunning || _startTime == null) return null;

    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
    final remaining = durationMs - elapsed;
    return remaining > 0 ? remaining :  0;
  }

  /// Hozirgi deteksiyalar soni
  int get currentDetectionCount => _detections. length;

  /// Label'ni ajratib olish
  String _extractLabel(Map<String, dynamic> detection) {
    final candidates = [
      detection['tag'],
      detection['label'],
      detection['className'],
      detection['cls'],
      detection['name'],
      detection['class'],
    ];

    for (final candidate in candidates) {
      if (candidate != null) return candidate.toString();
    }

    return '';
  }

  /// Confidence'ni ajratib olish
  double _extractConfidence(Map<String, dynamic> detection) {
    final candidates = [
      detection['confidence'],
      detection['score'],
      detection['conf'],
      if (detection['box'] is List && (detection['box'] as List).length > 4)
        (detection['box'] as List)[4],
    ];

    for (final candidate in candidates) {
      if (candidate is num) return candidate.toDouble();
    }

    return 0.0;
  }

  void dispose() {
    cancel();
    _reset();
  }
}

/// Validatsiya natijasi
class ValidationResult {
  /// Muvaffaqiyatlimi?
  final bool isSuccess;

  /// Kutilgan label
  final String expectedLabel;

  /// Jami deteksiyalar soni
  final int totalDetections;

  /// To'g'ri deteksiyalar soni
  final int correctDetections;

  /// Noto'g'ri deteksiyalar soni
  final int incorrectDetections;

  /// Aniqlik (0.0 - 1.0)
  final double accuracy;

  /// O'rtacha ishonch darajasi (faqat to'g'ri deteksiyalar uchun)
  final double averageConfidence;

  /// Davomiyligi (millisekund)
  final int durationMs;

  /// Xabar
  final String message;

  /// Deteksiyalar timeline'i
  final List<DetectionPoint> detectionTimeline;

  ValidationResult({
    required this.isSuccess,
    required this.expectedLabel,
    required this.totalDetections,
    required this. correctDetections,
    required this.incorrectDetections,
    required this.accuracy,
    required this.averageConfidence,
    required this.durationMs,
    required this.message,
    required this.detectionTimeline,
  });

  /// Batafsil ma'lumot
  String toDetailedString() {
    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 VALIDATSIYA NATIJASI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Holat: ${isSuccess ? '✅ MUVAFFAQIYATLI' :  '❌ MUVAFFAQIYATSIZ'}
Kutilgan:  $expectedLabel
Davomiyligi: ${durationMs}ms

📊 STATISTIKA:
  • Jami deteksiyalar: $totalDetections
  • To'g'ri:  $correctDetections
  • Noto'g'ri: $incorrectDetections
  • Aniqlik: ${(accuracy * 100).toStringAsFixed(1)}%
  • O'rtacha ishonch:  ${(averageConfidence * 100).toStringAsFixed(1)}%

💬 Xabar: $message
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }

  @override
  String toString() =>
      'ValidationResult(success:  $isSuccess, accuracy: ${(accuracy * 100).toStringAsFixed(1)}%)';
}

/// Bitta deteksiya nuqtasi (timeline uchun)
class DetectionPoint {
  final String label;
  final double confidence;
  final int timestamp; // millisekund
  final bool isCorrect;

  DetectionPoint({
    required this.label,
    required this.confidence,
    required this. timestamp,
    required this.isCorrect,
  });
}

/// Ichki deteksiya yozuvi
class _DetectionEntry {
  final String label;
  final double confidence;
  final int timestamp;

  _DetectionEntry({
    required this.label,
    required this.confidence,
    required this.timestamp,
  });
}