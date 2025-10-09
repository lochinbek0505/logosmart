import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/storage/level_state.dart';

class BreathPage extends StatefulWidget {
  final LevelState data;

  BreathPage({super.key, required this.data});

  @override
  State<BreathPage> createState() => _BreathPageState();
}

class _BreathPageState extends State<BreathPage> {
  late VideoPlayerController _video;
  bool _videoReady = false;

  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSub;

  bool _sessionActive = false; // 2s seans davom etyaptimi
  Timer? _sessionTimer;

  // Puflash sezgirligi (kuchsiz atrof shovqindan balandroq bo‘lishi kerak)
  // noise_meter odatda dB(A) beradi. -40..-30 dB past, -25..-10 dB kuchliroq.
  // Qurilmaga qarab moslab oling.
  static const double _thresholdDb = -25.0;

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.asset('assets/media/parrak.mp4')
      ..setLooping(true)
      ..initialize().then((_) async {
        await _video.pause();
        if (mounted) setState(() => _videoReady = true);
      });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _noiseSub?.cancel();
    _noiseMeter = null;
    _video.dispose();
    super.dispose();
  }

  Future<void> _startBlowSession() async {
    if (_sessionActive) return;

    final micOk = await _ensureMicPermission();
    if (!micOk) return;

    _sessionActive = true;
    _noiseMeter ??= NoiseMeter();
    _noiseSub = _noiseMeter!.noise.listen(_onNoise);

    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(seconds: 2), _endBlowSession);

    setState(() {});
  }

  void _endBlowSession() async {
    if (!_sessionActive) return;
    _sessionActive = false;

    await _noiseSub?.cancel();
    _noiseSub = null;

    await _video.pause();

    setState(() {});
  }

  void _onNoise(NoiseReading reading) async {
    if (!_sessionActive) return;

    final db = reading.meanDecibel;
    if (db != null && db > _thresholdDb) {
      if (!_video.value.isPlaying) await _video.play();
    } else {
      if (_video.value.isPlaying) await _video.pause();
    }
  }

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _pauseManually() async {
    await _video.pause();
    if (_sessionActive) {
      await _noiseSub?.cancel();
      _noiseSub = null;
      _sessionActive = false;
      _sessionTimer?.cancel();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background video (paused by default, plays only while blowing)
            if (_videoReady)
              FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _video.value.size.width,
                  height: _video.value.size.height,
                  child: VideoPlayer(_video),
                ),
              )
            else
              const ColoredBox(color: Colors.black),

            Column(
              children: [
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 6),
                    // Mic button: start 2s session; play only while blowing
                    GestureDetector(
                      onTap: _startBlowSession,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: const AssetImage(
                          "assets/icons/circle.png",
                        ),
                        child: Transform.translate(
                          offset: const Offset(0, -1),
                          child: Image.asset(
                            "assets/icons/micrafon.png",
                            width: 26,
                            height: 38,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Pause button: always pause
                    GestureDetector(
                      onTap: _pauseManually,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: const AssetImage(
                          "assets/icons/circle.png",
                        ),
                        child: Transform.translate(
                          offset: const Offset(0, -1),
                          child: Image.asset(
                            "assets/icons/pause.png",
                            width: 23,
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),

            // Small status pill
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 12,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _sessionActive
                      ? Colors.green.withOpacity(0.85)
                      : Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _sessionActive ? "Seans: 2s ichida puflang" : "Tayyor",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
