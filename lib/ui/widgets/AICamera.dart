import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' show decodeImageFromList, Size, DartPluginRegistrant;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:fluttertoast/fluttertoast.dart';
typedef OnDetections = void Function(
    List<Map<String, dynamic>> results,
    Size imageSize,
    );

class AICamera extends StatefulWidget {
  const AICamera({
    super.key,
    required this.modelPath,
    required this.labelsPath,
    this.modelVersion = 'yolov8',
    this.useGpu = true,
    this.numThreads = 2,
    this.lensDirection = CameraLensDirection.back,
    this.resolution = ResolutionPreset.medium,
    this.imageFormat = ImageFormatGroup.jpeg,
    this.intervalMs = 450,
    this.iouThreshold = 0.45,
    this.confThreshold = 0.35,
    this.classThreshold = 0.5,
    required this.onDetections,
  });

  /// TFLite model manzili (assets ichida)
  final String modelPath;

  /// Labels manzili (assets ichida)
  final String labelsPath;

  /// YOLO versiyasi (flutter_vision uchun)
  final String modelVersion;

  /// GPU’dan foydalanish
  final bool useGpu;

  /// Inference tarmoq oqimlari soni
  final int numThreads;

  /// Qaysi kamera
  final CameraLensDirection lensDirection;

  /// Kamera resolution
  final ResolutionPreset resolution;

  /// Surat format guruhi (takePicture uchun jpeg ma’qul)
  final ImageFormatGroup imageFormat;

  /// Kadr olish intervali (ms)
  final int intervalMs;

  /// YOLO threshold’lar
  final double iouThreshold;
  final double confThreshold;
  final double classThreshold;

  /// Natijalar callback’i
  final OnDetections onDetections;

  @override
  State<AICamera> createState() => _AICameraState();
}

class _AICameraState extends State<AICamera> {
  late final FlutterVision _vision;
  CameraController? _controller;
  Timer? _timer;
  bool _busy = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _vision = FlutterVision();
    _init();
  }

  Future<void> _init() async {
    try {
      // Kameralar
      final cameras = await availableCameras();
      final cam = cameras.firstWhere(
            (c) => c.lensDirection == widget.lensDirection,
        orElse: () => cameras.first,
      );

      // Kamera controller
      final controller = CameraController(
        cam,
        widget.resolution,
        enableAudio: false,
        imageFormatGroup: widget.imageFormat,
      );
      await controller.initialize();
      _controller = controller;

      // Model
      await _vision.loadYoloModel(
        labels: widget.labelsPath,
        modelPath: widget.modelPath,
        modelVersion: widget.modelVersion,
        quantization: false,
        useGpu: widget.useGpu,
        numThreads: widget.numThreads,
      );

      if (!mounted) return;
      setState(() => _ready = true);

      // Darhol pollingni boshlaymiz
      _startPolling();
    } catch (e) {
      // Xatoni minimal usulda yutib yuboramiz, UI’da faqat kamera (yoki bo‘sh)
      // print('Init error: $e');
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (_) {
      _pollOnce();
    });
  }

  Future<void> _pollOnce() async {
    final controller = _controller;
    if (!mounted || controller == null || !controller.value.isInitialized || _busy) return;

    _busy = true;
    try {
      final XFile shot = await controller.takePicture(); // stream emas
      final bytes = await File(shot.path).readAsBytes();

      // O‘lcham
      final img = await decodeImageFromList(bytes);
      final imageWidth = img.width;
      final imageHeight = img.height;

      // YOLO inference
      final result = await _vision.yoloOnImage(
        bytesList: bytes,
        imageHeight: imageHeight,
        imageWidth: imageWidth,
        iouThreshold: widget.iouThreshold,
        confThreshold: widget.confThreshold,
        classThreshold: widget.classThreshold,
      );

      if (!mounted) return;
      widget.onDetections(result, Size(imageWidth.toDouble(), imageHeight.toDouble()));
    } catch (_) {
      // e.g., tez-tez bosilganda yoki fayl o‘qish xatolari — yutamiz
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _controller?.dispose();
    // dispose() async bo‘la olmaydi — sinxron chaqiramiz
    _vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (!_ready || controller == null || !controller.value.isInitialized) {
      // UI talabi: ortiqcha widget yo‘q — bo‘sh qora fon kifoya
      return const SizedBox.expand(child: ColoredBox(color: Colors.black));
    }

    // Faqat kamera preview. Hech qanday overlay/icon yo‘q.
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller,),
    );
  }
}
