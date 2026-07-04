import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/diagnostic/advise_alphabet_page.dart';
import 'package:logosmart/ui/pages/diagnostic/diagnostic_end_page.dart';
import 'package:logosmart/ui/pages/diagnostic/diagnostic_start_page.dart';
import 'package:logosmart/ui/pages/diagnostic/provider/voice_diagnostic_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:shiny_striped_progress_bar/shiny_striped_progress_bar.dart';

import '../../../../core/service/uzbekvoice_stt_service.dart';
import '../../../../models/diagnostic_group_model.dart';
import '../../theme/app_colors.dart';

class VoiceDiagnosticPage extends StatefulWidget {
  List<Template>? templatesList;

  VoiceDiagnosticPage({super.key, this.templatesList});

  @override
  State<VoiceDiagnosticPage> createState() => _VoiceDiagnosticPageState();
}

class _VoiceDiagnosticPageState extends State<VoiceDiagnosticPage>
    with TickerProviderStateMixin {
  final heights = [4.0, 6.0, 8.0, 11.0, 15.0, 21.0, 28.0, 33.0, 36.0];

  int activeBars = 0;

  late AudioPlayer _audioPlayer;

  final _recorder = AudioRecorder();

  final _stt = UzbekVoiceSttService();

  final _player = AudioPlayer();

  late AnimationController _errorWobbleCtrl;

  late Animation<double> _errorShakeX;

  late Animation<double> _errorRotate;

  bool _isRecording = false;

  String? _lastText;

  bool _isImageReady = false;

  bool _isMicReady = false;

  bool _isAskingGirl = false;

  late AnimationController _pulse;

  late Animation<double> _scale;

  double _maxAmplitude = -160.0;

  late AnimationController _bounce;

  late Animation<double> _bounceAnim;

  late Animation<Color?> _colorAnim;

  late AnimationController _imageFloat;

  late Animation<double> _imageFloatAnim;

  late AnimationController _errorAnimCtrl;

  late Animation<double> _errorOpacity;

  late Animation<double> _errorScale;

  late ConfettiController _confettiCtrl;

  StreamSubscription<Amplitude>? _ampSub;

  int _audioState = 0;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 800),
    );

    _scale = Tween<double>(
      begin: 1.0,

      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _bounce = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 600),
    );

    _bounceAnim = Tween<double>(
      begin: 0,

      end: -6,
    ).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));

    _colorAnim = ColorTween(
      begin: const Color(0xFF7CFFB2),

      end: const Color(0xFFFF7C7C),
    ).animate(_pulse);

    _imageFloat = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _imageFloatAnim = Tween<double>(
      begin: -6,

      end: 6,
    ).animate(CurvedAnimation(parent: _imageFloat, curve: Curves.easeInOut));

    _errorWobbleCtrl = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _errorShakeX = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _errorWobbleCtrl, curve: Curves.easeInOut),
    );

    _errorRotate = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _errorWobbleCtrl, curve: Curves.easeInOut),
    );

    _errorAnimCtrl = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 2200),
    );

    _errorOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),

      TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),

      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _errorAnimCtrl, curve: Curves.easeOut));

    _errorScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.1), weight: 20),

      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 80),
    ]).animate(CurvedAnimation(parent: _errorAnimCtrl, curve: Curves.easeOut));

    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceDiagnosticProvider>().init(widget.templatesList ?? []);

      _playMicOnSound();
    });

    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerComplete.listen((event) async {
      if (mounted) {
        if (_audioState == 1) {
          _startItemSequence();
        } else if (_audioState == 2) {
          setState(() {
            _audioState = 3;
            _isMicReady = true;
          });

          // 2. Yozishni boshlaymiz
          await _toggleRecord();

          // 3. To'liq 2 sekund kutamiz
          await Future.delayed(const Duration(seconds: 3));

          // 4. Agar foydalanuvchi hali ham shu sahifada bo'lsa va yozish davom etayotgan bo'lsa, o'chiramiz
          if (mounted && _isRecording) {
            await _toggleRecord();
          }
        }
      }
    });

    _player.onPlayerComplete.listen((event) {
      if (mounted && _isAskingGirl) {
        setState(() {
          _isAskingGirl = false;
        });
        _startItemSequence();
      }
    });
  }

  void _startItemSequence() async {
    setState(() {
      _isMicReady = false;

      _isImageReady = true;
    });

    final provider = context.read<VoiceDiagnosticProvider>();

    final item = provider.currentTemplate?.itemsList?.first;

    if (item != null && item.voiceFile != null && item.voiceFile!.isNotEmpty) {
      _audioState = 2;

      await _audioPlayer.play(
        AssetSource("sound/diagnostic/${item.voiceFile}"),
      );
    } else {
      _playMicOnSound();
    }
  }

  void _playMicOnSound() async {
    setState(() {
      _isMicReady = false;

      _isImageReady = true;
    });

    _audioState = 1;

    await _audioPlayer.play(AssetSource('sound/microphone_on.mp3'));
  }

  @override
  void dispose() {
    _ampSub?.cancel();

    _pulse.dispose();

    _errorWobbleCtrl.dispose();

    _bounce.dispose();

    _imageFloat.dispose();

    _errorAnimCtrl.dispose();

    _confettiCtrl.dispose();

    _recorder.dispose();

    _player.dispose();

    _audioPlayer.dispose();

    super.dispose();
  }

  int _barsFromAmplitude(double? amp) {
    final value = amp ?? -160;

    final normalized = ((value + 160) / 160).clamp(0.0, 1.0);

    return (normalized * heights.length).round().clamp(0, heights.length);
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      final path = await _recorder.stop();

      _pulse.stop();

      _bounce.stop();

      await _ampSub?.cancel();

      setState(() {
        _isRecording = false;

        activeBars = 0;
      });

      if (_maxAmplitude < -10.0) {
        setState(() {
          _isAskingGirl = true;
        });

        await _player.play(AssetSource("sound/microphone_error.mp3"));

        return;
      }

      if (path != null && File(path).existsSync()) {
        final text = await _stt.transcribe(audioPath: path);

        setState(() => _lastText = text);

        final provider = context.read<VoiceDiagnosticProvider>();

        final result = provider.evaluateSpeech(text);

        if (result.score > 0) {
          _playSuccessBurst();

          await _player.play(AssetSource("sound/success.mp3"));
        } else {
          _playErrorFlash();

          await _player.play(AssetSource("sound/diagnostic_error.mp3"));
        }

        await _player.onPlayerComplete.first;

        final hasNext = provider.next();

        if (hasNext) {
          _startItemSequence();
        } else {
          bool suc = true;
          provider.scores.forEach((item) {
            if (!item.matchedSound) {
              suc = false;
              return;
            }
          });

          provider.submitResults(context);
          if (suc) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (builder) => DiagnosticEndPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (builder) => AdviseAlphabetPage()),
            );
          }
        }
      }

      return;
    }

    final mic = await Permission.microphone.request();

    if (!mic.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mikrofon ruxsati berilmadi')),
        );
      }

      return;
    }

    final dir = await getTemporaryDirectory();

    final path =
        '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

    _maxAmplitude = -160.0;

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen((amp) {
          if (amp.current > _maxAmplitude) {
            _maxAmplitude = amp.current;
          }

          final bars = _barsFromAmplitude(amp.current);

          if (mounted) setState(() => activeBars = bars);
        });

    setState(() => _isRecording = true);

    _pulse.repeat(reverse: true);

    _bounce.repeat(reverse: true);
  }

  void _playSuccessBurst() {
    _confettiCtrl.play();
  }

  void _playErrorFlash() {
    _errorAnimCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final provider = context.watch<VoiceDiagnosticProvider>();

    final template = provider.currentTemplate;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,

            height: size.height,

            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backround/fon_q.png"),

                fit: BoxFit.fill,
              ),
            ),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),

              child: Container(
                color: Colors.black.withOpacity(0.05),

                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 17.w),

                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          SizedBox(height: 15.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              SizedBox(
                                width: 56.w,

                                height: 56.h,

                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (builder) =>
                                            DiagnosticStartPage(),
                                      ),
                                    );
                                  },

                                  child: Image.asset(
                                    "assets/icons/arrow_right_button.png",

                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),

                              Row(
                                children: [
                                  Image.asset(
                                    "assets/icons/star.png",

                                    width: 40.w,

                                    height: 40.h,
                                  ),

                                  const SizedBox(width: 12),

                                  Stack(
                                    alignment: Alignment.center,

                                    children: [
                                      Text(
                                        "${provider.totalScore}",

                                        style: TextStyle(
                                          fontSize: 35.sp,

                                          fontWeight: FontWeight.w800,

                                          color: Colors.white,
                                        ),
                                      ),

                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),

                                        transitionBuilder: (c, a) =>
                                            ScaleTransition(scale: a, child: c),

                                        child: Text(
                                          "${provider.totalScore}",

                                          key: ValueKey(provider.totalScore),

                                          style: TextStyle(
                                            fontSize: 32.sp,

                                            fontWeight: FontWeight.w800,

                                            color: const Color(0xFFF7C24B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          SizedBox(
                            width: size.width,

                            height: 9.h,

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),

                              child: ShinyStripedProgressBar(
                                progressColor: AppColors.orange_200,

                                stripeColor: AppColors.orange_500,

                                targetProgress: .5,
                              ),
                            ),
                          ),

                          SizedBox(height: 48.h),

                          AnimatedOpacity(
                            opacity: (_isMicReady && !_isAskingGirl)
                                ? 1.0
                                : 0.0,

                            duration: const Duration(milliseconds: 600),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              crossAxisAlignment: CrossAxisAlignment.end,

                              mainAxisSize: MainAxisSize.min,

                              children: List.generate(heights.length, (index) {
                                Color? color;

                                if (activeBars == 0) {
                                  color = Colors.white;
                                } else if (activeBars < heights.length - 1) {
                                  color = index < activeBars
                                      ? AppColors.red_200
                                      : Colors.white;
                                } else {
                                  color = index < activeBars
                                      ? AppColors.green_600
                                      : Colors.white;
                                }

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),

                                  width: 12,

                                  height: heights[index],

                                  decoration: BoxDecoration(
                                    color: color,

                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                );
                              }),
                            ),
                          ),

                          SizedBox(height: 100.h),

                          AnimatedOpacity(
                            opacity: (_isImageReady && !_isAskingGirl)
                                ? 1.0
                                : 0.0,

                            duration: const Duration(milliseconds: 600),

                            child: AnimatedBuilder(
                              animation: _imageFloat,

                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _imageFloatAnim.value),

                                  child: Container(
                                    width: 220.w,

                                    height: 240.h,

                                    padding: EdgeInsets.all(5.w),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28.r),

                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff00D3FF),

                                          Color(0xff0066FF),
                                        ],

                                        begin: Alignment.topLeft,

                                        end: Alignment.bottomRight,
                                      ),

                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xff00D3FF,
                                          ).withOpacity(0.4),

                                          blurRadius: 15,

                                          spreadRadius: 2,

                                          offset: const Offset(-3, 5),
                                        ),

                                        BoxShadow(
                                          color: const Color(
                                            0xff0066FF,
                                          ).withOpacity(0.3),

                                          blurRadius: 18,

                                          spreadRadius: 2,

                                          offset: const Offset(3, 8),
                                        ),
                                      ],
                                    ),

                                    child: Container(
                                      padding: EdgeInsets.all(12.w),

                                      decoration: BoxDecoration(
                                        color: Colors.white,

                                        borderRadius: BorderRadius.circular(
                                          28.r - 5.w,
                                        ),
                                      ),

                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2F8FF),

                                          borderRadius: BorderRadius.circular(
                                            18.r,
                                          ),
                                        ),

                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18.r,
                                          ),

                                          child: Image.network(
                                            template?.itemsList?.first.url ??
                                                "https://via.placeholder.com/130x150.png?text=No+Image",

                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 80.h),

                          AnimatedOpacity(
                            opacity: (_isMicReady && !_isAskingGirl)
                                ? 1.0
                                : 0.0,

                            duration: const Duration(milliseconds: 600),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                SizedBox(width: 6.w),

                                GestureDetector(
                                  child: AnimatedBuilder(
                                    animation: Listenable.merge([
                                      _pulse,

                                      _bounce,
                                    ]),

                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, _bounceAnim.value),

                                        child: Stack(
                                          alignment: Alignment.center,

                                          children: [
                                            Container(
                                              width: 110.w,

                                              height: 110.h,

                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,

                                                color: _isRecording
                                                    ? _colorAnim.value
                                                          ?.withOpacity(0.25)
                                                    : Colors.white.withOpacity(
                                                        0.15,
                                                      ),
                                              ),
                                            ),

                                            Container(
                                              width: 90.w,

                                              height: 90.h,

                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,

                                                color: _isRecording
                                                    ? _colorAnim.value
                                                          ?.withOpacity(0.35)
                                                    : Colors.white.withOpacity(
                                                        0.2,
                                                      ),
                                              ),
                                            ),

                                            ScaleTransition(
                                              scale: _scale,

                                              child: CircleAvatar(
                                                radius: 40.r,

                                                backgroundImage:
                                                    const AssetImage(
                                                      "assets/icons/circle.png",
                                                    ),

                                                child: Image.asset(
                                                  "assets/icons/micrafon.png",

                                                  width: 26.w,

                                                  height: 38.r,

                                                  color: _isRecording
                                                      ? _colorAnim.value
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                SizedBox(width: 10.w),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          IgnorePointer(
            ignoring: !_isAskingGirl,

            child: AnimatedOpacity(
              opacity: _isAskingGirl ? 1.0 : 0.0,

              duration: const Duration(milliseconds: 400),

              child: Center(
                child: Image.asset(
                  "assets/images/ask_girl.png",

                  width: 473.w,

                  height: 473.h,

                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,

            child: ConfettiWidget(
              confettiController: _confettiCtrl,

              blastDirectionality: BlastDirectionality.explosive,

              shouldLoop: false,

              gravity: 0.5,

              emissionFrequency: 0.05,

              numberOfParticles: 25,

              colors: const [
                Colors.green,

                Colors.blue,

                Colors.orange,

                Colors.pink,

                Colors.purple,
              ],
            ),
          ),

          IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_errorAnimCtrl, _errorWobbleCtrl]),

              builder: (context, child) {
                return Opacity(
                  opacity: _errorOpacity.value,

                  child: Center(
                    child: ScaleTransition(
                      scale: _errorScale,

                      child: Transform.translate(
                        offset: Offset(_errorShakeX.value, 0),

                        child: Transform.rotate(
                          angle: _errorRotate.value,

                          child: Container(
                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: Colors.white.withOpacity(0.9),
                            ),

                            child: Image.asset(
                              "assets/icons/yellow_error.png",

                              width: 100.w,

                              height: 100.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
