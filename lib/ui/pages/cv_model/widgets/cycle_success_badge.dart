import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Har bir cycle tugaganda chiqadigan "Barakalla" animatsiyasi.
/// Bosilganda qo'shimcha sakraydi va yulduzchalar qayta otiladi.
class CycleSuccessBadge extends StatefulWidget {
  final int completedCycles;
  final int totalCycles;

  const CycleSuccessBadge({
    super.key,
    required this.completedCycles,
    required this.totalCycles,
  });

  @override
  State<CycleSuccessBadge> createState() => _CycleSuccessBadgeState();
}

class _CycleSuccessBadgeState extends State<CycleSuccessBadge>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _burstController;
  late final AnimationController _shineController;
  late final AnimationController _tapController;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _particles = List.generate(14, (i) {
      return _Particle(
        angle: (2 * pi / 14) * i + random.nextDouble() * 0.4,
        distance: 90 + random.nextDouble() * 60,
        size: 14 + random.nextDouble() * 12,
        icon: i.isEven ? '⭐' : '✨',
      );
    });

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _enterController.dispose();
    _burstController.dispose();
    _shineController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onTap() {
    _tapController.forward(from: 0);
    _burstController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final enter = CurvedAnimation(
      parent: _enterController,
      curve: Curves.elasticOut,
    );

    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Atrofga otiladigan yulduzchalar
          AnimatedBuilder(
            animation: _burstController,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(_burstController.value);
              final opacity = (1 - _burstController.value).clamp(0.0, 1.0);
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: _particles.map((p) {
                  return Transform.translate(
                    offset: Offset(
                      cos(p.angle) * p.distance.w * t,
                      sin(p.angle) * p.distance.w * t,
                    ),
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: t * pi,
                        child: Text(
                          p.icon,
                          style: TextStyle(fontSize: p.size.sp),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Asosiy badge
          ScaleTransition(
            scale: enter,
            child: AnimatedBuilder(
              animation: _tapController,
              builder: (context, child) {
                final bounce = sin(_tapController.value * pi) * 0.15;
                return Transform.scale(scale: 1 + bounce, child: child);
              },
              child: _buildBadge(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff00C9A7), Color(0xff20B9E8), Color(0xff845EF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff20B9E8).withValues(alpha: 0.55),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Barakalla! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                _buildProgressStars(),
              ],
            ),
            // Yaltirab o'tadigan nur
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _shineController,
                  builder: (context, _) {
                    final x = -1.5 + _shineController.value * 3;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(x - 0.3, -1),
                          end: Alignment(x + 0.3, 1),
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nechta cycle bajarilganini yulduzchalar bilan ko'rsatadi
  Widget _buildProgressStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.totalCycles, (i) {
        final filled = i < widget.completedCycles;
        final isNew = i == widget.completedCycles - 1;
        final star = Icon(
          Icons.star_rounded,
          size: 26.sp,
          color: filled ? Colors.yellow : Colors.white.withValues(alpha: 0.35),
        );
        if (!isNew) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: star,
          );
        }
        // Yangi yulduz aylanib, kattalashib chiqadi
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.elasticOut,
            builder: (context, v, child) => Transform.rotate(
              angle: (1 - v) * pi,
              child: Transform.scale(scale: 0.3 + 0.7 * v, child: child),
            ),
            child: star,
          ),
        );
      }),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final String icon;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.icon,
  });
}
