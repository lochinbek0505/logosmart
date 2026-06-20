import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/diagnostic/provider/voice_diagnostic_provider.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/game_bounce_page_route.dart';
import 'advise_alphabet_page.dart';

class DiagnosticEndPage extends StatefulWidget {
  DiagnosticEndPage({super.key});

  @override
  State<DiagnosticEndPage> createState() => _DiagnosticPage();
}

class _DiagnosticPage extends State<DiagnosticEndPage> {
  bool _isPressed = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.play(AssetSource('sound/diagnostic_finish.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var provider = Provider.of<VoiceDiagnosticProvider>(context);
    provider.scoreInit();
    var sounds = provider.scores;
    print("SOUND TEST");
    print(sounds.toString());

    return Scaffold(
      backgroundColor: Colors.green.shade300,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backround/fon_4.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          // ASOSIY O'ZGARISH SHU YERDA: CustomScrollView qo'shildi
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1-QISM: Tepadagi ma'lumotlar (Appbar, Card, Rasm)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 56.w,
                            height: 56.h,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Image.asset(
                                "assets/icons/arrow_right_button.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 8.5,
                              bottom: 11.5,
                            ),
                            width: 80.h,
                            height: 80.w,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/icons/circle.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(
                                "assets/icons/circle_bad.png",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25.h),

                    // Asosiy Karta (Card)
                    Container(
                      width: 320.w,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.sky_blue_300,
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.sky_blue_400,
                            offset: Offset(0, 5),
                            blurRadius: 0,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: const Color(0xffFFD700),
                                size: 45.sp,
                              ),
                              Transform.translate(
                                offset: Offset(0, -10.h),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: const Color(0xffFFD700),
                                  size: 60.sp,
                                ),
                              ),
                              Icon(
                                Icons.star_rounded,
                                color: const Color(0xffFFD700),
                                size: 45.sp,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Barakalla!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: const Color(0xffFF8C00),
                              fontWeight: FontWeight.w900,
                              fontSize: 24.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Sen barcha topshiriqlarni\na'lo darajada bajarding!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: AppColors.sky_blue_900,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8.w,
                              runSpacing: 10.h,
                              children: sounds.map((item) {
                                return _buildWordTag(
                                  item.matchedWord.toString(),
                                  item.matchedSound,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    true
                        ? const SizedBox()
                        : Transform.translate(
                            offset: Offset(0, -15.h),
                            child: Image.asset(
                              "assets/persons/girl_3.png",
                              width: 220.w,
                              height: 400.h,
                            ),
                          ),
                  ],
                ),
              ),

              // 2-QISM: Qolgan joyni egallovchi va tugmani pastga itaruvchi qism
              SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 40.h),

                    // Karta va tugma orasida minimal bo'sh joy
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPressed = true;
                        });
                        Future.delayed(const Duration(milliseconds: 160), () {
                          if (mounted) {
                            setState(() {
                              _isPressed = false;
                            });
                          }
                        });

                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5.5),
                        width: 211.w,
                        height: 57.5.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: _isPressed ? const Color(0xff20B9E8) : null,
                            gradient: _isPressed
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xffbee9f7),
                                      Color(0xff20B9E8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            boxShadow: _isPressed
                                ? []
                                : const [
                                    BoxShadow(
                                      color: Color(0xff47809e),
                                      offset: Offset(0, 2.5),
                                      blurRadius: 0,
                                      spreadRadius: 0,
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: Text(
                              "DAVOM ETISH",
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.5.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    // Eng pastki xavfsiz bo'sh joy
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordTag(String word, bool isCorrect) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:  Colors.green.shade400 ,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text( "✅ " , style: TextStyle(fontSize: 14.sp)),
          Text(
            word,
            style: GoogleFonts.nunito(
              color: Colors.green.shade800 ,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
