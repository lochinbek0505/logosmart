import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/main/diagnostic/provider/diagnostic_provider.dart';
import 'package:logosmart/ui/pages/main/diagnostic/voice_diagnostic_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class DiagnosticGroupPage extends StatefulWidget {
  const DiagnosticGroupPage({super.key});

  @override
  State<DiagnosticGroupPage> createState() => _DiagnosticGroupPageState();
}

class _DiagnosticGroupPageState extends State<DiagnosticGroupPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiagnosticProvider>(context, listen: false).init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DiagnosticProvider>(context);
    var groups = provider.diagnosticGroupModel.dataListList ?? [];
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,

        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/backround_frame.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 60, width: double.infinity),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        "assets/images/arow_back.png",
                        width: 24,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Diagnostika guruhlari",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: AppColors.main_blue_900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemBuilder: (context, index) {
                    var group = groups[index];
                    return provider.isLoading
                        ? Center(
                            child: Container(
                              padding: EdgeInsets.all(20.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.main_blue_900,
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              if (index == 0) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VoiceDiagnosticPage(
                                      templatesList: group.templatesList,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Bu qism bo'yicha ishlar davom etyabdi",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5.5,
                              ),
                              // 7 -> 5.5
                              child: Container(
                                height: 102.h, // 128 -> 102
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14, // 18 -> 14
                                  vertical: 11, // 14 -> 11
                                ),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      "assets/backround/bacround_sound.png",
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    12.r,
                                  ), // 15 -> 12
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// Left side
                                    Row(
                                      children: [
                                        Container(
                                          width: 58.w,
                                          // 72 -> 58
                                          height: 58.h,
                                          // 72 -> 58
                                          padding: const EdgeInsets.all(1.5),
                                          // 2 -> 1.5
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            // Aniq radius o'rniga har doim mukammal aylana qiladi
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xffb5e9f7),
                                                Color(0xff5ad4f2),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              // Ichki qism ham aylana
                                              color: Colors.white,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            // Rasm aylanadan tashqariga chiqsa, kesib tashlaydi
                                            child: Center(
                                              child: Image.asset(
                                                "assets/icons/voice_controller.png",
                                                height: 28.h, // 35 -> 28
                                                width: 28.w, // 35 -> 28
                                                fit: BoxFit
                                                    .contain, // Rasm o'z o'lchamidan oshib ketmasdan joylashadi
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 13.w), // 16 -> 13
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              group.name!,
                                              style: GoogleFonts.nunito(
                                                color: AppColors.sky_blue_900,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 19.sp, // 24 -> 19
                                              ),
                                            ),
                                            SizedBox(height: 5.h), // 6 -> 5
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage:
                                                      const AssetImage(
                                                        "assets/icons/circle.png",
                                                      ),
                                                  radius: 13.r, // 16 -> 13
                                                  child: Transform.translate(
                                                    offset: const Offset(
                                                      0.8,
                                                      -0.8,
                                                    ),
                                                    // 1, -1 -> 0.8, -0.8
                                                    child: Image.asset(
                                                      "assets/icons/play.png",
                                                      width: 10.w, // 12 -> 10
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 3.w), // 4 -> 3
                                                Text(
                                                  "Boshlash",
                                                  style: GoogleFonts.nunito(
                                                    color:
                                                        AppColors.main_blue_600,
                                                    fontSize: 11.sp, // 14 -> 11
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
