import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

import '../../../../core/utils/game_bounce_page_route.dart';
import '../../../../models/diagnostic_group_model.dart';
import 'advise_alphabet_page.dart';

class DiagnosticEndPage extends StatefulWidget {
  List<Template>? templatesList;

  DiagnosticEndPage({super.key, this.templatesList});

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
    _audioPlayer.play(AssetSource('sound/diagnostiic.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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

                SizedBox(height: 15.h),

                Container(
                  width: 230.w,
                  height: 140.h,
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 22,
                    bottom: 11.5,
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/big_cloud.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Transform.translate(
                    offset: Offset(0, 25.h),
                    child: Text(
                      "Barakalla, sen topshiriqlarni bajarding!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: AppColors.sky_blue_900,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: Offset(0, -15.h),
                  child: Image.asset(
                    "assets/persons/girl_3.png",
                    width: 220.w,
                    height: 400.h,
                  ),
                ),

                SizedBox(height: 20.h),
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

                    Future.delayed(const Duration(milliseconds: 180), () {});

                    Navigator.push(
                      context,
                      GameBouncePageRoute(page: AdviseAlphabetPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5.5),
                    // 7 ning 80% i
                    width: 211.w,
                    // 264 ning 80% i
                    height: 57.5.h,
                    // 72 ning 80% i
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32), // 40 ning 80% i
                    ),
                    child: Container(
                      width: double.infinity,
                      // Ota widgetning qolgan joyini to'liq egallaydi
                      height: 48,
                      // 60 ning 80% i
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        // 30 ning 80% i
                        color: _isPressed ? const Color(0xff20B9E8) : null,
                        gradient: _isPressed
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xffbee9f7), Color(0xff20B9E8)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                        // 3D effekt uchun Container o'rniga pastki soya (offset) beramiz
                        boxShadow: _isPressed
                            ? []
                            : const [
                                BoxShadow(
                                  color: Color(0xff47809e),
                                  offset: Offset(
                                    0,
                                    2.5,
                                  ), // Soya faqat pastga tushadi
                                  blurRadius: 0,
                                  spreadRadius: 0,
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          "NATIJALAR",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.5.sp, // 22 ning 80% i
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30.h), // Eng pastki xavfsiz bo'sh joy
              ],
            ),
          ),
        ),
      ),
    );
  }
}
