import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/path_drag_game_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

import 'dashed_path_painter.dart';

class IafpWidget extends StatefulWidget {
  final PathConfig pathConfig;
  final String image;
  final String sound;
  final bool isLocked;
  final VoidCallback? onFinished;

  const IafpWidget({
    super.key,
    required this.pathConfig,
    required this.image,
    required this.sound,
    this.isLocked = false,
    this.onFinished,
  });

  @override
  State<IafpWidget> createState() => _IafpWidgetState();
}

class _IafpWidgetState extends State<IafpWidget> {
  double _progress = 0.0;
  Path? _path;
  PathMetric? _pathMetric;
  Offset _currentPosition = Offset.zero;
  Size? _widgetSize;
  bool _hasCalledFinished = false;

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

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isLocked || _pathMetric == null) return;

    final currentTangent = _pathMetric!.getTangentForOffset(
      _pathMetric!.length * _progress,
    );

    if (currentTangent == null) return;

    double dotProduct = (details.delta.dx * currentTangent.vector.dx) +
        (details.delta.dy * currentTangent.vector.dy);

    double deltaProgress = dotProduct / _pathMetric!.length;

    setState(() {
      _progress += deltaProgress * 1.5;
      _progress = _progress.clamp(0.0, 1.0);

      final newTangent = _pathMetric!.getTangentForOffset(
        _pathMetric!.length * _progress,
      );
      if (newTangent != null) {
        _currentPosition = newTangent.position;
      }

      // 2. Oxiriga 90% (0.90) yetganini tekshirish
      if (_progress >= 0.90 && !_hasCalledFinished) {
        _hasCalledFinished = true;
        if (widget.onFinished != null) {
          widget.onFinished!();
        }
      } else if (_progress < 0.90) {
        _hasCalledFinished = false;
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
            if (_path != null)
              CustomPaint(
                size: size,
                painter: DashedPathPainter(path: _path!),
              ),
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
                              widget.sound,
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