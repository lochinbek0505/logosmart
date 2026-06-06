import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/path_drag_game_widget.dart'; // Sizning path_config faylingiz
import 'package:logosmart/ui/theme/app_colors.dart';

import 'dashed_path_painter.dart';

class IafpWidget extends StatefulWidget {
  final PathConfig pathConfig;

  const IafpWidget({super.key, required this.pathConfig});

  @override
  State<IafpWidget> createState() => _IafpWidgetState();
}

class _IafpWidgetState extends State<IafpWidget> {
  double _progress = 0.0;
  Path? _path;
  PathMetric? _pathMetric;
  Offset _currentPosition = Offset.zero;
  Size? _widgetSize;

  void _initPath(Size size) {
    final path = widget.pathConfig.buildPath(size);

    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      _pathMetric = metrics.first;

      final tangent = _pathMetric!.getTangentForOffset(
        _pathMetric!.length * _progress,
      );
      if (tangent != null) {
        _currentPosition = tangent.position;
      }
    }
    _path = path;
    _widgetSize = size;
  }

  // Yaxshilangan barmoq harakati mantig'i
  void _onPanUpdate(DragUpdateDetails details) {
    if (_pathMetric == null) return;

    // 1. Qahramonning hozirgi turgan nuqtasidagi yo'nalish vektorini (tangent) olamiz
    final currentTangent = _pathMetric!.getTangentForOffset(
      _pathMetric!.length * _progress,
    );

    if (currentTangent == null) return;

    // 2. Skalyar ko'paytma (Dot Product):
    // Barmoq siljishi (delta) ni yo'lning shu joydagi yo'nalishiga (vector) ko'paytiramiz.
    // Agar barmoq yo'l bo'ylab tortilsa natija musbat (oldinga), teskari tortilsa manfiy (orqaga) bo'ladi.
    double dotProduct = (details.delta.dx * currentTangent.vector.dx) +
        (details.delta.dy * currentTangent.vector.dy);

    // 3. Olingan masofani yo'lning umumiy uzunligiga bo'lib, progress delta'sini topamiz
    double deltaProgress = dotProduct / _pathMetric!.length;

    setState(() {
      // 1.5 - bu harakatlanish sezgirligi (tezligi). O'zingizga qarab o'zgartirishingiz mumkin.
      _progress += deltaProgress * 1.5;
      _progress = _progress.clamp(0.0, 1.0); // Obyekt yo'ldan chiqib ketmasligi uchun

      // 4. Progress o'zgargandan keyingi yangi joylashuvni yangilaymiz
      final newTangent = _pathMetric!.getTangentForOffset(
        _pathMetric!.length * _progress,
      );
      if (newTangent != null) {
        _currentPosition = newTangent.position;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_path == null || _widgetSize != size) {
          _initPath(size);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Chiziq
            if (_path != null)
              CustomPaint(
                size: size,
                painter: DashedPathPainter(path: _path!),
              ),

            // 2. Harakatlanuvchi qahramon
            Positioned(
              left: _currentPosition.dx - 45.w,
              top: _currentPosition.dy - 60.h,
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (_progress < 0.1)
                      Positioned(
                        top: -70.h,
                        left: -15.w,
                        child: Container(
                          width: 108.w,
                          height: 67.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/game/game_cloud.png"),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 5.0.h, left: 3.w),
                            child: Text(
                              "Rrr-Rrr",
                              style: TextStyle(
                                color: AppColors.sky_blue_900,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Image.asset(
                      "assets/game/tiger.png",
                      width: 110.w,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}