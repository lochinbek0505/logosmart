import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../models/target_node_model.dart';

class ArrowLinePainter extends CustomPainter {
  final Offset centerPoint;
  final double innerRadius;
  final double outerRadius;
  final List<TargetNode> outerNodes;
  final Map<int, int> connectedLines;
  final int? activeInnerNode;
  final Offset? currentDragPosition;

  ArrowLinePainter({
    required this.centerPoint,
    required this.innerRadius,
    required this.outerRadius,
    required this.outerNodes,
    required this.connectedLines,
    this.activeInnerNode,
    this.currentDragPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3.w
      ..style = PaintingStyle.stroke;

    // 1. Ulanib bo'lingan (tayyor) chiziqlarni chizish
    connectedLines.forEach((innerIndex, outerIndex) {
      final startPos = _getPos(innerRadius, outerNodes[innerIndex].angle);
      // Strelka uchi harfga kirib ketmasligi uchun radiusni biroz kamaytiramiz (- 25.w)
      final endPos = _getPos(outerRadius - 25.w, outerNodes[outerIndex].angle);
      _drawDashedArrow(canvas, startPos, endPos, linePaint);
    });

    // 2. Hozir faol tortilayotgan chiziqni chizish
    if (activeInnerNode != null && currentDragPosition != null) {
      final startPos = _getPos(innerRadius, outerNodes[activeInnerNode!].angle);
      final Paint activeLinePaint = Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 4.w
        ..style = PaintingStyle.stroke;
      _drawDashedArrow(canvas, startPos, currentDragPosition!, activeLinePaint);
    }
  }

  Offset _getPos(double radius, double angleDegree) {
    final double radian = angleDegree * (pi / 180);
    return Offset(
      centerPoint.dx + radius * cos(radian),
      centerPoint.dy + radius * sin(radian),
    );
  }

  // Uzlukli (Dashed) chiziq va oxirida strelka chizish funksiyasi
  void _drawDashedArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double distance = (end - start).distance;
    final double dashWidth = 8.w;
    final double dashSpace = 6.w;
    double currentDistance = 0.0;

    final double dx = (end.dx - start.dx) / distance;
    final double dy = (end.dy - start.dy) / distance;

    // Uzlukli chiziq
    while (currentDistance < distance - 10.w) { // Strelka uchiga joy qoldiramiz
      final double endDistance = (currentDistance + dashWidth < distance - 10.w)
          ? currentDistance + dashWidth
          : distance - 10.w;

      canvas.drawLine(
        Offset(start.dx + dx * currentDistance, start.dy + dy * currentDistance),
        Offset(start.dx + dx * endDistance, start.dy + dy * endDistance),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }

    // Strelka uchi (Arrowhead) chizish
    final double angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final double arrowLength = 12.w;

    final Path arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowLength * cos(angle - pi / 6), end.dy - arrowLength * sin(angle - pi / 6))
      ..lineTo(end.dx - arrowLength * cos(angle + pi / 6), end.dy - arrowLength * sin(angle + pi / 6))
      ..close();

    canvas.drawPath(arrowPath, Paint()..color = paint.color ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
