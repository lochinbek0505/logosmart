import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              Color color;
              if (index < currentStep) {
                color = Colors.green;
              } else if (index == currentStep) {
                color = const Color(0xff20B9E8);
              } else {
                color = Colors.grey. shade300;
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: index == currentStep
                        ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius:  8,
                        spreadRadius: 1,
                      ),
                    ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${currentStep + 1} / $totalSteps bosqich',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xff20B9E8),
            ),
          ),
        ],
      ),
    );
  }
}