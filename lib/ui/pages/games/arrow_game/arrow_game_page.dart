import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/games/arrow_game/widgets/arrow_line_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

import '../../../../models/target_node_model.dart';
import '../../main/widgets/custom_text_widget.dart';

class ArrowGamePage extends StatefulWidget {
  const ArrowGamePage({super.key});

  @override
  State<ArrowGamePage> createState() => _ArrowGamePageState();
}

class _ArrowGamePageState extends State<ArrowGamePage> {
  final double innerRadius = 70.w; // Markaziy doira va kichik doiralar masofasi
  final double outerRadius = 150.w; // Tashqi harflar joylashuv masofasi
  final String centerLetter = "R";

  final List<TargetNode> outerNodes = [
    TargetNode(0, "A", AppColors.orange_400, -150),
    TargetNode(1, "O", AppColors.green_600, -90),
    TargetNode(2, "U", AppColors.pink_400, -30),
    TargetNode(3, "I", const Color(0xFFF2C860), 30),
    TargetNode(4, "E", const Color(0xFF7FD8F7), 90),
    TargetNode(5, "O'", AppColors.red_300, 150),
  ];

  Map<int, int> connectedLines = {};

  int? activeInnerNode;
  Offset? currentDragPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            _buildHeader(),
            SizedBox(height: 57.h),
            SizedBox(
              width: 300.w,
              height: 370.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final Offset centerPoint = Offset(
                    constraints.maxWidth / 2,
                    constraints.maxHeight / 2,
                  );

                  return GestureDetector(
                    onPanStart: (details) =>
                        _onDragStart(details.localPosition, centerPoint),
                    onPanUpdate: (details) =>
                        _onDragUpdate(details.localPosition),
                    onPanEnd: (details) => _onDragEnd(centerPoint),
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: ArrowLinePainter(
                            centerPoint: centerPoint,
                            innerRadius: innerRadius,
                            outerRadius: outerRadius,
                            outerNodes: outerNodes,
                            connectedLines: connectedLines,
                            activeInnerNode: activeInnerNode,
                            currentDragPosition: currentDragPosition,
                          ),
                        ),

                        Positioned(
                          left: centerPoint.dx - innerRadius,
                          top: centerPoint.dy - innerRadius,
                          width: innerRadius * 2,
                          height: innerRadius * 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CustomTextWidget(
                                text: centerLetter,
                                sizeText: 96.sp,
                                textColor: const Color(0xFF4A90E2),
                                strokeWidth: 8.w,
                              ),
                            ),
                          ),
                        ),

                        // 3. Kichik doiralar (Ularning markazi katta doira chizig'ida yotadi)
                        ...List.generate(outerNodes.length, (index) {
                          final pos = _calculatePosition(
                            centerPoint,
                            innerRadius,
                            outerNodes[index].angle,
                          );
                          return Positioned(
                            left: pos.dx - 18.w,
                            top: pos.dy - 18.w,
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // 4. Tashqi harflar
                        ...outerNodes.map((node) {
                          final pos = _calculatePosition(
                            centerPoint,
                            outerRadius,
                            node.angle,
                          );
                          return Positioned(
                            left: pos.dx - 25.w,
                            top: pos.dy - 25.h,
                            child: CustomTextWidget(
                              text: node.letter,
                              sizeText: 64.sp,
                              textColor: node.color,
                              strokeWidth: 6.w,
                            ),
                          );
                        }),
                      ],
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 40.w,
                color: const Color(0xffFFC754),
              ),
              SizedBox(width: 8.w),
              CustomTextWidget(text: "20", sizeText: 32.sp),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8.5,
              bottom: 11.5,
            ),
            width: 80.w,
            height: 80.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/icons/circle.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage("assets/icons/circle_bad.png"),
            ),
          ),
        ],
      ),
    );
  }

  Offset _calculatePosition(Offset center, double radius, double angleDegree) {
    final double angleRadian = angleDegree * (pi / 180);
    return Offset(
      center.dx + radius * cos(angleRadian),
      center.dy + radius * sin(angleRadian),
    );
  }

  void _onDragStart(Offset touchPosition, Offset centerPoint) {
    for (int i = 0; i < outerNodes.length; i++) {
      final innerNodePos = _calculatePosition(
        centerPoint,
        innerRadius,
        outerNodes[i].angle,
      );
      if ((touchPosition - innerNodePos).distance < 30.w) {
        setState(() {
          activeInnerNode = i;
          currentDragPosition = touchPosition;
        });
        break;
      }
    }
  }

  void _onDragUpdate(Offset touchPosition) {
    if (activeInnerNode != null) {
      setState(() {
        currentDragPosition = touchPosition;
      });
    }
  }

  void _onDragEnd(Offset centerPoint) {
    if (activeInnerNode != null && currentDragPosition != null) {
      // ignore: unused_local_variable
      bool matched = false;

      for (var node in outerNodes) {
        final targetPos = _calculatePosition(
          centerPoint,
          outerRadius,
          node.angle,
        );
        if ((currentDragPosition! - targetPos).distance < 45.w) {
          if (activeInnerNode == node.id) {
            setState(() {
              connectedLines[activeInnerNode!] = node.id;
            });
            _showSnackbar(
              "To'g'ri! ${node.letter} harfi topildi.",
              Colors.green,
            );
            matched = true;
          } else {
            _showSnackbar("Xato ulanish, qayta urinib ko'ring!", Colors.red);
          }
          break;
        }
      }

      setState(() {
        activeInnerNode = null;
        currentDragPosition = null;
      });
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
