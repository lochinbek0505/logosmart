import 'package:flutter/material.dart';

class StarMeter extends StatelessWidget {
  final int value;
  final int max;
  final Color filledColor;
  final Color emptyColor;
  final EdgeInsets spacing;

  const StarMeter({
    super.key,
    required this.value,
    this.max = 3,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.black26,
    this.spacing = const EdgeInsets.symmetric(horizontal: 2),
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0, max);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < v;
        final size = i == 1 ? 30.0 : 20.0;
        return Padding(
          padding: spacing,
          child: Image.asset(
            filled ? "assets/icons/star.png" : "assets/icons/star_grey.png",
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        );
      }),
    );
  }
}
