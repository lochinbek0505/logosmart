import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/storage/level_state.dart';
import '../widgets/camera_box.dart';
import '../widgets/debug_panel.dart';
import '../widgets/detection_overlay.dart';
import '../widgets/instruction_text.dart';
import '../widgets/top_bar.dart';
import '../widgets/video_box.dart';

class CameraPage extends StatefulWidget {
  final LevelState data;

  const CameraPage({super.key, required this.data});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  Key _camKey = UniqueKey();
  bool _cameraActive = true;

  // ====== FRAME-BASED VOTING SOZLAMALARI ======
  final double _minConfidencePerVote =
      0.60; // ✅ 60% dan yuqori ovlarni qabul qilish
  final int _requiredFrames = 3; // ✅ 3 ta frame kerak
  final double _requiredAvgConfidence =
      0.60; // ✅ O'rtacha 65% dan yuqori bo'lishi kerak

  // ====== VIDEO CONTROLLER ======
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  String? _currentVideoPath;

  List<Map<String, dynamic>> _lastDetections = [];
  Map<String, dynamic>? _currentBest;
  bool _showDebugPanel = false;

  // ====== KETMA-KETLIK NAZORATI ======
  late List<ExerciseStep> _steps;
  int _currentStepIndex = 0;
  int _completedCycles = 0;
  final int _totalCycles = 7;

  // ====== FRAME-BASED VOTING TIZIMI ======
  List<double> _confidenceVotes = [];
  int _currentFrameCount = 0; // Joriy frame hisoblagich
  bool _isProcessingVote = false;

  // ====== VIZUAL FEEDBACK ======
  Color _cameraBoxBorderColor = const Color(0xff20B9E8);
  bool _showSuccessAnimation = false;
  String _feedbackMessage = '';

  // ====== MASHQ SOZLAMALARI ======
  bool _isExerciseCompleted = false;
  bool _waitingForNextStep = false;

  // ====== FPS TRACKING ======
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  double _currentFps = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _steps = widget.data.exercise?.steps ?? [];

    if (_steps.isEmpty) {
      debugPrint('❌ Steps topilmadi');
      return;
    }

    debugPrint('🎯 Ketma-ketlik boshlandi:  ${_steps.length} ta bosqich');
    debugPrint('📊 Frame-based Voting sozlamalari: ');
    debugPrint(
      '  - Minimal konfidenslik: $_minConfidencePerVote (${(_minConfidencePerVote * 100).toInt()}%)',
    );
    debugPrint('  - Kerakli frame lar: $_requiredFrames ta');
    debugPrint(
      '  - O\'rtacha talabi: $_requiredAvgConfidence (${(_requiredAvgConfidence * 100).toInt()}%)',
    );
    _logSteps();

    _initializeVideo();
  }

  void _logSteps() {
    for (int i = 0; i < _steps.length; i++) {
      debugPrint('  [$i] ${_steps[i].text} (action: ${_steps[i].action})');
    }
  }

  // ====== DETEKSIYA LOGIKASI ======

  void _onDetections(List<Map<String, dynamic>> results, Size imgSize) {
    _lastDetections = results;

    // FPS hisoblash
    _updateFps();

    if (!mounted ||
        results.isEmpty ||
        _waitingForNextStep ||
        _isExerciseCompleted ||
        _isProcessingVote) {
      return;
    }

    // Eng yaxshi deteksiyani topish
    Map<String, dynamic>? best;
    double bestConf = -1;

    for (final r in results) {
      final conf = _extractConfidence(r);
      if (conf > bestConf) {
        bestConf = conf;
        best = r;
      }
    }

    if (best != null) {
      _currentBest = best;
      double conf = _extractConfidence(best);
      String label = _extractLabel(best);

      // Kutilgan harakat bilan solishtirish
      String expectedAction = _steps[_currentStepIndex].action;

      if (label.toLowerCase().contains(expectedAction.toLowerCase())) {
        // ✅ Faqat 60% dan yuqori ovlarni qabul qilish
        if (conf >= _minConfidencePerVote) {
          _currentFrameCount++;
          _confidenceVotes.add(conf);

          debugPrint(
            '✅ FRAME ${_currentFrameCount}/$_requiredFrames: '
            'conf=${(conf * 100).toStringAsFixed(1)}% | '
            'action="$label"',
          );

          // ✅ Kerakli framelar yig'ilganda tekshirish
          if (_currentFrameCount >= _requiredFrames) {
            _processFrameVotingResult();
          }
        } else {
          debugPrint(
            '⏭️ FRAME RAD: conf=${(conf * 100).toStringAsFixed(1)}% '
            '(< ${(_minConfidencePerVote * 100).toStringAsFixed(1)}%)',
          );
        }
      } else {
        // ❌ Noto'g'ri harakat - frame lar ni reset qilish
        if (_currentFrameCount > 0) {
          debugPrint(
            '❌ NOTO\'G\'RI HARAKAT: "$label" != "$expectedAction" | '
            'Frame lar reset qilindi (${_currentFrameCount} ta)',
          );
          _resetFrameVoting();
        }
      }

      if (mounted) setState(() {});
    }
  }

  /// FPS ni yangilash
  void _updateFps() {
    _frameCount++;
    final now = DateTime.now();
    final duration = now.difference(_lastFpsUpdate);

    if (duration.inMilliseconds >= 1000) {
      _currentFps = _frameCount / (duration.inMilliseconds / 1000);
      debugPrint('📸 Kamera FPS: ${_currentFps.toStringAsFixed(1)} fps');

      _frameCount = 0;
      _lastFpsUpdate = now;

      if (mounted) setState(() {});
    }
  }

  /// Frame-based voting natijasini qayta ishlash
  void _processFrameVotingResult() {
    if (_isProcessingVote) {
      debugPrint('⚠️ Allaqachon processing, skip');
      return;
    }

    _isProcessingVote = true;

    debugPrint('\n📊 ========== FRAME VOTING NATIJASI ==========');

    // 1-TEKSHIRUV:  Frame lar soni to'g'rimi?
    if (_confidenceVotes.length < _requiredFrames) {
      debugPrint('❌ KAM FRAME LAR: ');
      debugPrint('  Hozirgi:  ${_confidenceVotes.length} ta');
      debugPrint('  Talab: $_requiredFrames ta');
      _onStepFailure();
      _resetFrameVoting();
      return;
    }

    // 2-TEKSHIRUV: O'rtacha konfidenslik yetarlimi?
    double avgConfidence =
        _confidenceVotes.reduce((a, b) => a + b) / _confidenceVotes.length;

    debugPrint('📈 FRAME TAHLILI:');
    debugPrint('  Frame lar: ${_confidenceVotes.length} ta');
    debugPrint(
      '  Konfidensliklar: ${_confidenceVotes.map((e) => '${(e * 100).toStringAsFixed(0)}%').join(', ')}',
    );
    debugPrint('  O\'rtacha: ${(avgConfidence * 100).toStringAsFixed(1)}%');
    debugPrint(
      '  Talab: ${(_requiredAvgConfidence * 100).toStringAsFixed(1)}%',
    );

    bool voteSuccessful = avgConfidence >= _requiredAvgConfidence;

    if (voteSuccessful) {
      debugPrint('✅ QABUL QILINDI! ');
      debugPrint(
        '  Sabab:  Avg ${(avgConfidence * 100).toStringAsFixed(1)}% >= ${(_requiredAvgConfidence * 100).toStringAsFixed(1)}%',
      );
      debugPrint('============================================\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ TO\'G\'RI:  Avg=${(avgConfidence * 100).toStringAsFixed(1)}% ($_requiredFrames frame)',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 800),
        ),
      );

      _onStepSuccess();
    } else {
      debugPrint('❌ RAD ETILDI! ');
      debugPrint(
        '  Sabab:  Avg ${(avgConfidence * 100).toStringAsFixed(1)}% < ${(_requiredAvgConfidence * 100).toStringAsFixed(1)}%',
      );
      debugPrint('============================================\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ QAYTA:  Avg=${(avgConfidence * 100).toStringAsFixed(1)}% < ${(_requiredAvgConfidence * 100).toStringAsFixed(1)}%',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 800),
        ),
      );

      _onStepFailure();
    }

    _resetFrameVoting();
  }

  /// Frame voting holatini qayta tiklash
  void _resetFrameVoting() {
    debugPrint('🔄 Frame voting holati qayta tiklanmoqda.. .');
    _isProcessingVote = false;
    _currentFrameCount = 0;
    _confidenceVotes.clear();
  }

  /// Bosqich muvaffaqiyatli
  void _onStepSuccess() {
    debugPrint(
      '✅ Bosqich muvaffaqiyatli!  Action: ${_steps[_currentStepIndex].action}',
    );

    setState(() {
      _cameraBoxBorderColor = Colors.green;
      _showSuccessAnimation = true;
      _feedbackMessage = '✅ To\'g\'ri! ';
    });

    Fluttertoast.showToast(
      msg: '✅ To\'g\'ri bajarildi! ',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    _moveToNextStep();
  }

  /// Bosqich muvaffaqiyatsiz
  void _onStepFailure() {
    debugPrint('❌ Bosqich muvaffaqiyatsiz.  Qayta urinib ko\'ring');

    setState(() {
      _cameraBoxBorderColor = Colors.red;
      _feedbackMessage = '❌ Qayta urinib ko\'ring';
    });

    Fluttertoast.showToast(
      msg: '❌ Noto\'g\'ri, qayta urinib ko\'ring',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _cameraBoxBorderColor = const Color(0xff20B9E8);
          _showSuccessAnimation = false;
          _feedbackMessage = '';
        });
      }
    });
  }

  /// Keyingi bosqichga o'tish
  void _moveToNextStep() {
    _waitingForNextStep = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (_currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex++;
          _cameraBoxBorderColor = const Color(0xff20B9E8);
          _showSuccessAnimation = false;
          _feedbackMessage = '';
          _waitingForNextStep = false;
        });
        debugPrint('➡️ Keyingi bosqichga o\'tildi:  $_currentStepIndex');
      } else {
        _completedCycles++;
        debugPrint('🔄 Tsikl tugadi: $_completedCycles / $_totalCycles');

        if (_completedCycles < _totalCycles) {
          setState(() {
            _currentStepIndex = 0;
            _cameraBoxBorderColor = const Color(0xff20B9E8);
            _showSuccessAnimation = false;
            _feedbackMessage = '';
            _waitingForNextStep = false;
          });
          debugPrint(
            '♻️ Yangi tsikl boshlandi: $_completedCycles / $_totalCycles',
          );
        } else {
          _onAllExercisesCompleted();
        }
      }
    });
  }

  /// Barcha mashqlar tugaganda
  void _onAllExercisesCompleted() {
    debugPrint('🎉 MASHQ YAKUNLANDI!  7 marta to\'liq ketma-ketlik');

    setState(() {
      _isExerciseCompleted = true;
      _cameraActive = false;
      _showSuccessAnimation = false;
      _feedbackMessage = '🎉 Tabriklaymiz! ';
    });

    _videoController?.pause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Ajoyib! ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Siz barcha mashqlarni muvaffaqiyatli bajardingiz!\n\n'
          'Jami: $_totalCycles marta to\'liq ketma-ketlik',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Tayyor',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// MP4 video faylni yuklash va sozlash
  Future<void> _initializeVideo() async {
    try {
      _currentVideoPath =
          widget.data.exercise?.mediaPath ?? 'assets/video. mp4';

      debugPrint('🎬 MP4 video yuklanmoqda:  $_currentVideoPath');

      await _videoController?.dispose();

      _videoController = VideoPlayerController.asset(
        _currentVideoPath!,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      _videoController!.addListener(() {
        if (_videoController!.value.hasError) {
          debugPrint(
            '❌ Video xatolik: ${_videoController!.value.errorDescription}',
          );
          if (mounted) {
            setState(() {
              _isVideoError = true;
              _isVideoInitialized = false;
            });
          }
        }
      });

      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoError = false;
        });

        await _videoController!.setLooping(true);
        await _videoController!.setVolume(0.0);
        await _videoController!.play();

        debugPrint('▶️ Video ijro etilmoqda (loop: true)');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Video yuklashda xatolik: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _isVideoError = true;
        });

        Fluttertoast.showToast(
          msg: '⚠️ Video yuklashda xatolik',
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
    debugPrint('🧹 CameraPage dispose qilinmoqda.. .');

    _videoController?.removeListener(() {});
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _safeRestartVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 App lifecycle o\'zgardi: $state');

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _videoController?.pause();

      if (_cameraActive) {
        setState(() => _cameraActive = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isVideoInitialized && _videoController != null) {
        _videoController!.play();
      } else {
        _initializeVideo();
      }

      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_isExerciseCompleted) {
          setState(() {
            _camKey = UniqueKey();
            _cameraActive = true;
          });
        }
      });
    }
  }

  void _safeRestartVideo() {
    if (!mounted) return;

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
          backgroundColor: _showDebugPanel
              ? Colors.red
              : const Color(0xff20B9E8),
          onPressed: () {
            setState(() => _showDebugPanel = !_showDebugPanel);
          },
          child: Icon(
            _showDebugPanel ? Icons.bug_report : Icons.bug_report_outlined,
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
                    image: AssetImage('assets/images/backround_xira.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              // Yuqori panel
              TopBar(
                onBack: () {
                  if (mounted) setState(() => _cameraActive = false);
                  _videoController?.pause();
                  Navigator.of(context).pop();
                },
              ),

              // Markaziy content
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: size.width, height: 150),

                  // MP4 Video player
                  VideoBox(
                    size: size,
                    isVideoInitialized: _isVideoInitialized,
                    isVideoError: _isVideoError,
                    currentVideoPath: _currentVideoPath,
                    videoController: _videoController,
                    showDebugPanel: _showDebugPanel,
                    onRetry: _initializeVideo,
                  ),

                  const SizedBox(height: 15),

                  // Tsikl progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Tsikl:  $_completedCycles / $_totalCycles',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Kamera (rings bilan)
                  _buildCameraBoxWithBorder(size),

                  const SizedBox(height: 15),

                  // Ko'rsatma
                  InstructionText(
                    stepNumber: _currentStepIndex + 1,
                    totalSteps: _steps.length,
                    instructionText: _steps.isNotEmpty
                        ? _steps[_currentStepIndex].text
                        : 'Steps topilmadi',
                  ),
                ],
              ),

              // Debug panel
              if (_showDebugPanel)
                DebugPanel(
                  isVideoInitialized: _isVideoInitialized,
                  isVideoError: _isVideoError,
                  videoController: _videoController,
                  currentBest: _currentBest,
                  lastDetections: _lastDetections,
                ),

              // Deteksiya overlay
              if (_currentBest != null)
                DetectionOverlay(
                  currentBest: _currentBest,
                  onExtractLabel: _extractLabel,
                  onExtractConfidence: _extractConfidence,
                ),

              // Debug ma'lumotlari
              if (_showDebugPanel) _buildDebugInfo(),

              // Feedback message
              if (_feedbackMessage.isNotEmpty)
                Positioned(
                  top: size.height * 0.35,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _cameraBoxBorderColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _feedbackMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildCameraBoxWithBorder(Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size.width * 0.6,
      height: size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cameraBoxBorderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: _cameraBoxBorderColor.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: _cameraActive
            ? CameraBox(
                size: Size(size.width * 0.6, size.width * 0.6),
                cameraActive: _cameraActive,
                camKey: _camKey,
                modelPath: widget.data.exercise!.modelPath,
                labelsPath: widget.data.exercise!.labelsPath,
                onDetections: _onDetections,
              )
            : Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDebugInfo() {
    double avgConf = _confidenceVotes.isEmpty
        ? 0
        : _confidenceVotes. reduce((a, b) => a + b) / _confidenceVotes.length;

    return Positioned(
      top: 200,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.cyan.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('📍', '${_currentStepIndex + 1}/${_steps.length}', Colors.cyan),
            _row('🔄', '${_completedCycles}/${_totalCycles}', Colors.purple),
            _row('📊', '$_currentFrameCount/$_requiredFrames',
                _currentFrameCount >= _requiredFrames ? Colors. green : Colors.orange),
            _row('⚡', '${(avgConf * 100).toStringAsFixed(0)}%',
                avgConf >= _requiredAvgConfidence ? Colors.green : Colors. yellow),
            _row('📸', '${_currentFps. toStringAsFixed(0)}',
                _currentFps < 15 ? Colors.red : Colors. green),
          ],
        ),
      ),
    );
  }

  Widget _row(String icon, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            value,
            style:  TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight. bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget _infoChip(String text, Color color, {String? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon, style: TextStyle(fontSize: 9)),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ====== DETEKSIYA HELPER FUNKSIYALARI ======

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
}
