
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class InteractiveLottie extends StatefulWidget {
  final String assetPath;
  final double size;

  const InteractiveLottie({
    super.key,
    required this.assetPath,
    this.size = 100,
  });

  @override
  State<InteractiveLottie> createState() => _InteractiveLottieState();
}

class _InteractiveLottieState extends State<InteractiveLottie> {
  double _scale = 1.2;

  void _onTap() {
    setState(() => _scale = 1.5);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _scale = 1.2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.bounceOut,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Lottie.asset(
            widget.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
      ),
    );
  }
}
