import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';

typedef OnDetections =
    void Function(List<Map<String, dynamic>> results, Size imageSize);

typedef OnError = void Function(String error);

class AICamera extends StatefulWidget {
  const AICamera({
    super.key,
    required this.modelPath,
    required this.labelsPath,
    this.modelVersion = 'yolov8',
    this.useGpu = true,
    this.numThreads = 2,
    this.lensDirection = CameraLensDirection.front,
    this.resolution = ResolutionPreset.low,
    this.imageFormat = ImageFormatGroup.yuv420,
    this.intervalMs = 450,
    this.iouThreshold = 0.4,
    this.confThreshold = 0.4,
    this.classThreshold = 0.5,
    required this.onDetections,
    this.onError,
    this.showLoadingIndicator = true,
  });

  final String modelPath;
  final String labelsPath;
  final String modelVersion;
  final bool useGpu;
  final int numThreads;
  final CameraLensDirection lensDirection;
  final ResolutionPreset resolution;
  final ImageFormatGroup imageFormat;
  final int intervalMs;
  final double iouThreshold;
  final double confThreshold;
  final double classThreshold;
  final OnDetections onDetections;
  final OnError? onError;
  final bool showLoadingIndicator;

  @override
  State<AICamera> createState() => _AICameraState();
}

class _AICameraState extends State<AICamera> with WidgetsBindingObserver {
  late final FlutterVision _vision;
  CameraController? _controller;
  Timer? _timer;
  bool _busy = false;
  bool _ready = false;
  bool _disposed = false;
  int _errorCount = 0;
  static const int _maxErrors = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _vision = FlutterVision();
    _init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      debugPrint('📱 AICamera: App inactive/paused, kamerani to\'xtatish');
      _stopPolling();
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (!_disposed) {
        debugPrint('📱 AICamera: App resumed, kamerani qayta boshlash');
        _init();
      }
    }
  }

  Future<void> _init() async {
    if (_disposed) {
      debugPrint('⚠️ AICamera allaqachon dispose qilingan, init skip');
      return;
    }

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _handleError('Kamera topilmadi');
        return;
      }

      final cam = cameras.firstWhere(
        (c) => c.lensDirection == widget.lensDirection,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        cam,
        widget.resolution,
        enableAudio: false,
        imageFormatGroup: widget.imageFormat,
      );

      await controller.initialize();

      if (_disposed) {
        debugPrint('⚠️ AICamera dispose qilingan, controller ni o\'chirish');
        await controller.dispose();
        return;
      }

      _controller = controller;

      debugPrint('🤖 YOLO modelni yuklash: ${widget.modelPath}');
      await _vision.loadYoloModel(
        labels: widget.labelsPath,
        modelPath: widget.modelPath,
        modelVersion: widget.modelVersion,
        quantization: false,
        useGpu: widget.useGpu,
        numThreads: widget.numThreads,
      );
      debugPrint('✅ YOLO model yuklandi');

      if (!mounted || _disposed) {
        debugPrint(
          '⚠️ Widget unmounted, model yuklanganidan keyin to\'xtatish',
        );
        return;
      }

      setState(() {
        _ready = true;
        _errorCount = 0;
      });

      _startPolling();
    } catch (e, stack) {
      debugPrint('❌ AICamera init xatolik: $e');
      debugPrint('Stack: $stack');
      _handleError('Initsializatsiya xatosi: $e');
    }
  }

  void _startPolling() {
    _stopPolling();

    if (_disposed) {
      debugPrint('⚠️ Disposed, polling boshlanmaydi');
      return;
    }

    debugPrint('⏰ Polling boshlandi (interval: ${widget.intervalMs}ms)');
    _timer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (_) {
      if (!_disposed) {
        _pollOnce();
      }
    });
  }

  void _stopPolling() {
    if (_timer != null) {
      debugPrint('⏸️ Polling to\'xtatildi');
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _pollOnce() async {
    final controller = _controller;

    if (!mounted ||
        _disposed ||
        controller == null ||
        !controller.value.isInitialized ||
        _busy) {
      return;
    }

    _busy = true;

    try {
      final XFile shot = await controller.takePicture();

      if (_disposed || !mounted) {
        _busy = false;
        return;
      }

      final bytes = await File(shot.path).readAsBytes();
      final img = await decodeImageFromList(bytes);
      final imageWidth = img.width;
      final imageHeight = img.height;
      img.dispose();

      if (!mounted || _disposed) {
        _busy = false;
        return;
      }

      final result = await _vision.yoloOnImage(
        bytesList: bytes,
        imageHeight: imageHeight,
        imageWidth: imageWidth,
        iouThreshold: widget.iouThreshold,
        confThreshold: widget.confThreshold,
        classThreshold: widget.classThreshold,
      );

      if (mounted && !_disposed) {
        widget.onDetections(
          result,
          Size(imageWidth.toDouble(), imageHeight.toDouble()),
        );
      }

      try {
        await File(shot.path).delete();
      } catch (_) {}
    } catch (e) {
      _errorCount++;
      if (_errorCount >= _maxErrors) {
        _handleError('Juda ko\'p inference xatoliklari: $e');
        _stopPolling();
      }
    } finally {
      _busy = false;
    }
  }

  void _handleError(String error) {
    if (!mounted || _disposed) return;
    widget.onError?.call(error);
    debugPrint('AICamera Error: $error');
  }

  // ✅ Kamerani dispose qilish (model'siz)
  Future<void> _disposeCamera() async {
    debugPrint('🧹 AICamera:  Camera dispose');
    _stopPolling();

    final controller = _controller;
    _controller = null;
    _ready = false;

    if (controller != null) {
      try {
        await controller.dispose();
        debugPrint('✅ Camera controller dispose qilindi');
      } catch (e) {
        debugPrint('⚠️ Camera dispose xatolik: $e');
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 AICamera:  Widget dispose boshlandi');
    _disposed = true;

    WidgetsBinding.instance.removeObserver(this);

    // ✅ 1. Avval polling'ni to'xtatish
    _stopPolling();

    // ✅ 2. Kamera'ni o'chirish
    final controller = _controller;
    _controller = null;

    if (controller != null) {
      controller
          .dispose()
          .then((_) {
            debugPrint('✅ Camera disposed');
          })
          .catchError((e) {
            debugPrint('⚠️ Camera dispose error: $e');
          });
    }

    // ✅ 3. Model'ni xavfsiz yopish
    try {
      _vision
          .closeYoloModel()
          .then((_) {
            debugPrint('✅ YOLO model yopildi');
          })
          .catchError((e) {
            debugPrint('⚠️ YOLO model close error: $e');
          });
    } catch (e) {
      debugPrint('⚠️ YOLO close sync error: $e');
    }

    debugPrint('🏁 AICamera:  Widget dispose tugadi');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (!_ready || controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: widget.showLoadingIndicator
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : null,
      );
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize!.height,
            height: controller.value.previewSize!.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}
