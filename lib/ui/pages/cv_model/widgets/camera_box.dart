import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logosmart/ui/widgets/yolo_camera_widget.dart';

import 'SuccessGifPlaceholder.dart';

class CameraBox extends StatefulWidget {
  final Size size;
  final bool cameraActive;
  final Key camKey;
  final String modelPath;
  final String labelsPath;
  final Function(List<Map<String, dynamic>>, Size) onDetections;

  // ✅ RANG QABUL QILISH UCHUN YANGI PARAMETR
  final Color borderColor;

  const CameraBox({
    super.key,
    required this.size,
    required this.cameraActive,
    required this.camKey,
    required this.modelPath,
    required this.labelsPath,
    required this.onDetections,
    this.borderColor = const Color(0xff20B9E8), // Default rang
  });

  @override
  State<CameraBox> createState() => _CameraBoxState();
}

class _CameraBoxState extends State<CameraBox> {
  bool _localCameraActive = true;

  @override
  void initState() {
    super.initState();
    _localCameraActive = widget.cameraActive;
  }

  @override
  void didUpdateWidget(CameraBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cameraActive != widget.cameraActive) {
      if (!widget.cameraActive && _localCameraActive) {
        debugPrint('🛑 CameraBox: cameraActive false bo\'ldi, kamerani o\'chirish');
        setState(() {
          _localCameraActive = false;
        });
      } else if (widget.cameraActive && !_localCameraActive) {
        debugPrint('▶️ CameraBox: cameraActive true bo\'ldi, kamerani yoqish');
        setState(() {
          _localCameraActive = true;
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 CameraBox dispose qilinmoqda');
    _localCameraActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ RANG SILLIQ O'ZGARISHI UCHUN AnimatedContainer ISHLATAMIZ
    print("asamknalf");
    print(widget.borderColor);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.size.width * 0.6,
      height: widget.size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: widget.borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: widget.borderColor.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: _localCameraActive && widget.cameraActive
            ? YoloCameraWidget(
          key: widget.camKey,
          modelPath: widget.modelPath,
          useGpu: false,
          onDetections: widget.onDetections,
        )
            : const SuccessGifPlaceholder(),
      ),
    );
  }
}