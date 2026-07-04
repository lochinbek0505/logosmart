import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../main/widgets/custom_text_widget.dart';

// {
// "start_voice":"assets/sound/breath/breath_start.mp3",
// "blow_voice":"assets/sound/breath/butterfly.mp3",
// "lottie_animation":"assets/animation/breath/butterfly.json",
// "background_image":"assets/backround/breath/butterfly_background.jpg",
// "icon_star":"assets/icons/star.png",
// "icon_arrow":"assets/icons/arrow_right_button.png",
// "animation_position":-1.2
// }

class BreathPage extends StatefulWidget {
  const BreathPage({super.key});

  @override
  State<BreathPage> createState() => _BreathPageState();
}

class _BreathPageState extends State<BreathPage> with TickerProviderStateMixin {
  //TODO UMUMIY BALL TIZIMINI ISHLAB CHIQISH KERAK VA HAR BIR INCREASE BO'LGAN BALL O'YINLAR VA CAMERA MASHQLARI BOYICHA O'SHA YAGONA PROVIDER BALL TIZIMIDAN FOYDALANISHI KERAK
  // Lottie va Audio
  late final AnimationController _lottieController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Mikrofon animatsiyasi uchun controllerlar
  late final AnimationController _pulse;
  late final AnimationController _bounce;
  late final Animation<double> _scale;
  late final Animation<double> _bounceAnim;
  late final Animation<Color?> _colorAnim;
  DateTime? _blowStartTime;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSub;
  StreamSubscription<void>? _audioCompleteSub; // Ovoz tugashini eshitish uchun

  // Ovoz va animatsiya holatlari
  bool _isMicReady = false;
  bool _isAskingGirl = false;
  bool _hasBlown = false;
  bool _isRecording = false;

  // Vizualizator uchun o'zgaruvchilar
  List<double> heights = [10.0, 18.0, 26.0, 36.0, 26.0, 18.0, 10.0];
  int activeBars = 0;
  int _breathCount = 0;

  //TODO PROVIDER DAN OLINADIGAN QILINADI SHU JOYLARI
  int _ball = 0;

  // Puflash sezgirligi (Detsibel)
  static const double _thresholdDb = 75.0;

  @override
  void initState() {
    super.initState();

    // 1. Lottie Controller
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener(_onAnimationStatus);

    // 2. Mikrofon Animatsiyalari Controllerlari (Bu yerda repeat qilmaymiz, kutamiz)
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animatsiya qiymatlari (Tweens)
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _bounceAnim = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));

    _colorAnim = ColorTween(
      begin: Colors.green,
      end: Colors.lightGreenAccent,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    // Sahifani initsializatsiya qilish
    _initPage();
  }

  Future<void> _initPage() async {
    // 1. Ovoz to'liq tugashini kuzatamiz
    _audioCompleteSub = _audioPlayer.onPlayerComplete.listen((_) async {
      // Keyingi ovozlarda (kapalak uchganda) bu mantiq takrorlanmasligi uchun obunani bekor qilamiz
      _audioCompleteSub?.cancel();

      // 2. Ovoz tugagach, 1 soniya kutamiz
      await Future.delayed(const Duration(seconds: 1));

      // 3. Mikrofon ruxsatini so'raymiz
      final micOk = await _ensureMicPermission();
      if (micOk && mounted) {
        setState(() {
          _isMicReady = true;
        });

        // 4. Mikrofon ruxsati olingach va 1 sekund o'tgach animatsiyalarni yoqamiz
        _pulse.repeat(reverse: true);
        _bounce.repeat(reverse: true);

        // 5. Ovozni eshitishni boshlaymiz
        _startListening();
      }
    });

    // Ovozni chalishni boshlaymiz (bu qator faqat play qilib beradi, kutish tepadagi tinglovchida bo'ladi)
    await _audioPlayer.play(AssetSource('sound/breath/breath_start.mp3'));
  }

  void _startListening() {
    _noiseMeter ??= NoiseMeter();
    _noiseSub = _noiseMeter!.noise.listen(_onNoise);
  }

  void _onAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      // Ovoz chalish buyrug'i bu yerdan olib tashlandi
      // (chunki bu animatsiya tugagan holat).
      if (_breathCount == 3) {
        _gameEnd();
      }
      // Yangi puflashni qabul qilish uchun holatni qaytarish (2 sekund kutib)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _hasBlown = false;
          });
        }
      });
    }
  }

  void _gameEnd() async {
    print("Game end");

    // TODO: OYIN TUGAGANINI PROVIDERGA YUBORISH KERAK VA BALL QO'SHISH KERAK
    setState(() {
      _ball += 10;
    });

    // 1. Muvaffaqiyatli ovozni chalish (asset yo'lini o'zingizdagi faylga moslang)
    await _audioPlayer.play(AssetSource('sound/success.mp3'));

    // 2. Bolalarga mos, qiziqarli dialog ko'rsatish
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      // Ekranning chetini bosganda yopilib ketmasligi uchun
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Yutuq animatsiyasi (masalan: mushakbozlik, yulduzchalar yoki tabriklayotgan belgi)
                Lottie.asset(
                  'assets/animation/success.json',
                  // O'zingizdagi Lottie fayl nomiga almashtiring
                  width: 120.w,
                  height: 120.h,
                  repeat: false,
                ),

                Text(
                  "Tabriklaymiz",
                  style: GoogleFonts.nunito(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,

                    color: AppColors.sky_blue_900,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  "O\'yinni muvaffaqiyatli yakunladingiz!\n +10 Ball",
                  style: GoogleFonts.nunito(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.light_blue_900,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 30.h),

                // Keyingi bosqichga o'tish yoki chiqish tugmasi
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.main_blue_600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 48.w,
                        vertical: 16.h,
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Dialogni yopish
                      Navigator.pop(
                        context,
                      ); // O'yin sahifasidan chiqish (yoki boshqa logikangiz)
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Davom etish",
                          style: GoogleFonts.nunito(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNoise(NoiseReading reading) {
    if (!mounted || _breathCount >= 3) return;

    final db = reading.meanDecibel;
    int calculatedBars = ((db - 30) / 10).clamp(0, heights.length).toInt();

    if (db > _thresholdDb) {
      // Ovoz balandlasha boshlaganda vaqtni qayd qilamiz
      _blowStartTime ??= DateTime.now();

      // Ovoz qancha vaqtdan beri baland ekanligini hisoblaymiz
      final blowDuration = DateTime.now().difference(_blowStartTime!);

      // Mikrofon vizualizatsiyasini darhol yashil qilib yoqamiz
      setState(() {
        activeBars = calculatedBars;
        _isRecording = true;
      });

      // AGAR ovoz uzluksiz kamida 400 millisoniya (0.4 sekund) davom etgan bo'lsa:
      if (blowDuration.inMilliseconds > 400) {
        if (!_lottieController.isAnimating && !_hasBlown) {
          _hasBlown = true;

          // Animatsiya va ovozni bir vaqtda ishga tushiramiz
          _audioPlayer.play(AssetSource('sound/breath/butterfly.mp3'));
          _lottieController.forward(from: 0.0);
          _breathCount++;
        }
      }
      print(
        "Blow duration: ${blowDuration.inMilliseconds} ms, Blow count: $_breathCount",
      );

    } else {
      // Ovoz pasaysa (uzilib qolsa), taymerni nollaymiz (oraga qisqa shovqin tushgan bo'lsa bekor qilinadi)
      _blowStartTime = null;

      setState(() {
        activeBars = calculatedBars;
        _isRecording = false;
      });
    }
  }

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  void dispose() {
    _audioCompleteSub?.cancel();
    _noiseSub?.cancel();
    _lottieController.dispose();
    _pulse.dispose();
    _bounce.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/backround/breath/butterfly_background.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50.h),

            // Yuqori qism
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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
                      SizedBox(width: 8.w),
                      CustomTextWidget(text: _ball.toString(), sizeText: 32.sp),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Lottie animatsiyasi
            Lottie.asset(
              'assets/animation/breath/butterfly.json',
              controller: _lottieController,
              animate: _isMicReady,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
              },
              width: 300.w,
              height: 300.h,
              fit: BoxFit.contain,
            ),

            const Spacer(),

            SizedBox(height: 16.h),

            // Animatsiyali Mikrofon Widgeti
            AnimatedOpacity(
              opacity: (_isMicReady && !_isAskingGirl) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 6.w),
                  GestureDetector(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_pulse, _bounce]),
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
                                      ? _colorAnim.value?.withOpacity(0.25)
                                      : Colors.white.withOpacity(0.15),
                                ),
                              ),
                              Container(
                                width: 90.w,
                                height: 90.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRecording
                                      ? _colorAnim.value?.withOpacity(0.35)
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                              ScaleTransition(
                                scale: _scale,
                                child: CircleAvatar(
                                  radius: 40.r,
                                  backgroundImage: const AssetImage(
                                    "assets/icons/circle.png",
                                  ),
                                  child: Image.asset(
                                    "assets/icons/micrafon.png",
                                    width: 26.w,
                                    height: 38.h,
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

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
