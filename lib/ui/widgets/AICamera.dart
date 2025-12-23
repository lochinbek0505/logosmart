import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' show decodeImageFromList, Size;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';

typedef OnDetections = void Function(
    List<Map<String, dynamic>> results,
    Size imageSize,
    );

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

  /// TFLite model fayl yo'li (assets/model.tflite)
  final String modelPath;

  /// Obyekt nomlari fayli yo'li (assets/labels.txt)
  final String labelsPath;

  /// YOLO model versiyasi (yolov5, yolov8, yolov9, etc.)
  final String modelVersion;

  /// GPU akseleratsiyasidan foydalanish (tezroq inference)
  final bool useGpu;

  /// CPU thread'lar soni (ko'proq = tezroq, lekin batareya sarfi ko'p)
  final int numThreads;

  /// Qaysi kamera: old yoki orqa
  final CameraLensDirection lensDirection;

  /// Video sifati (low, medium, high, veryHigh)
  /// Medium - optimal balans tezlik va sifat o'rtasida
  final ResolutionPreset resolution;

  /// Rasm format guruhi (jpeg - siqilgan, tez)
  final ImageFormatGroup imageFormat;

  /// Kadr tekshirish intervali millisekund'larda
  /// Kichikroq = tez-tez tekshirish, ko'proq resurs sarfi
  final int intervalMs;

  /// IoU (Intersection over Union) threshold - qo'shaloq deteksiyalarni filtrlash
  /// 0.45 = 45% o'xshash box'larni birlashtriradi
  final double iouThreshold;

  /// Confidence threshold - minimal ishonch darajasi
  /// 0.5 = 50% va undan yuqori ishonchli natijalarni ko'rsatadi
  final double confThreshold;

  /// Class threshold - klasifikatsiya ishonch chegarasi
  final double classThreshold;

  /// Deteksiya natijalari callback'i - har safar obyekt topilganda chaqiriladi
  final OnDetections onDetections;

  /// Xatolik callback'i - muammolar yuz berganda xabar beradi
  final OnError? onError;

  /// Yuklanish indikatorini ko'rsatish
  final bool showLoadingIndicator;

  @override
  State<AICamera> createState() => _AICameraState();
}

class _AICameraState extends State<AICamera> with WidgetsBindingObserver {
  /// Flutter Vision SDK instance'i - YOLO modelini boshqaradi
  late final FlutterVision _vision;

  /// Kamera kontrolyori - kamera'ni boshqaradi
  CameraController? _controller;

  /// Vaqt bo'yicha tekshirish uchun timer
  Timer? _timer;

  /// Hozir inference bajarilayotganini bildiruvchi flag
  /// Bir vaqtning o'zida bir nechta inference'dan saqlaydi
  bool _busy = false;

  /// Model va kamera tayyor bo'lganini bildiruvchi flag
  bool _ready = false;

  /// Widget dispose qilinganini kuzatish uchun
  bool _disposed = false;

  /// Xatoliklar hisoblagichi - bir xil xatoni takrorlamaslik uchun
  int _errorCount = 0;
  static const int _maxErrors = 3;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding observer qo'shamiz - app lifecycle'ni kuzatish uchun
    WidgetsBinding.instance.addObserver(this);

    // FlutterVision instance'ini yaratamiz
    _vision = FlutterVision();

    // Asinxron initsializatsiyani boshlaymiz
    _init();
  }

  /// App lifecycle o'zgarishlarini kuzatish
  /// Fon'ga ketganda kamera'ni to'xtatish, qaytganda qayta ishga tushirish
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final controller = _controller;

    // Agar controller yo'q yoki tayyor emas bo'lsa, hech narsa qilmaymiz
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    // App background'ga ketganda
    if (state == AppLifecycleState.inactive) {
      _stopPolling(); // Polling'ni to'xtatamiz
      controller.dispose(); // Kamera resurslarini bo'shatamiz
      _controller = null;
      _ready = false;
    }
    // App qaytib kelganda
    else if (state == AppLifecycleState.resumed) {
      _init(); // Qayta initsializatsiya qilamiz
    }
  }

  /// Kamera va model'ni initsializatsiya qilish
  Future<void> _init() async {
    // Agar widget dispose qilingan bo'lsa, hech narsa qilmaymiz
    if (_disposed) return;

    try {
      // 1. Mavjud kameralar ro'yxatini olamiz
      final cameras = await availableCameras();

      // Agar kameralar yo'q bo'lsa, xatolik
      if (cameras.isEmpty) {
        _handleError('Kamera topilmadi');
        return;
      }

      // 2. Kerakli yo'nalishda kamerani topamiz
      final cam = cameras.firstWhere(
            (c) => c.lensDirection == widget.lensDirection,
        orElse: () => cameras.first, // Topilmasa birinchisini olamiz
      );

      // 3. Kamera controller'ini yaratamiz va sozlaymiz
      final controller = CameraController(
        cam,
        widget.resolution,
        enableAudio: false, // Audio kerak emas
        imageFormatGroup: widget.imageFormat,
      );

      // 4. Kamera'ni initsializatsiya qilamiz
      await controller.initialize();

      // Widget dispose qilingan bo'lsa, yangi controller'ni o'chiramiz
      if (_disposed) {
        await controller.dispose();
        return;
      }

      // Controller'ni saqlash
      _controller = controller;

      // 5. YOLO modelini yuklash
      await _vision.loadYoloModel(
        labels: widget.labelsPath,
        modelPath: widget.modelPath,
        modelVersion: widget.modelVersion,
        quantization: false, // Full precision model
        useGpu: widget.useGpu,
        numThreads: widget.numThreads,
      );

      // Widget hali mounted bo'lsa UI'ni yangilaymiz
      if (!mounted) return;

      setState(() {
        _ready = true; // Hamma narsa tayyor
        _errorCount = 0; // Xatoliklar hisobini resetlaymiz
      });

      // 6. Kadr tekshirishni boshlaymiz
      _startPolling();
    } catch (e) {
      // Xatolikni qayta ishlash
      _handleError('Initsializatsiya xatosi: $e');
    }
  }

  /// Polling jarayonini boshlash
  /// Belgilangan interval bilan kadrlarni tekshiradi
  void _startPolling() {
    // Avvalgi timer'ni bekor qilamiz (agar mavjud bo'lsa)
    _stopPolling();

    // Yangi periodic timer yaratamiz
    _timer = Timer.periodic(
      Duration(milliseconds: widget.intervalMs),
          (_) {
        // Har intervalda _pollOnce'ni chaqiramiz
        _pollOnce();
      },
    );
  }

  /// Polling'ni to'xtatish
  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  /// Bir marta kadr olish va inference qilish
  Future<void> _pollOnce() async {
    final controller = _controller;

    // Agar quyidagi shartlardan biri to'g'ri bo'lsa, hech narsa qilmaymiz:
    // - Widget mounted emas
    // - Controller yo'q
    // - Controller initsializatsiya qilinmagan
    // - Allaqachon inference bajarilayotgan
    if (!mounted ||
        controller == null ||
        !controller.value.isInitialized ||
        _busy) {
      return;
    }

    // Busy flag'ni o'rnatamiz - parallel inference'lardan saqlanish
    _busy = true;

    try {
      // 1. Joriy kadrdan rasm olamiz
      final XFile shot = await controller.takePicture();

      // Widget dispose qilingan bo'lsa, to'xtaymiz
      if (_disposed) return;

      // 2. Rasmni byte array sifatida o'qiymiz
      final bytes = await File(shot.path).readAsBytes();

      // 3. Rasmni decode qilib o'lchamlarini olamiz
      final img = await decodeImageFromList(bytes);
      final imageWidth = img.width;
      final imageHeight = img.height;

      // Rasm resurslarini bo'shatamiz
      img.dispose();

      // Widget hali mounted emasligini tekshiramiz
      if (!mounted || _disposed) return;

      // 4. YOLO inference bajaramiz
      final result = await _vision.yoloOnImage(
        bytesList: bytes,
        imageHeight: imageHeight,
        imageWidth: imageWidth,
        iouThreshold: widget.iouThreshold,
        confThreshold: widget.confThreshold,
        classThreshold: widget.classThreshold,
      );

      print("RESULT $result");
      // 5. Natijalarni callback orqali qaytaramiz
      if (mounted && !_disposed) {
        widget.onDetections(
          result,
          Size(imageWidth.toDouble(), imageHeight.toDouble()),
        );
      }

      // 6. Temp faylni o'chiramiz (xotira tozalash)
      try {
        await File(shot.path).delete();
      } catch (_) {
        // Fayl o'chirilmasa ham davom etamiz
      }
    } catch (e) {
      // Xatoliklarni yutamiz - inference jarayoni davom etishi kerak
      // Lekin juda ko'p xatolik bo'lsa, to'xtatamiz
      _errorCount++;
      if (_errorCount >= _maxErrors) {
        _handleError('Juda ko\'p inference xatoliklari: $e');
        _stopPolling();
      }
    } finally {
      // Har qanday holatda busy flag'ni resetlaymiz
      _busy = false;
    }
  }

  /// Xatoliklarni qayta ishlash
  void _handleError(String error) {
    if (!mounted || _disposed) return;

    // Agar callback mavjud bo'lsa, xabar yuboramiz
    widget.onError?.call(error);

    // Debug rejimida console'ga ham chiqaramiz
    debugPrint('AICamera Error: $error');
  }

  @override
  void dispose() {
    // Dispose flag'ni o'rnatamiz
    _disposed = true;

    // Observer'ni o'chiramiz
    WidgetsBinding.instance.removeObserver(this);

    // Timer'ni to'xtatamiz
    _stopPolling();

    // Kamera'ni o'chiramiz
    _controller?.dispose();
    _controller = null;

    // YOLO modelini o'chiramiz
    // closeYoloModel() aslida Future<void> qaytaradi
    // lekin dispose() sinxron bo'lishi kerak
    // Shuning uchun kutmasdan chaqiramiz
    _vision.closeYoloModel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    // Agar hali tayyor bo'lmagan bo'lsa
    if (!_ready || controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        // Agar loading indicator kerak bo'lsa ko'rsatamiz
        child: widget.showLoadingIndicator
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
            : null,
      );
    }

    // Tayyor bo'lsa - kamera preview'ni ko'rsatamiz
    return ClipRect(
      // ClipRect - ortiqcha qismlarni kesib tashlaydi
      child: OverflowBox(
        // OverflowBox - aspect ratio'ni to'g'ri ko'rsatish uchun
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
