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

  const CameraBox({
    super.key,
    required this. size,
    required this.cameraActive,
    required this. camKey,
    required this. modelPath,
    required this. labelsPath,
    required this.onDetections,
  });

  @override
  State<CameraBox> createState() => _CameraBoxState();
}

class _CameraBoxState extends State<CameraBox> {
  // ✅ Local camera active state
  bool _localCameraActive = true;

  @override
  void initState() {
    super.initState();
    _localCameraActive = widget.cameraActive;
  }

  @override
  void didUpdateWidget(CameraBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ Agar cameraActive false ga o'zgardi, local state'ni yangilaymiz
    if (oldWidget.cameraActive != widget. cameraActive) {
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
    // ✅ Dispose dan oldin kamerani o'chirish
    _localCameraActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width * 0.6,
      height: widget.size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xff20B9E8), width: 3),
        boxShadow: [
          BoxShadow(
            color:  const Color(0xff20B9E8).withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        // ✅ Local state'dan foydalanish
        child:  _localCameraActive && widget.cameraActive
            ?  YoloCameraWidget(
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