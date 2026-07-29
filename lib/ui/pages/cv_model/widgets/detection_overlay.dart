import 'package:flutter/material.dart';

class DetectionOverlay extends StatelessWidget {
  final Map<String, dynamic>? currentBest;
  final String Function(Map<String, dynamic>) onExtractLabel;
  final double Function(Map<String, dynamic>) onExtractConfidence;

  const DetectionOverlay({
    super.key,
    required this.currentBest,
    required this.onExtractLabel,
    required this.onExtractConfidence,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child:  Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white. withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentBest != null) ...[
              const SizedBox(height: 10),
              _buildProgressRow(
                "Ishonch ${currentBest!['tag']} ${onExtractConfidence(currentBest!)}",
                onExtractConfidence(currentBest!),
                _getConfidenceColor(onExtractConfidence(currentBest!)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: Colors. white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),

      ],
    );
  }

  Color _getConfidenceColor(double conf) {
    if (conf >= 0.7) return Colors.green;
    if (conf >= 0.5) return Colors.orange;
    return Colors.red;
  }
}