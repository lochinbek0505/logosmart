import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final double sizeText;
  final Color textColor;
  final double strokeWidth;

  const CustomTextWidget({
    super.key,
    required this.text,
    this.sizeText = 32,
    this.textColor = const Color(0xffFFC754),
    this.strokeWidth = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: sizeText,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.white,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: sizeText,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ],
    );
  }
}