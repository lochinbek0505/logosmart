import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/storage/level_state.dart';
import '../widgets/Custom3dButton.dart';
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

  final double _minConfidencePerVote = 0.60;
  final int _requiredFrames = 3;
  final double _requiredAvgConfidence = 0.60;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  String? _currentVideoPath;

  List<Map<String, dynamic>> _lastDetections = [];
  Map<String, dynamic>? _currentBest;
  bool _showDebugPanel = false;

  late List<ExerciseStep> _steps;
  int _currentStepIndex = 0;
  int _completedCycles = 1;
  final int _totalCycles = 1;

  List<double> _confidenceVotes = [];
  int _currentFrameCount = 0;
  bool _isProcessingVote = false;

  Color _cameraBoxBorderColor = const Color(0xff20B9E8);
  bool _showSuccessAnimation = false;
  String _feedbackMessage = '';

  bool _isExerciseCompleted = false;
  bool _waitingForNextStep = false;

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
    _logSteps();
    _initializeVideo();
  }

  void _logSteps() {
    for (int i = 0; i < _steps.length; i++) {
      debugPrint('  [$i] ${_steps[i].text} (action: ${_steps[i].action})');
    }
  }

  Widget _buildCycleProgress(Size size) {
    double progressValue = _totalCycles > 0
        ? _completedCycles / _totalCycles
        : 0;
    bool isCompleted = _completedCycles == _totalCycles;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 3,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 3,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? Colors.greenAccent
                          : const Color(0xff20B9E8),
                    ),
                  ),
                  Icon(
                    isCompleted ? Icons.check : Icons.loop,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isCompleted ? "Yakunlandi" : "Bosqich",
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 14,
              color: Colors.blue.withOpacity(0.3),
            ),
            const SizedBox(width: 8),
            Text(
              '$_completedCycles/$_totalCycles',
              style: TextStyle(
                color: isCompleted ? Colors.greenAccent : Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetections(List<Map<String, dynamic>> results, Size imgSize) {
    _lastDetections = results;
    _updateFps();

    // ✅ KRITIK: Tsikllar tugaganda deteksiyani BUTUNLAY to'xtatish
    if (!mounted ||
        results.isEmpty ||
        _waitingForNextStep ||
        _isExerciseCompleted ||
        _isProcessingVote ||
        _completedCycles >= _totalCycles ||
        !_cameraActive) {
      return;
    }

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

      String expectedAction = _steps[_currentStepIndex].action;

      if (label.toLowerCase().contains(expectedAction.toLowerCase())) {
        if (conf >= _minConfidencePerVote) {
          _currentFrameCount++;
          _confidenceVotes.add(conf);

          debugPrint(
            '✅ FRAME ${_currentFrameCount}/$_requiredFrames: '
            'conf=${(conf * 100).toStringAsFixed(1)}% | '
            'action="$label"',
          );

          if (_currentFrameCount >= _requiredFrames) {
            _processFrameVotingResult();
          }
        }
      } else {
        if (_currentFrameCount > 0) {
          _resetFrameVoting();
        }
      }

      if (mounted) setState(() {});
    }
  }

  void _updateFps() {
    _frameCount++;
    final now = DateTime.now();
    final duration = now.difference(_lastFpsUpdate);

    if (duration.inMilliseconds >= 1000) {
      _currentFps = _frameCount / (duration.inMilliseconds / 1000);
      _frameCount = 0;
      _lastFpsUpdate = now;
      if (mounted) setState(() {});
    }
  }

  void _processFrameVotingResult() {
    if (_isProcessingVote) return;
    _isProcessingVote = true;

    if (_confidenceVotes.length < _requiredFrames) {
      _onStepFailure();
      _resetFrameVoting();
      return;
    }

    double avgConfidence =
        _confidenceVotes.reduce((a, b) => a + b) / _confidenceVotes.length;

    bool voteSuccessful = avgConfidence >= _requiredAvgConfidence;

    if (voteSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ TO\'G\'RI:  Avg=${(avgConfidence * 100).toStringAsFixed(1)}%',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 800),
        ),
      );
      _onStepSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ QAYTA: Avg=${(avgConfidence * 100).toStringAsFixed(1)}%',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 800),
        ),
      );
      _onStepFailure();
    }

    _resetFrameVoting();
  }

  void _resetFrameVoting() {
    _isProcessingVote = false;
    _currentFrameCount = 0;
    _confidenceVotes.clear();
  }

  void _onStepSuccess() {
    setState(() {
      _cameraBoxBorderColor = Colors.green;
      _showSuccessAnimation = true;
      _feedbackMessage = '✅ To\'g\'ri! ';
    });

    Fluttertoast.showToast(
      msg: '✅ To\'g\'ri bajarildi!',
      backgroundColor: Colors.green,
    );

    _moveToNextStep();
  }

  void _onStepFailure() {
    setState(() {
      _cameraBoxBorderColor = Colors.red;
      _feedbackMessage = '❌ Qayta urinib ko\'ring';
    });

    Fluttertoast.showToast(msg: '❌ Noto\'g\'ri', backgroundColor: Colors.red);

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
      } else {
        _completedCycles++;

        if (_completedCycles < _totalCycles) {
          setState(() {
            _currentStepIndex = 0;
            _cameraBoxBorderColor = const Color(0xff20B9E8);
            _showSuccessAnimation = false;
            _feedbackMessage = '';
            _waitingForNextStep = false;
          });
        } else {
          _onAllCyclesCompleted();
        }
      }
    });
  }

  void _onAllCyclesCompleted() {
    debugPrint('🎉 BARCHA TSIKLLAR YAKUNLANDI!');

    // ✅ 1.  AVVAL kamerani o'chirish (eng muhim!)
    if (mounted) {
      setState(() {
        _cameraActive = false; // ← Bu model inference ni to'xtatadi
        _isExerciseCompleted = true;
        _showSuccessAnimation = false;
        _feedbackMessage = '';
      });
    }

    // ✅ 2. Kamera to'xtagandan keyin video ni pause qilish
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        _videoController?.pause();
        debugPrint('⏸️ Video to\'xtatildi');
      } catch (e) {
        debugPrint('⚠️ Video pause xatolik: $e');
      }

      Fluttertoast.showToast(
        msg: '🎉 Barcha tsikllar yakunlandi!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
      );
    });
  }

  Future<void> _initializeVideo() async {
    try {
      _currentVideoPath =
          widget.data.exercise?.mediaPath ?? 'assets/video. mp4';
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
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Video xatolik: $e\n$stackTrace');

      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _isVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 CameraPage dispose');

    // ✅ AVVAL kamerani o'chirish
    _cameraActive = false;

    // ✅ Keyin video ni tozalash
    try {
      _videoController?.removeListener(() {});
      _videoController?.pause();
      _videoController?.dispose();
      _videoController = null;
    } catch (e) {
      debugPrint('⚠️ Video dispose xatolik: $e');
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (_completedCycles < _totalCycles && !_isExerciseCompleted) {
      _safeRestartVideo();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      try {
        _videoController?.pause();
      } catch (e) {}

      if (_cameraActive && mounted) {
        setState(() => _cameraActive = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_completedCycles >= _totalCycles || _isExerciseCompleted) {
        return;
      }

      if (_isVideoInitialized && _videoController != null) {
        try {
          _videoController!.play();
        } catch (e) {}
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
      if (mounted) _initializeVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (mounted) {
          setState(() => _cameraActive = false);
        }
        // ✅ Kamera to'xtagandan keyin video pause
        await Future.delayed(const Duration(milliseconds: 300));
        try {
          _videoController?.pause();
        } catch (e) {}
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

              TopBar(
                onBack: () {
                  if (mounted) setState(() => _cameraActive = false);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    try {
                      _videoController?.pause();
                    } catch (e) {}
                  });
                  Navigator.of(context).pop();
                },
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: size.width, height: 120),
                  _buildCycleProgress(size),

                  VideoBox(
                    size: size,
                    isVideoInitialized:
                        (_completedCycles >= _totalCycles ||
                            _isExerciseCompleted)
                        ? false
                        : _isVideoInitialized,
                    isVideoError: _isVideoError,
                    currentVideoPath: _currentVideoPath,
                    videoController: _videoController,
                    showDebugPanel: _showDebugPanel,
                    onRetry: _initializeVideo,
                  ),

                  const SizedBox(height: 15),

                  _buildCameraBoxWithBorder(size),

                  const SizedBox(height: 15),

                  if (_completedCycles < _totalCycles &&
                      !_isExerciseCompleted &&
                      _currentStepIndex < _steps.length)
                    InstructionText(
                      stepNumber: _currentStepIndex + 1,
                      totalSteps: _steps.length,
                      instructionText: _steps.isNotEmpty
                          ? _steps[_currentStepIndex].text
                          : 'Steps topilmadi',
                    ),

                  if (_completedCycles >= _totalCycles || _isExerciseCompleted)
                    const Custom3DButton(),
                ],
              ),

              if (_showDebugPanel)
                DebugPanel(
                  isVideoInitialized: _isVideoInitialized,
                  isVideoError: _isVideoError,
                  videoController: _videoController,
                  currentBest: _currentBest,
                  lastDetections: _lastDetections,
                ),

              if (_currentBest != null &&
                  _completedCycles < _totalCycles &&
                  !_isExerciseCompleted &&
                  _cameraActive)
                DetectionOverlay(
                  currentBest: _currentBest,
                  onExtractLabel: _extractLabel,
                  onExtractConfidence: _extractConfidence,
                ),

              if (_showDebugPanel) _buildDebugInfo(),

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
    bool shouldStopCamera =
        _completedCycles >= _totalCycles || _isExerciseCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size.width * 0.6,
      height: size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: shouldStopCamera ? Colors.green : _cameraBoxBorderColor,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (shouldStopCamera ? Colors.green : _cameraBoxBorderColor)
                .withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        // ✅ KRITIK: shouldStopCamera true bo'lsa CameraBox widgetini UMUMAN render qilmaslik
        child: shouldStopCamera
            ? Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.celebration, color: Colors.green, size: 60),
                ),
              )
            : (_cameraActive
                  ? CameraBox(
                      size: Size(size.width * 0.6, size.width * 0.6),
                      cameraActive: true,
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
                    )),
      ),
    );
  }

  Widget _buildDebugInfo() {
    double avgConf = _confidenceVotes.isEmpty
        ? 0
        : _confidenceVotes.reduce((a, b) => a + b) / _confidenceVotes.length;

    return Positioned(
      top: 200,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _row(
              '📍',
              '${_currentStepIndex + 1}/${_steps.length}',
              Colors.cyan,
            ),
            _row('🔄', '$_completedCycles/$_totalCycles', Colors.purple),
            _row(
              '📊',
              '$_currentFrameCount/$_requiredFrames',
              _currentFrameCount >= _requiredFrames
                  ? Colors.green
                  : Colors.orange,
            ),
            _row(
              '⚡',
              '${(avgConf * 100).toStringAsFixed(0)}%',
              avgConf >= _requiredAvgConfidence ? Colors.green : Colors.yellow,
            ),
            _row(
              '📸',
              '${_currentFps.toStringAsFixed(0)}',
              _currentFps < 15 ? Colors.red : Colors.green,
            ),
            _row(
              '📷',
              _cameraActive ? 'ON' : 'OFF',
              _cameraActive ? Colors.green : Colors.red,
            ),
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
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
}
