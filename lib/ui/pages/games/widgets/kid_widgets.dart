import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bolalarga mos animatsion UI bo'laklari: obuna taklifi dialogi va resurslarni
/// yuklash oynalarida ishlatiladi. Faqat APK ichidagi rasmlar (assets/icons)
/// ishlatiladi — serverdagi animatsiyalarga bog'liq emas.

/// Yumshoq "3D" tugma: doimiy sekin pulsatsiya, bosilganda ezilib qaytadi.
class KidBounceButton extends StatefulWidget {
  const KidBounceButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.colors = const [Color(0xFF33DCFF), Color(0xFF0096B5)],
    this.pulse = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final List<Color> colors;
  final bool pulse;

  @override
  State<KidBounceButton> createState() => _KidBounceButtonState();
}

class _KidBounceButtonState extends State<KidBounceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final shadow = Color.lerp(widget.colors.last, Colors.black, 0.25)!;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) => Transform.scale(
          scale: 1 + 0.035 * Curves.easeInOut.transform(_pulse.value),
          child: child,
        ),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedOpacity(
            opacity: enabled ? 1 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              margin: EdgeInsets.only(top: _pressed ? 4.h : 0),
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 22.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.colors,
                ),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: [
                  // Pastki "qalinlik" — tugma bosilganda yo'qoladi
                  BoxShadow(
                    color: shadow,
                    offset: Offset(0, _pressed ? 0 : 5.h),
                  ),
                  BoxShadow(
                    color: widget.colors.first.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    SizedBox(width: 10.w),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Qalin, yumaloq, harakatlanuvchi chiziqli ("konfet") progress bar.
/// [value] null bo'lsa — noaniq holat (bo'lak u yoqdan-bu yoqqa yuguradi).
class KidProgressBar extends StatefulWidget {
  const KidProgressBar({
    super.key,
    required this.value,
    this.colors = const [Color(0xFF54E2FF), Color(0xFF00C0E8)],
    this.trackColor,
    this.height,
  });

  final double? value;
  final List<Color> colors;
  final Color? trackColor;
  final double? height;

  @override
  State<KidProgressBar> createState() => _KidProgressBarState();
}

class _KidProgressBarState extends State<KidProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? 22.h;
    final track = widget.trackColor ?? Colors.white.withValues(alpha: 0.75);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: (widget.value ?? 0).clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size(double.infinity, h),
          painter: _CandyBarPainter(
            value: widget.value == null ? null : v,
            phase: _c.value,
            colors: widget.colors,
            track: track,
          ),
        ),
      ),
    );
  }
}

class _CandyBarPainter extends CustomPainter {
  _CandyBarPainter({
    required this.value,
    required this.phase,
    required this.colors,
    required this.track,
  });

  final double? value;
  final double phase;
  final List<Color> colors;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    final full = RRect.fromRectAndRadius(Offset.zero & size, r);

    // Ichki soya bilan trek
    canvas.drawRRect(full, Paint()..color = track);
    canvas.drawRRect(
      full.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black.withValues(alpha: 0.06),
    );

    // To'lgan qism (noaniq holatda — yuguruvchi bo'lak)
    double start = 0, end;
    if (value == null) {
      final seg = size.width * 0.32;
      final t = (math.sin(phase * 2 * math.pi) + 1) / 2;
      start = t * (size.width - seg);
      end = start + seg;
    } else {
      end = size.width * value!;
      if (end > 0 && end < size.height) end = size.height;
    }
    if (end <= start) return;

    final fillRect = Rect.fromLTRB(start, 0, end, size.height);
    final fill = RRect.fromRectAndRadius(fillRect, r);
    canvas.save();
    canvas.clipRRect(fill);
    canvas.drawRect(
      fillRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(fillRect),
    );

    // Harakatlanuvchi qiya chiziqlar
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.22);
    final w = size.height;
    final shift = phase * w * 2;
    for (double x = -w * 2 + shift; x < size.width + w; x += w * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + w, 0)
        ..lineTo(x + w * 1.8, 0)
        ..lineTo(x + w * 0.8, size.height)
        ..close();
      canvas.drawPath(path, stripe);
    }

    // Yaltiroq yuqori chiziq
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          start + size.height * 0.3,
          size.height * 0.16,
          math.max(0, fillRect.width - size.height * 0.6),
          size.height * 0.22,
        ),
        Radius.circular(size.height),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CandyBarPainter old) =>
      old.value != value || old.phase != phase;
}

/// Yuqoriga-pastga sekin "suzib" turadigan bola (biroz chayqaladi ham).
class KidFloating extends StatefulWidget {
  const KidFloating({
    super.key,
    required this.child,
    this.amplitude = 8,
    this.tilt = 0.04,
    this.duration = const Duration(milliseconds: 1800),
  });

  final Widget child;
  final double amplitude;
  final double tilt;
  final Duration duration;

  @override
  State<KidFloating> createState() => _KidFloatingState();
}

class _KidFloatingState extends State<KidFloating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final a = _c.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, math.sin(a) * widget.amplitude),
          child: Transform.rotate(
            angle: math.cos(a) * widget.tilt,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Vaqti-vaqti bilan "qimirlab" qo'yadigan bola (qulf, xato belgisi).
class KidWiggle extends StatefulWidget {
  const KidWiggle({super.key, required this.child});

  final Widget child;

  @override
  State<KidWiggle> createState() => _KidWiggleState();
}

class _KidWiggleState extends State<KidWiggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Siklning birinchi 30% ida tebranadi, qolganida tinch turadi
        final t = _c.value;
        final angle = t < 0.3
            ? math.sin(t / 0.3 * 4 * math.pi) * 0.22 * (1 - t / 0.3)
            : 0.0;
        return Transform.rotate(angle: angle, child: child);
      },
      child: widget.child,
    );
  }
}

/// Atrofida miltillab turadigan yulduzchalar ([positions] — Alignment'lar).
class KidTwinkleStars extends StatefulWidget {
  const KidTwinkleStars({super.key, required this.positions, this.size = 18});

  final List<Alignment> positions;
  final double size;

  @override
  State<KidTwinkleStars> createState() => _KidTwinkleStarsState();
}

class _KidTwinkleStarsState extends State<KidTwinkleStars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          children: [
            for (var i = 0; i < widget.positions.length; i++)
              Align(
                alignment: widget.positions[i],
                child: Builder(
                  builder: (_) {
                    final t =
                        (math.sin(
                              (_c.value + i / widget.positions.length) *
                                  2 *
                                  math.pi,
                            ) +
                            1) /
                        2;
                    final s = widget.size * (i.isEven ? 1 : 0.7);
                    return Opacity(
                      opacity: 0.35 + 0.65 * t,
                      child: Transform.rotate(
                        angle: t * 0.6,
                        child: Transform.scale(
                          scale: 0.6 + 0.5 * t,
                          child: Image.asset(
                            "assets/icons/star_orange.webp",
                            width: s,
                            height: s,
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
    );
  }
}

/// Osmon foni: gradient va sekin suzib o'tadigan bulutlar.
class KidSkyBackground extends StatefulWidget {
  const KidSkyBackground({super.key, required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  State<KidSkyBackground> createState() => _KidSkyBackgroundState();
}

class _KidSkyBackgroundState extends State<KidSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.dark
        ? const [Color(0xFF0B2A3A), Color(0xFF123F52), Color(0xFF1B5266)]
        : const [Color(0xFF7FDBFF), Color(0xFFB8F0FF), Color(0xFFF1FCFF)];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) => CustomPaint(
                  painter: _CloudsPainter(
                    phase: _c.value,
                    color: Colors.white.withValues(
                      alpha: widget.dark ? 0.08 : 0.85,
                    ),
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _CloudsPainter extends CustomPainter {
  _CloudsPainter({required this.phase, required this.color});

  final double phase;
  final Color color;

  // (balandlik ulushi, o'lcham, tezlik, boshlang'ich siljish)
  static const _clouds = [
    (0.08, 1.0, 1.0, 0.0),
    (0.22, 0.7, 1.6, 0.45),
    (0.70, 0.9, 1.2, 0.7),
    (0.86, 0.6, 2.0, 0.2),
    (0.45, 0.5, 2.4, 0.85),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final base = size.width * 0.28;
    for (final (y, scale, speed, offset) in _clouds) {
      final w = base * scale;
      final span = size.width + w * 2;
      final x = ((phase * speed + offset) % 1.0) * span - w;
      _cloud(canvas, Offset(x, size.height * y), w, paint);
    }
  }

  void _cloud(Canvas canvas, Offset o, double w, Paint p) {
    final h = w * 0.32;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(o.dx, o.dy, w, h),
        Radius.circular(h / 2),
      ),
      p,
    );
    canvas.drawCircle(Offset(o.dx + w * 0.32, o.dy + h * 0.1), h * 0.62, p);
    canvas.drawCircle(Offset(o.dx + w * 0.6, o.dy), h * 0.78, p);
  }

  @override
  bool shouldRepaint(_CloudsPainter old) => old.phase != phase;
}

/// Kichik dumaloq "pufakcha" ma'lumot (MB, tezlik, qolgan vaqt).
class KidInfoChip extends StatelessWidget {
  const KidInfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.color = const Color(0xFF0096B5),
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
