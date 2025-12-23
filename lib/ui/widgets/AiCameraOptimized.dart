import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show decodeImageFromList, Size;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

typedef OnDetections = void Function(
    List<Map<String, dynamic>> results,
    Size imageSize,
    );
typedef OnError = void Function(String error);

/// OPTIMIZED AI Camera - Dynamic output shape
class AICameraOptimized extends StatefulWidget {
  const AICameraOptimized({
    super.key,
    required this. modelPath,
    required this. labelsPath,
    this. useGpu = true,
    this.numThreads = 2,
    this. lensDirection = CameraLensDirection.back,
    this.resolution = ResolutionPreset.medium,
    this.imageFormat = ImageFormatGroup.jpeg,
    this.intervalMs = 200,
    this.iouThreshold = 0.45,
    this.confThreshold = 0.3,
    required this.onDetections,
    this.onError,
    this. showLoadingIndicator = true,
    this.inputSize = 640,
    this.showDebugInfo = false,
  });

  final String modelPath;
  final String labelsPath;
  final bool useGpu;
  final int numThreads;
  final CameraLensDirection lensDirection;
  final ResolutionPreset resolution;
  final ImageFormatGroup imageFormat;
  final int intervalMs;
  final double iouThreshold;
  final double confThreshold;
  final OnDetections onDetections;
  final OnError?  onError;
  final bool showLoadingIndicator;
  final int inputSize;
  final bool showDebugInfo;

  @override
  State<AICameraOptimized> createState() => _AICameraOptimizedState();
}

class _AICameraOptimizedState extends State<AICameraOptimized>
    with WidgetsBindingObserver {
  Interpreter? _interpreter;
  List<String> _labels = [];
  CameraController? _controller;
  Timer? _timer;
  bool _busy = false;
  bool _ready = false;
  bool _disposed = false;
  int _errorCount = 0;
  static const int _maxErrors = 5;

  // Model shape info
  int _outputRows = 0; // Will be 7 for your model
  int _outputCols = 0; // Will be 8400

  // Performance monitoring
  int _frameCount = 0;
  int _fps = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  double _avgInferenceTime = 0.0;
  final List<double> _inferenceTimes = [];
  static const int _maxInferenceSamples = 30;

  // Reusable buffers
  Float32List?  _inputBuffer;
  Float32List? _outputBuffer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final controller = _controller;
    if (controller == null || ! controller.value.isInitialized) return;

    if (state == AppLifecycleState. inactive ||
        state == AppLifecycleState.paused) {
      _stopPolling();
      controller.dispose();
      _controller = null;
      _ready = false;
    } else if (state == AppLifecycleState.resumed) {
      _init();
    }
  }

  Future<void> _init() async {
    if (_disposed) return;

    try {
      debugPrint('🚀 AICameraOptimized initsializatsiya...');

      // 1. Labels
      await _loadLabels();

      // 2. Model
      await _loadModel();

      // 3. Buffers (model shape'ga qarab)
      _createBuffers();

      // 4. Kamera
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _handleError('Kamera topilmadi');
        return;
      }

      final cam = cameras. firstWhere(
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
        await controller.dispose();
        return;
      }

      _controller = controller;

      if (! mounted) return;

      setState(() {
        _ready = true;
        _errorCount = 0;
      });

      debugPrint('✅ Kamera tayyor:  ${controller.value.previewSize}');

      _startPolling();
    } catch (e, st) {
      debugPrint('❌ Init xatolik: $e\n$st');
      _handleError('Init xatolik: $e');
    }
  }

  Future<void> _loadLabels() async {
    final labelsData = await rootBundle.loadString(widget.labelsPath);
    _labels = labelsData
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    debugPrint('✅ ${_labels.length} ta label yuklandi');
  }

  Future<void> _loadModel() async {
    final options = InterpreterOptions();
    options.threads = widget.numThreads;

    if (widget.useGpu) {
      if (Platform.isAndroid) {
        try {
          options.addDelegate(GpuDelegateV2());
          debugPrint('✅ GPU (Android) aktiv');
        } catch (e) {
          debugPrint('⚠️ GPU yo\'q, CPU ishlatilmoqda');
        }
      } else if (Platform.isIOS) {
        try {
          options.addDelegate(GpuDelegate());
          debugPrint('✅ GPU (iOS Metal) aktiv');
        } catch (e) {
          debugPrint('⚠️ Metal yo\'q, CPU ishlatilmoqda');
        }
      }
    }

    _interpreter = await Interpreter.fromAsset(
      widget.modelPath,
      options:  options,
    );

    // Get actual output shape from model
    final outputShape = _interpreter! .getOutputTensor(0).shape;
    debugPrint('📊 Model Output Shape: $outputShape');

    // outputShape = [1, 7, 8400]
    _outputRows = outputShape[1]; // 7
    _outputCols = outputShape[2]; // 8400

    debugPrint('✅ Model yuklandi - Rows: $_outputRows, Cols: $_outputCols');
  }

  void _createBuffers() {
    // Input:  [1, 640, 640, 3]
    _inputBuffer = Float32List(1 * widget.inputSize * widget.inputSize * 3);

    // Output: [1, rows, cols] - dynamic!
    _outputBuffer = Float32List(1 * _outputRows * _outputCols);

    debugPrint('✅ Buffers yaratildi - Output:  ${_outputBuffer! .length}');
  }

  void _startPolling() {
    _stopPolling();
    _timer = Timer.periodic(
      Duration(milliseconds: widget. intervalMs),
          (_) => _pollOnce(),
    );
    debugPrint('⏱️ Polling boshlandi - ${widget.intervalMs}ms');
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _pollOnce() async {
    final controller = _controller;
    final interpreter = _interpreter;

    if (! mounted ||
        controller == null ||
        interpreter == null ||
        !controller. value.isInitialized ||
        _busy) {
      return;
    }

    _busy = true;
    final startTime = DateTime.now();

    try {
      // 1. Rasm
      final shot = await controller.takePicture();
      if (_disposed) return;

      final bytes = await File(shot.path).readAsBytes();

      // 2. O'lchamlar
      final decodedImage = await decodeImageFromList(bytes);
      final imageWidth = decodedImage.width;
      final imageHeight = decodedImage.height;
      decodedImage.dispose();

      if (! mounted || _disposed) return;

      // 3. Preprocessing
      _preprocessImageFast(bytes);

      // 4. Inference
      _runInferenceFast(interpreter);

      // 5. Post-processing
      final detections = _parseYOLOv8OutputFast(
        imageWidth,
        imageHeight,
      );

      // 6. Callback
      if (mounted && ! _disposed) {
        widget.onDetections(
          detections,
          Size(imageWidth. toDouble(), imageHeight.toDouble()),
        );
      }

      // 7. Performance
      final inferenceMs = DateTime.now().difference(startTime).inMilliseconds;
      _inferenceTimes.add(inferenceMs. toDouble());
      if (_inferenceTimes.length > _maxInferenceSamples) {
        _inferenceTimes.removeAt(0);
      }
      _avgInferenceTime = _inferenceTimes.reduce((a, b) => a + b) /
          _inferenceTimes. length;

      // 8. FPS
      _frameCount++;
      final now = DateTime.now();
      if (now.difference(_lastFpsUpdate).inSeconds >= 1) {
        _fps = _frameCount;
        _frameCount = 0;
        _lastFpsUpdate = now;
        if (mounted) setState(() {});
      }

      // 9. Cleanup
      try {
        await File(shot.path).delete();
      } catch (_) {}
    } catch (e, st) {
      debugPrint('❌ Inference xatolik: $e\n$st');
      _errorCount++;
      if (_errorCount >= _maxErrors) {
        _handleError('Ko\'p xatoliklar: $e');
        _stopPolling();
      }
    } finally {
      _busy = false;
    }
  }

  void _preprocessImageFast(Uint8List bytes) {
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Image decode xatolik');
    }

    img.Image resized = img.copyResize(
      image,
      width: widget.inputSize,
      height: widget.inputSize,
      interpolation: img. Interpolation.linear,
    );

    int pixelIndex = 0;
    for (int y = 0; y < widget. inputSize; y++) {
      for (int x = 0; x < widget.inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        _inputBuffer![pixelIndex++] = pixel.r / 255.0;
        _inputBuffer![pixelIndex++] = pixel.g / 255.0;
        _inputBuffer![pixelIndex++] = pixel.b / 255.0;
      }
    }
  }

  void _runInferenceFast(Interpreter interpreter) {
    // Reshape input
    final input = _inputBuffer!.reshape([1, widget.inputSize, widget.inputSize, 3]);

    // Reshape output - DYNAMIC!
    final output = _outputBuffer!.reshape([1, _outputRows, _outputCols]);

    // Run
    interpreter.run(input, output);
  }

  List<Map<String, dynamic>> _parseYOLOv8OutputFast(
      int imageWidth,
      int imageHeight,
      ) {
    List<Map<String, dynamic>> detections = [];

    // Output:  [1, outputRows, outputCols]
    // outputRows = 4 (bbox) + numClasses
    final numClasses = _outputRows - 4;
    final numPredictions = _outputCols;

    debugPrint('🔍 Parsing:  $numClasses classes, $numPredictions predictions');

    final scaleX = imageWidth / widget.inputSize;
    final scaleY = imageHeight / widget.inputSize;

    for (int i = 0; i < numPredictions; i++) {
      // Get bbox (transposed format:  [row][col])
      final x = _outputBuffer![0 * numPredictions + i]; // Row 0
      final y = _outputBuffer![1 * numPredictions + i]; // Row 1
      final w = _outputBuffer![2 * numPredictions + i]; // Row 2
      final h = _outputBuffer![3 * numPredictions + i]; // Row 3

      // Get class scores (rows 4 onwards)
      double maxScore = 0.0;
      int maxClassIdx = 0;

      for (int c = 0; c < numClasses; c++) {
        final score = _outputBuffer! [(4 + c) * numPredictions + i];
        if (score > maxScore) {
          maxScore = score;
          maxClassIdx = c;
        }
      }

      // Filter
      if (maxScore < widget.confThreshold) continue;

      // Scale
      final x1 = ((x - w / 2) * scaleX).clamp(0.0, imageWidth.toDouble());
      final y1 = ((y - h / 2) * scaleY).clamp(0.0, imageHeight.toDouble());
      final x2 = ((x + w / 2) * scaleX).clamp(0.0, imageWidth.toDouble());
      final y2 = ((y + h / 2) * scaleY).clamp(0.0, imageHeight.toDouble());

      // Safety check
      if (maxClassIdx >= _labels.length) {
        debugPrint('⚠️ Class index $maxClassIdx >= ${_labels.length}');
        continue;
      }

      detections.add({
        'tag': _labels[maxClassIdx],
        'confidence': maxScore,
        'box': {
          'x1': x1,
          'y1': y1,
          'x2':  x2,
          'y2': y2,
        },
      });
    }

    debugPrint('✅ ${detections.length} deteksiya topildi');

    // NMS
    return _applyNMS(detections);
  }

  List<Map<String, dynamic>> _applyNMS(List<Map<String, dynamic>> detections) {
    detections.sort((a, b) =>
        (b['confidence'] as double).compareTo(a['confidence'] as double));

    List<Map<String, dynamic>> selected = [];

    while (detections.isNotEmpty) {
      final current = detections.removeAt(0);
      selected.add(current);

      detections.removeWhere((detection) {
        if (detection['tag'] == current['tag']) {
          final iou = _calculateIoU(
            current['box'] as Map<String, dynamic>,
            detection['box'] as Map<String, dynamic>,
          );
          return iou > widget.iouThreshold;
        }
        return false;
      });
    }

    return selected;
  }

  double _calculateIoU(Map<String, dynamic> box1, Map<String, dynamic> box2) {
    final x1 = (box1['x1'] as double)
        .clamp(box2['x1'] as double, box2['x2'] as double);
    final y1 = (box1['y1'] as double)
        .clamp(box2['y1'] as double, box2['y2'] as double);
    final x2 = (box1['x2'] as double)
        .clamp(box2['x1'] as double, box2['x2'] as double);
    final y2 = (box1['y2'] as double)
        .clamp(box2['y1'] as double, box2['y2'] as double);

    final intersectionArea = (x2 - x1).clamp(0.0, double.infinity) *
        (y2 - y1).clamp(0.0, double.infinity);

    final box1Area = (box1['x2'] - box1['x1']) * (box1['y2'] - box1['y1']);
    final box2Area = (box2['x2'] - box2['x1']) * (box2['y2'] - box2['y1']);
    final unionArea = box1Area + box2Area - intersectionArea;

    if (unionArea == 0) return 0.0;
    return intersectionArea / unionArea;
  }

  void _handleError(String error) {
    if (! mounted || _disposed) return;
    widget.onError?.call(error);
    debugPrint('❌ AICamera: $error');
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _controller?.dispose();
    _controller = null;
    _interpreter?. close();
    _interpreter = null;
    _inputBuffer = null;
    _outputBuffer = null;
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

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit:  BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize! .height,
                height: controller.value.previewSize!.width,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
        if (widget.showDebugInfo) _buildDebugOverlay(),
      ],
    );
  }

  Widget _buildDebugOverlay() {
    return Positioned(
      top: 10,
      right: 10,
      child:  Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚡ OPTIMIZED',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _debugRow('FPS', _fps.toString()),
            _debugRow('Inference', '${_avgInferenceTime. toStringAsFixed(0)}ms'),
            _debugRow('Shape', '[$_outputRows, $_outputCols]'),
            _debugRow('Classes', '${_labels.length}'),
            _debugRow('Busy', _busy ?  '🔴' : '🟢'),
          ],
        ),
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style:  const TextStyle(color: Colors. white70, fontSize: 11)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight. bold)),
        ],
      ),
    );
  }
}