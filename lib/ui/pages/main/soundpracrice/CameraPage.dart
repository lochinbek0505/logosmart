import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logosmart/ui/widgets/AICamera.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/storage/level_state.dart';
import '../../../../providers/level_provider.dart';

/// MP4 video fayllar bilan ishlovchi optimallashtirilgan kamera sahifasi
class CameraPage extends StatefulWidget {
  final LevelState data;

  const CameraPage({super.key, required this.data});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

enum _SeqState { idle, waiting, success, fail }

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  Key _camKey = UniqueKey();
  bool _cameraActive = true;
  Color _camBorderColor = const Color(0xff20B9E8);
  late List<String> _sequence;
  int _idx = 0;
  int _errors = 0;

  static const Duration _acceptCooldown = Duration(milliseconds: 600);
  DateTime? _lastAcceptedAt;
  _SeqState _seqState = _SeqState.idle;
  DateTime? _lastToastAt;

  static const int _windowMs = 800;
  static const int _minHoldMs = 300;
  static const int _stepTimeoutMs = 5000;
  static const int _minVotes = 1;
  static const double _minAvgConf = 0.50;

  // ====== VIDEO CONTROLLER - MP4 uchun optimallashtirilgan ======
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  String? _currentVideoPath;

  late DateTime _stepStartAt;
  final _VoteWindow _vote = _VoteWindow(windowMs: _windowMs);
  String? _lastAcceptedLabel;

  List<Map<String, dynamic>> _lastDetections = [];
  Map<String, dynamic>? _currentBest;
  double _stability = 0.0;
  bool _showDebugPanel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Mashq bosqichlarini tayyorlash
    final steps = List<ExerciseStep>.from(widget.data.exercise!.steps);
    if (steps.isNotEmpty) {
      steps.removeAt(0); // Birinchi "about" stepni olib tashlash
    }

    _sequence = steps
        .map((s) => _normalizeUz(s.action.toString()))
        .where((a) => a.isNotEmpty)
        .toList();

    if (_sequence.length > 4) {
      _sequence = _sequence.take(4).toList();
    }

    _seqState = _SeqState.waiting;
    _setBorderNormal();
    _stepStartAt = DateTime.now();

    // Video initsializatsiya - MP4 fayl
    _initializeVideo();

    // Birinchi ko'rsatma
    _showStepInstruction();
  }

  /// MP4 video faylni yuklash va sozlash
  Future<void> _initializeVideo() async {
    try {
      // Video fayl yo'lini olish
      _currentVideoPath = widget.data.exercise?.mediaPath ?? 'assets/video.mp4';

      debugPrint('🎬 MP4 video yuklanmoqda: $_currentVideoPath');

      // Eski controller'ni tozalash (agar mavjud bo'lsa)
      await _videoController?.dispose();

      // Yangi controller yaratish - MP4 fayl uchun
      _videoController = VideoPlayerController.asset(
        _currentVideoPath!,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Boshqa audio bilan aralashishi mumkin
          allowBackgroundPlayback: false, // Fonda ijro etilmasin
        ),
      );

      // Controller listener qo'shish - xatolarni ushlash uchun
      _videoController!.addListener(() {
        if (_videoController!.value.hasError) {
          debugPrint('❌ Video xatolik: ${_videoController!.value.errorDescription}');
          if (mounted) {
            setState(() {
              _isVideoError = true;
              _isVideoInitialized = false;
            });
          }
        }

        // Video tugaganda (agar loop bo'lmasa)
        if (_videoController!.value.position >= _videoController!.value.duration) {
          debugPrint('🔄 Video tugadi, qayta boshlanmoqda...');
        }
      });

      // Video'ni initsializatsiya qilish
      await _videoController!.initialize();

      debugPrint('✅ Video muvaffaqiyatli initsializatsiya qilindi');
      debugPrint('📊 Video ma\'lumotlari:');
      debugPrint('   - O\'lcham: ${_videoController!.value.size.width}x${_videoController!.value.size.height}');
      debugPrint('   - Davomiyligi: ${_videoController!.value.duration.inSeconds}s');
      debugPrint('   - Aspect Ratio: ${_videoController!.value.aspectRatio}');

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoError = false;
        });

        // Video sozlamalarini qo'llash
        await _videoController!.setLooping(true);  // Takroriy ijro
        await _videoController!.setVolume(0.0);     // Ovozni o'chirish (mashqda chalg'itmasin)
        await _videoController!.play();             // Avtomatik boshlash

        debugPrint('▶️ Video ijro etilmoqda (loop: true, volume: 0)');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Video yuklashda xatolik: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _isVideoError = true;
        });

        // Xatolik haqida toast ko'rsatish
        Fluttertoast.showToast(
          msg: "⚠️ Video yuklashda xatolik",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 CameraPage dispose qilinmoqda...');

    // Video controller'ni to'xtatish va tozalash
    _videoController?.removeListener(() {});
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;

    // Observer'ni olib tashlash
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload'da video'ni qayta yuklash
    _safeRestartVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 App lifecycle o\'zgardi: $state');

    // Video'ni lifecycle'ga qarab boshqarish
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Fon'ga ketganda to'xtatish
      debugPrint('⏸️ Video to\'xtatilmoqda (app background)');
      _videoController?.pause();

      if (_cameraActive) {
        setState(() => _cameraActive = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      // Qaytib kelganda davom ettirish
      debugPrint('▶️ Video qayta boshlanmoqda (app resumed)');

      if (_isVideoInitialized && _videoController != null) {
        _videoController!.play();
      } else {
        // Agar video muammoli bo'lsa, qayta yuklash
        _initializeVideo();
      }

      // Kamera'ni ham qayta ishga tushirish
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _camKey = UniqueKey();
            _cameraActive = true;
          });
        }
      });
    }
  }

  /// Video'ni xavfsiz tarzda qayta yuklash
  void _safeRestartVideo() {
    if (!mounted) return;

    debugPrint('🔄 Video qayta yuklanmoqda...');

    setState(() {
      _isVideoInitialized = false;
      _isVideoError = false;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _initializeVideo();
      }
    });
  }

  /// Kamera'ni xavfsiz tarzda qayta yuklash
  void _safeStopCameraAndRemount() {
    if (!mounted) return;

    debugPrint('📷 Kamera qayta yuklanmoqda...');

    setState(() => _cameraActive = false);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _camKey = UniqueKey();
        _cameraActive = true;
      });
    });
  }

  void _showStepInstruction() {
    if (_idx >= _sequence.length) return;

    final currentAction = _sequence[_idx];
    final step = widget.data.exercise!.steps.firstWhere(
          (s) => _normalizeUz(s.action.toString()) == currentAction,
      orElse: () => widget.data.exercise!.steps.first,
    );

    Fluttertoast.showToast(
      msg: "📋 ${step.text}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xff20B9E8),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (mounted) setState(() => _cameraActive = false);
        _videoController?.pause();
        return true;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          mini: true,
          backgroundColor: _showDebugPanel ? Colors.red : const Color(0xff20B9E8),
          onPressed: () {
            setState(() => _showDebugPanel = !_showDebugPanel);
          },
          child: Icon(
            _showDebugPanel ? Icons.bug_report : Icons.bug_report,
            color: Colors.white,
          ),
        ),
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              // Fon
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/backround_xira.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              // Yuqori panel
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Orqaga qaytish
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            if (mounted) setState(() => _cameraActive = false);
                            _videoController?.pause();
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            "assets/icons/arrow_right_button.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      // Yulduzlar
                      Row(
                        children: [
                          Image.asset("assets/icons/star.png", width: 40, height: 40),
                          const SizedBox(width: 12),
                          Image.asset("assets/icons/namber_o.png", height: 35),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Markaziy content
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: size.width, height: 150),

                  // MP4 Video player
                  _buildMP4VideoBox(size),

                  const SizedBox(height: 15),

                  // Progress
                  _buildProgressIndicator(),

                  const SizedBox(height: 15),

                  // Kamera
                  _buildCameraBox(size),

                  const SizedBox(height: 15),

                  // Ko'rsatma
                  _buildCurrentInstructionText(),
                ],
              ),

              // Debug panel
              if (_showDebugPanel) _buildDebugPanel(),

              // Deteksiya overlay
              _buildDetectionOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// MP4 video player qutisi - TO'LIQ OPTIMALLASHTIRILGAN
  Widget _buildMP4VideoBox(Size size) {
    return Container(
      width: size.width * 0.6,
      height: size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xff20B9E8), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff20B9E8).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: _buildVideoContent(),
      ),
    );
  }

  /// Video content - holat bo'yicha render qilish
  Widget _buildVideoContent() {
    // 1. XATOLIK holati
    if (_isVideoError) {
      return Container(
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'MP4 video yuklashda xatolik',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _currentVideoPath ?? 'Video yo\'li topilmadi',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isVideoError = false;
                  _isVideoInitialized = false;
                });
                _initializeVideo();
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Qayta yuklash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff20B9E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. YUKLANMOQDA holati
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff20B9E8)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'MP4 video yuklanmoqda...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentVideoPath?.split('/').last ?? '',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    // 3. VIDEO TAYYOR - ko'rsatish
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player - aspect ratio to'g'ri
        Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),

        // Play/Pause va progress (debug rejimida)
        if (_showDebugPanel) ...[
          // Progress bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Color(0xff20B9E8),
                bufferedColor: Colors.white30,
                backgroundColor: Colors.white10,
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            ),
          ),

          // Play/Pause button
          Positioned(
            bottom: 24,
            right: 8,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                      debugPrint('⏸️ Video to\'xtatildi (manual)');
                    } else {
                      _videoController!.play();
                      debugPrint('▶️ Video davom ettirildi (manual)');
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Video info badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'MP4 • ${_videoController!.value.duration.inSeconds}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],

        // Center play button (video to'xtaganda)
        if (!_videoController!.value.isPlaying && !_showDebugPanel)
          Center(
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  _videoController!.play();
                },
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: List.generate(_sequence.length, (index) {
              Color color;
              if (index < _idx) {
                color = Colors.green; // Bajarilgan
              } else if (index == _idx) {
                color = const Color(0xff20B9E8); // Joriy
              } else {
                color = Colors.grey.shade300; // Kutilayotgan
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: index == _idx
                        ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
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
          // Progress matn
          Text(
            '${_idx + 1} / ${_sequence.length} bosqich',
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

  Widget _buildCameraBox(Size size) {
    return Container(
      width: size.width * 0.6,
      height: size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _camBorderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: _camBorderColor.withOpacity(0.5),
            blurRadius: _seqState == _SeqState.waiting ? 15 : 10,
            spreadRadius: _seqState == _SeqState.waiting ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: _cameraActive
            ? AICamera(
          key: _camKey,
          modelPath: widget.data.exercise!.modelPath,
          labelsPath: widget.data.exercise!.labelsPath,
          useGpu: true,
          numThreads: 2,
          lensDirection: CameraLensDirection.front,
          intervalMs: 400,
          iouThreshold: 0.45,
          confThreshold: 0.35,
          classThreshold: 0.5,
          onDetections: _onDetections,
        )
            : const _SuccessGifPlaceholder(),
      ),
    );
  }

  Widget _buildCurrentInstructionText() {
    if (_idx >= _sequence.length) {
      return const SizedBox.shrink();
    }

    final currentAction = _sequence[_idx];
    final step = widget.data.exercise!.steps.firstWhere(
          (s) => _normalizeUz(s.action.toString()) == currentAction,
      orElse: () => widget.data.exercise!.steps.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bosqich ${_idx + 1}/${_sequence.length}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
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

  Widget _buildDetectionOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Aniqlangan harakat
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _currentBest != null
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentBest != null ? Icons.check_circle : Icons.hourglass_empty,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentBest != null ? "ANIQLANDI" : "KUTILMOQDA",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentBest != null
                            ? _extractLabel(_currentBest!).toUpperCase()
                            : "Harakatni bajaring...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (_currentBest != null) ...[
              const SizedBox(height: 16),

              // Ishonch darajasi
              _buildProgressRow(
                "Ishonch",
                _extractConfidence(_currentBest!),
                _getConfidenceColor(_extractConfidence(_currentBest!)),
              ),

              const SizedBox(height: 12),

              // Barqarorlik
              _buildProgressRow(
                "Barqarorlik",
                _stability,
                _getStabilityColor(_stability),
              ),
            ],

            // Vaqt
            if (_seqState == _SeqState.waiting && _idx < _sequence.length) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Qolgan vaqt: ${_getRemainingTime()}s",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
              color: Colors.white.withOpacity(0.7),
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
        SizedBox(
          width: 45,
          child: Text(
            "${(value * 100).toStringAsFixed(0)}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDebugPanel() {
    return Positioned(
      top: 100,
      right: 10,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                const Text(
                  "DEBUG PANEL",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.green, height: 16),

            // Video ma'lumotlari
            _debugSection("VIDEO", [
              _debugRow("Holat", _isVideoInitialized ? "✅ Tayyor" : "⏳ Yuklanmoqda"),
              _debugRow("Xatolik", _isVideoError ? "❌ Ha" : "✅ Yo'q"),
              if (_videoController != null && _isVideoInitialized)
                _debugRow("Ijro", _videoController!.value.isPlaying ? "▶️ Ha" : "⏸️ Yo'q"),
              if (_videoController != null && _isVideoInitialized)
                _debugRow("O'lcham", "${_videoController!.value.size.width.toInt()}x${_videoController!.value.size.height.toInt()}"),
            ]),

            const Divider(color: Colors.green, height: 16),

            // Mashq ma'lumotlari
            _debugSection("MASHQ", [
              _debugRow("Holat", _seqState.toString().split('.').last.toUpperCase()),
              _debugRow("Bosqich", "${_idx + 1}/${_sequence.length}"),
              _debugRow("Xatolar", "$_errors"),
              _debugRow("Kutilmoqda", _idx < _sequence.length ? _sequence[_idx] : "-"),
            ]),

            if (_currentBest != null) ...[
              const Divider(color: Colors.green, height: 16),
              _debugSection("DETEKSIYA", [
                _debugRow("Label", _extractLabel(_currentBest!)),
                _debugRow("Conf", "${(_extractConfidence(_currentBest!) * 100).toStringAsFixed(1)}%"),
                _debugRow("Stab", "${(_stability * 100).toStringAsFixed(1)}%"),
                _debugRow("Soni", "${_lastDetections.length}"),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _debugSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.green.shade300,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        ...children,
      ],
    );
  }

  Widget _debugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double conf) {
    if (conf >= 0.7) return Colors.green;
    if (conf >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Color _getStabilityColor(double stability) {
    if (stability >= 0.7) return Colors.green;
    if (stability >= 0.4) return Colors.yellow;
    return Colors.orange;
  }

  int _getRemainingTime() {
    final elapsed = DateTime.now().difference(_stepStartAt).inMilliseconds;
    final remaining = _stepTimeoutMs - elapsed;
    return (remaining / 1000).ceil().clamp(0, 999);
  }

  // ====== DETEKSIYA LOGIKASI ======

  void _onDetections(List<Map<String, dynamic>> results, Size imgSize) {
    _lastDetections = results;

    if (!mounted || results.isEmpty) {
      _currentBest = null;
      _stability = 0.0;
      if (mounted) setState(() {});
      return;
    }

    if (_seqState == _SeqState.success) return;

    Map<String, dynamic>? best;
    double bestConf = -1;

    for (final r in results) {
      final conf = _extractConfidence(r);
      if (conf > bestConf) {
        bestConf = conf;
        best = r;
      }
    }

    if (best == null) {
      _currentBest = null;
      _stability = 0.0;
      if (mounted) setState(() {});
      return;
    }

    _currentBest = best;
    final tag = _normalizeUz(_extractLabel(best));

    if (tag.isEmpty) {
      _stability = 0.0;
      if (mounted) setState(() {});
      return;
    }

    _maybeToast(tag);

    final expected = (_idx < _sequence.length) ? _sequence[_idx] : null;
    if (expected == null) return;

    final now = DateTime.now();
    _vote.add(label: tag, conf: bestConf, at: now);

    final votesForExpected = _vote.countLabel(expected);
    final avgConfExpected = _vote.avgConf(expected);
    final expectedFirstSeen = _vote.firstSeen(expected);

    final maxPossibleVotes = (_windowMs / 400).ceil();
    _stability = (votesForExpected / maxPossibleVotes).clamp(0.0, 1.0);

    if (mounted) setState(() {});

    final hasMinVotes = votesForExpected >= _minVotes;
    final hasMinConf = avgConfExpected >= _minAvgConf;
    final heldLongEnough = expectedFirstSeen != null &&
        now.difference(expectedFirstSeen) >= Duration(milliseconds: _minHoldMs);

    if (hasMinVotes && hasMinConf && heldLongEnough) {
      if (_lastAcceptedLabel == expected &&
          _lastAcceptedAt != null &&
          now.difference(_lastAcceptedAt!) < _acceptCooldown) {
        return;
      }

      _acceptStep(expected, now);
      return;
    }

    if (now.difference(_stepStartAt) >= Duration(milliseconds: _stepTimeoutMs)) {
      _timeoutStep(now);
    }
  }

  void _acceptStep(String expected, DateTime now) {
    debugPrint('✅ Bosqich qabul qilindi: $expected');

    _lastAcceptedAt = now;
    _lastAcceptedLabel = expected;
    _idx++;
    _seqState = _SeqState.waiting;
    _setBorderGreen();
    _vote.clear();
    _stepStartAt = now;
    _stability = 0.0;

    if (_idx >= _sequence.length) {
      debugPrint('🎉 Barcha bosqichlar bajarildi!');
      _seqState = _SeqState.success;

      if (mounted) {
        setState(() => _cameraActive = false);
      }

      _videoController?.pause();
      _showSuccessDialog();
      return;
    }

    _showStepInstruction();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted || _seqState == _SeqState.success) return;
      _setBorderNormal();
    });
  }

  void _timeoutStep(DateTime now) {
    debugPrint('⏰ Timeout: ${_sequence[_idx]}');

    _errors += 1;
    _seqState = _SeqState.waiting;
    _setBorderRed();

    Fluttertoast.showToast(
      msg: "⏰ Vaqt tugadi! Keyingi bosqich",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    _idx = (_idx + 1).clamp(0, _sequence.length);
    _vote.clear();
    _stepStartAt = now;
    _stability = 0.0;

    if (_idx >= _sequence.length) {
      _seqState = _SeqState.success;
      if (mounted) {
        setState(() => _cameraActive = false);
      }
      _videoController?.pause();
      _showSuccessDialog();
      return;
    }

    _showStepInstruction();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || _seqState == _SeqState.success) return;
      _setBorderNormal();
    });
  }

  double _extractConfidence(Map<String, dynamic> r) {
    final candidates = [
      r['confidence'],
      r['score'],
      r['conf'],
      if (r['box'] is List && (r['box'] as List).length > 4)
        (r['box'] as List)[4],
    ];

    for (final c in candidates) {
      if (c is num) return c.toDouble();
    }

    return 0.0;
  }

  String _extractLabel(Map<String, dynamic> r) {
    final candidates = [
      r['tag'],
      r['label'],
      r['className'],
      r['cls'],
      r['name'],
      r['class'],
    ];

    for (final c in candidates) {
      if (c != null) return c.toString();
    }

    return '';
  }

  void _setBorderNormal() {
    if (mounted) setState(() => _camBorderColor = const Color(0xff20B9E8));
  }

  void _setBorderGreen() {
    if (mounted) setState(() => _camBorderColor = Colors.green);
  }

  void _setBorderRed() {
    if (mounted) setState(() => _camBorderColor = Colors.red);
  }

  Future<void> _showSuccessDialog() async {
    final prov = context.read<LevelProvider>();
    final locked = prov.levels.firstWhere(
          (e) => e.locked,
      orElse: () => prov.levels.last,
    );

    int stars = 3;
    if (_errors == 1) {
      stars = 2;
    } else if (_errors > 1) {
      stars = 1;
    }

    prov.unlock(locked.id, stars);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green.shade400,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "🎉 Ajoyib!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "Siz barcha bosqichlarni\nmuvaffaqiyatli bajardingiz!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Statistika
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _statRow("Bosqichlar", "${_sequence.length}/${_sequence.length}", Icons.check_circle_outline),
                    const Divider(height: 16),
                    _statRow("Xatolar", "$_errors", Icons.error_outline,
                        color: _errors == 0 ? Colors.green : Colors.orange),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Yulduzlar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 48,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Tugma
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff20B9E8),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Davom etish",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey.shade600, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color ?? Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  String _normalizeUz(String s) {
    var t = s.toLowerCase();
    t = t
        .replaceAll(''', "'")
        .replaceAll('ʼ', "'")
        .replaceAll(''', "'")
        .replaceAll('`', "'")
        .replaceAll('ʻ', "'")
        .replaceAll('´', "'");
    t = t
        .replaceAll("o'", "o")
        .replaceAll("g'", "g");
    t = t.replaceAll(RegExp(r'\s+|\.'), '');
    return t;
  }

  void _maybeToast(String msg) {
    final now = DateTime.now();
    if (_lastToastAt == null ||
        now.difference(_lastToastAt!) > const Duration(milliseconds: 900)) {
      _lastToastAt = now;
      Fluttertoast.showToast(
        msg: "👁️ $msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

// ====== VOTING TIZIMI ======

class _VoteWindow {
  final int windowMs;
  final List<_Hit> _hits = [];

  _VoteWindow({required this.windowMs});

  void add({required String label, required double conf, required DateTime at}) {
    _hits.add(_Hit(label, conf, at));
    _trim(at);
  }

  void _trim(DateTime now) {
    final cutoff = now.subtract(Duration(milliseconds: windowMs));
    while (_hits.isNotEmpty && _hits.first.at.isBefore(cutoff)) {
      _hits.removeAt(0);
    }
  }

  int countLabel(String label) => _hits.where((h) => h.label == label).length;

  double avgConf(String label) {
    final list = _hits.where((h) => h.label == label).toList();
    if (list.isEmpty) return 0.0;
    final sum = list.fold<double>(0.0, (a, b) => a + b.conf);
    return sum / list.length;
  }

  DateTime? firstSeen(String label) {
    for (final h in _hits) {
      if (h.label == label) return h.at;
    }
    return null;
  }

  void clear() => _hits.clear();
}

class _Hit {
  final String label;
  final double conf;
  final DateTime at;
  _Hit(this.label, this.conf, this.at);
}

// ====== SUCCESS PLACEHOLDER ======

class _SuccessGifPlaceholder extends StatelessWidget {
  const _SuccessGifPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "✅ Yakunlandi",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}