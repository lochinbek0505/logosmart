import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/diagnostic/provider/diagnostic_provider.dart';import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import 'diagnostic_start_page.dart';

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
              image: AssetImage("assets/backround/fon_q.png"),
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
                        width: 24.w,
                        height: 24.h,
                        color: AppColors.main_blue_900,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Diagnostika guruhlari",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
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
              SizedBox(
                height: 200.h,
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
                                    builder: (_) => DiagnosticStartPage(
                                      templatesList: group.templatesList,
                                    ),
                                  ),
                                );
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (_) => VoiceDiagnosticPage(
                                //       templatesList: group.templatesList,
                                //     ),
                                //   ),
                                // );
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
                                height: 95.h, // 128 -> 102
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      group.iconUrl!,
                                      height: 80.h,
                                      width: 80.w, // 35 -> 28
                                      fit: BoxFit
                                          .contain, // Rasm o'z o'lchamidan oshib ketmasdan joylashadi
                                    ),
                                    SizedBox(
                                      width: 160.w, // 200 -> 150
                                      child: Text(
                                        group.name!,
                                        style: GoogleFonts.nunito(
                                          color: AppColors.sky_blue_900,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17.sp, // 24 -> 19
                                        ),
                                      ),
                                    ),
                                    CircleAvatar(
                                      backgroundImage: const AssetImage(
                                        "assets/icons/circle.png",
                                      ),
                                      radius: 25.r, // 16 -> 13
                                      child: Transform.translate(
                                        offset: const Offset(0.8, -0.8),
                                        // 1, -1 -> 0.8, -0.8
                                        child: Image.asset(
                                          "assets/icons/play.png",
                                          width: 19.w, // 12 -> 10
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ),

              Image.asset("assets/persons/girl_2.png", height: 480.h),
            ],
          ),
        ),
      ),
    );
  }
}
