import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_colors.dart';

/// Bulut ichidagi matn. Matn hech qachon kesilmaydi:
/// 1) avval shrift [minFontSize] gacha kichraytiriladi,
/// 2) shunda ham sig'masa bulut balandligi matnga qarab o'sadi.
class CloudText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final double? minFontSize;
  final double? width;
  final double? height;
  final String image;
  final Color? color;

  const CloudText({
    required this.text,
    this.fontSize,
    this.minFontSize,
    this.width,
    this.height,
    this.image = "assets/icons/cloud.webp",
    this.color,
    super.key,
  });

  // cloud.webp (258x162) va big_cloud.webp (275x194) da matn uchun xavfsiz maydon: bulut tanasi,
  // tepadagi do'ngliklar va pastdagi pufakchalardan tashqari
  static const double _left = 0.10;
  static const double _right = 0.10;
  static const double _top = 0.20;
  static const double _bottom = 0.28;

  TextStyle _style(double size) => GoogleFonts.nunito(
    color: color ?? AppColors.main_blue_900,
    fontWeight: FontWeight.w600,
    fontSize: size,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    final double boxWidth = width ?? 320.w;
    final double baseHeight = height ?? 190.h;
    final double maxSize = fontSize ?? 18.sp;
    final double minSize = minFontSize ?? 14.sp;
    final textScaler = MediaQuery.textScalerOf(context);

    final double textWidth = boxWidth * (1 - _left - _right);
    final double textAreaFactor = 1 - _top - _bottom;

    double measure(double size) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: _style(size)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: textWidth);
      return painter.height;
    }

    // Asosiy balandlikka sig'adigan eng katta shrift
    double size = maxSize;
    double textHeight = measure(size);
    while (textHeight > baseHeight * textAreaFactor && size > minSize) {
      size = (size - 0.5).clamp(minSize, maxSize);
      textHeight = measure(size);
    }
    // Eng kichik shriftda ham sig'masa — bulut o'sadi
    final double boxHeight = textHeight > baseHeight * textAreaFactor
        ? textHeight / textAreaFactor
        : baseHeight;

    return Container(
      width: boxWidth,
      height: boxHeight,
      padding: EdgeInsets.fromLTRB(
        boxWidth * _left,
        boxHeight * _top,
        boxWidth * _right,
        boxHeight * _bottom,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.fill),
      ),
      child: Center(
        child: Text(text, textAlign: TextAlign.center, style: _style(size)),
      ),
    );
  }
}
