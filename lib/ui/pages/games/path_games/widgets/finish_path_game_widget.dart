import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/path_games/widgets/path_drag_game_widget.dart'; // O'zingizning path_config faylingiz
import 'package:logosmart/ui/theme/app_colors.dart';

import 'dashed_path_painter.dart';

class FinishPathGameWidget extends StatefulWidget {
  final PathConfig pathConfig;
  final VoidCallback? onComplete; // O'yin tugaganda parent'ga xabar berish uchun

  const FinishPathGameWidget({
    super.key,
    required this.pathConfig,
    this.onComplete,
  });

  @override
  State<FinishPathGameWidget> createState() => _FinishPathGameWidgetState();
}

class _FinishPathGameWidgetState extends State<FinishPathGameWidget> {
  double _progress = 0.0;
  Path? _path;
  PathMetric? _pathMetric;

  Offset _currentPosition = Offset.zero;
  Offset _endPosition = Offset.zero; // Uy turadigan oxirgi manzil

  Size? _widgetSize;
  bool _isSuccess = false; // Manzilga yetib borganligini tekshirish uchun

  void _initPath(Size size) {
    final path = widget.pathConfig.buildPath(size);

    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      _pathMetric = metrics.first;

      // Boshlang'ich nuqtani o'rnatish
      final startTangent = _pathMetric!.getTangentForOffset(0);
      if (startTangent != null) {
        _currentPosition = startTangent.position;
      }

      // Oxirgi nuqtani (Uy joylashuvini) o'rnatish
      final endTangent = _pathMetric!.getTangentForOffset(_pathMetric!.length);
      if (endTangent != null) {
        _endPosition = endTangent.position;
      }
    }
    _path = path;
    _widgetSize = size;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_pathMetric == null || _isSuccess) return;

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
    });
  }

  // Barmoq qo'yib yuborilganda nima bo'lishini hal qiluvchi funksiya
  void _onPanEnd(DragEndDetails details) {
    if (_isSuccess) return;

    setState(() {
      // Agar qahramon yo'lning 90% yoki undan ko'pini bosib o'tgan bo'lsa -> G'alaba
      if (_progress >= 0.9) {
        _progress = 1.0;
        _isSuccess = true;
        final endTangent = _pathMetric!.getTangentForOffset(_pathMetric!.length);
        if (endTangent != null) {
          _currentPosition = endTangent.position;
        }

        // Parent widgetga o'yin tugaganini bildirish (masalan: keyingi levelga o'tish)
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      }
      // Aks holda (yarmida qolib ketsa) -> Boshiga qaytib qoladi
      else {
        _progress = 0.0;
        final startTangent = _pathMetric!.getTangentForOffset(0);
        if (startTangent != null) {
          _currentPosition = startTangent.position;
        }
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

            if (_path != null)
              Positioned(
                left: _endPosition.dx - 80.w, // Uyning o'lchamiga qarab markazlashtiring
                top: _endPosition.dy - 100.h,
                child: Image.asset(
                  "assets/game/house.png", // <--- Uy rasmini kiriting
                  height: 120.h,
                  fit: BoxFit.contain,
                ),
              ),

            // 3. Agar g'alaba bo'lsa (Correct/Tick belgisi chiqib turadi)
            if (_isSuccess)
              Positioned(
                left: _endPosition.dx - 120.w,
                top: _endPosition.dy - 60.h,
                child: Image.asset(
                  "assets/game/game_correct.png", // <--- Yashil ptichka rasmini kiriting
                  width: 80.w,
                  fit: BoxFit.contain,
                ),
              ),

            // 4. Harakatlanuvchi qahramon (Faqat g'alaba qozonmagan bo'lsa ko'rinadi)
            if (!_isSuccess)
              Positioned(
                left: _currentPosition.dx - 45.w,
                top: _currentPosition.dy - 90.h,
                child: GestureDetector(
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd, // Barmoq qo'yib yuborilishini kuzatish
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
                        "assets/game/dog.png", // <--- Yo'lbars o'rniga Kuchukcha rasmi (tiger.png qolsa ham bo'ladi)
                        width: 90.w,
                        height: 120.h,
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