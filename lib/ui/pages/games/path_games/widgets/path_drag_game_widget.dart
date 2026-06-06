import 'package:flutter/material.dart';

/// Bitta nuqtani ifodalovchi model
class PathPoint {
  final double x;
  final double y;

  PathPoint({required this.x, required this.y});

  factory PathPoint.fromJson(Map<String, dynamic> json) {
    return PathPoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}

/// Yo'l qismlari (segmentlar) uchun umumiy interfeys
abstract class PathSegment {
  void addToPath(Path path, Size size);

  factory PathSegment.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'line') {
      return LineSegment.fromJson(json);
    } else {
      return CurveSegment.fromJson(json);
    }
  }
}

/// To'g'ri chiziq segmenti
class LineSegment implements PathSegment {
  final PathPoint endPoint;

  LineSegment({required this.endPoint});

  factory LineSegment.fromJson(Map<String, dynamic> json) {
    return LineSegment(
      endPoint: PathPoint.fromJson(json['endPoint']),
    );
  }

  @override
  void addToPath(Path path, Size size) {
    path.lineTo(size.width * endPoint.x, size.height * endPoint.y);
  }
}

/// Egri chiziq (Cubic Bezier) segmenti
class CurveSegment implements PathSegment {
  final PathPoint cp1;
  final PathPoint cp2;
  final PathPoint endPoint;

  CurveSegment({
    required this.cp1,
    required this.cp2,
    required this.endPoint,
  });

  factory CurveSegment.fromJson(Map<String, dynamic> json) {
    return CurveSegment(
      cp1: PathPoint.fromJson(json['cp1']),
      cp2: PathPoint.fromJson(json['cp2']),
      endPoint: PathPoint.fromJson(json['endPoint']),
    );
  }

  @override
  void addToPath(Path path, Size size) {
    path.cubicTo(
      size.width * cp1.x, size.height * cp1.y,
      size.width * cp2.x, size.height * cp2.y,
      size.width * endPoint.x, size.height * endPoint.y,
    );
  }
}

/// Umumiy yo'l konfiguratsiyasi
class PathConfig {
  final PathPoint startPoint;
  final List<PathSegment> segments;

  PathConfig({required this.startPoint, required this.segments});

  factory PathConfig.fromJson(Map<String, dynamic> json) {
    var segmentsList = json['segments'] as List;
    return PathConfig(
      startPoint: PathPoint.fromJson(json['startPoint']),
      segments: segmentsList.map((i) => PathSegment.fromJson(i)).toList(),
    );
  }

  /// O'lcham kelganda Path obyektini shakllantirib beruvchi funksiya
  Path buildPath(Size size) {
    final path = Path();
    path.moveTo(size.width * startPoint.x, size.height * startPoint.y);

    for (var segment in segments) {
      segment.addToPath(path, size);
    }
    return path;
  }
}