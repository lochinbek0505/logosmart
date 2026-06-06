import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class DashedPathPainter extends CustomPainter {
  final Path path;
  DashedPathPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    Path dashPath = Path();
    const double dashWidth = 15.0;
    const double dashSpace = 8.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);

    // Strelka qismi
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final lastMetric = metrics.last;
      final tangent = lastMetric.getTangentForOffset(lastMetric.length);
      if (tangent != null) {
        _drawArrow(canvas, paint, tangent.position, tangent.vector);
      }
    }
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset position, Offset direction) {
    final double angle = math.atan2(direction.dy, direction.dx);
    const double arrowLength = 20.0;
    const double arrowAngle = math.pi / 5;

    Path arrowPath = Path();
    arrowPath.moveTo(position.dx, position.dy);
    arrowPath.lineTo(
      position.dx - arrowLength * math.cos(angle - arrowAngle),
      position.dy - arrowLength * math.sin(angle - arrowAngle),
    );
    arrowPath.moveTo(position.dx, position.dy);
    arrowPath.lineTo(
      position.dx - arrowLength * math.cos(angle + arrowAngle),
      position.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}