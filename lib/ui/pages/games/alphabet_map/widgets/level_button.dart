
import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/star_meter.dart';

import '../../../../../models/level_model.dart';
import '../../../../theme/app_colors.dart';

class LevelButton extends StatefulWidget {
  final Level level;
  final bool isCurrent;
  final VoidCallback? onTap;

  const LevelButton({
    super.key,
    required this.level,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  State<LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), // puls tezligi
    );

    // Tugma 1.0 dan 1.12 gacha kattalashib kichrayadi
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Faqatgina ushbu bosqich hozirgi (ochiq va eng oxirgi) bo'lsa ishlaydi
    if (widget.isCurrent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.level;

    // Asl rang va uslublaringiz
    final starFilled = l.locked ? Colors.grey : Colors.amber;
    final starEmpty = l.locked ? Colors.black26 : Colors.black26;
    // TODO OXIRDA CHIQAR COMMENT BLAA l.locked ? null :
    // Asl vizual UI ni bitta o'zgaruvchiga yig'amiz
    Widget buttonContent = GestureDetector(
      onTap:  widget.onTap,
      child: Column(
        children: [
          if (!l.locked)
            SizedBox(
              height: 35,
              child: StarMeter(
                value: l.stars,
                max: 3,
                filledColor: starFilled,
                emptyColor: starEmpty,
              ),
            ),
          const SizedBox(height: 5),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(l.skin, width: 70, height: 70, fit: BoxFit.cover),
              Text(
                '${l.id}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: !l.locked ? Colors.white : AppColors.grey_600,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Animatsiya bor/yo'qligini tekshirib qaytaramiz
    if (widget.isCurrent) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}