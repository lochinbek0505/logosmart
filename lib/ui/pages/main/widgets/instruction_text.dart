import 'package:flutter/material.dart';

class InstructionText extends StatelessWidget {
  final int stepNumber;
  final int totalSteps;
  final String instructionText;

  const InstructionText({
    super. key,
    required this.stepNumber,
    required this.totalSteps,
    required this. instructionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xff20B9E8),
                  const Color(0xff20B9E8).withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff20B9E8).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.accessibility_new,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width:  16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bosqich $stepNumber/$totalSteps",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors. grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instructionText,
                  style: const TextStyle(
                    fontSize:  16,
                    fontWeight: FontWeight.w700,
                    color: Colors. black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}