import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/diagnostic/voice_diagnostic_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

import '../../../../core/utils/game_bounce_page_route.dart';
import '../../../../models/diagnostic_group_model.dart';

class DiagnosticStartPage extends StatefulWidget {
  List<Template>? templatesList;

  DiagnosticStartPage({super.key, this.templatesList});

  @override
  State<DiagnosticStartPage> createState() => _DiagnosticPage();
}

class _DiagnosticPage extends State<DiagnosticStartPage> {
  bool _isPressed = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.play(AssetSource('sound/diagnostic.mp3'));
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
            image: AssetImage("assets/backround/fon_q.png"),
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
                  width: 250.w,
                  height: 160.h,
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
                      "Diagnostika vaqtida ortiqcha shovqin qilmang! Rasmlar nomini ortimdan takrorlang",
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
                    "assets/persons/girl_1.png",
                    width: 200.w,
                    height: 380.h,
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
                      GameBouncePageRoute(
                        page: VoiceDiagnosticPage(
                          templatesList: widget.templatesList,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    width: 264.w,
                    height: 72.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: _isPressed
                        ? Container(
                            width: size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xff20B9E8),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "BOSHLASH",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.sp,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            width: size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xff47809e),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(top: 2),
                              width: 190,
                              height: 57,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(29),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xffbee9f7),
                                    Color(0xff20B9E8),
                                  ],
                                  end: Alignment.bottomCenter,
                                  begin: Alignment.topCenter,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "BOSHLASH",
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.sp,
                                  ),
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
