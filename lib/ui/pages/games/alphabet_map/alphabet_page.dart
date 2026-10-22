import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'map_route_page.dart';
import 'provider/level_provider.dart';

class AlphabetPage extends StatefulWidget {
  const AlphabetPage({super.key});

  @override
  State<AlphabetPage> createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  final List<Map<String, dynamic>> alphabet = [
    {"alphabet": "assets/alphabet/r.webp", "text": "R"},
    {"alphabet": "assets/alphabet/l.webp", "text": "L"},
    {"alphabet": "assets/alphabet/s.webp", "text": "S"},
    {"alphabet": "assets/alphabet/y.webp", "text": "Y"},
  ];

  @override
  void initState() {
    super.initState();
    // Har bir tovush levellari soni kartalarda ko'rsatilishi uchun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LevelProvider>();
      for (final item in alphabet) {
        provider.preloadSound(item["text"] as String);
      }
    });
  }

  /// Mashg'ulotlar soni tovush JSON faylidagi levellar soniga qarab
  String _lessonsLabel(String sound) {
    final count = context.watch<LevelProvider>().levelsOf(sound)?.length;
    if (count != null) return "$count ta mashg'ulot";
    return LevelProvider.hasSound(sound) ? "..." : "Tez kunda";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,

        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/backround_xira.webp"),
              fit: BoxFit.fill,
              colorFilter: context.palette.backgroundImageFilter,
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
                        "assets/images/arow_back.webp",
                        width: 24.w,
                        color: context.palette.icon,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Tovush mashqlari",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: context.palette.textStrong,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: alphabet.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        final sound = alphabet[index]["text"] as String;
                        if (LevelProvider.hasSound(sound)) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MapRoadPage(sound: sound),
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
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        child: Container(
                          constraints: BoxConstraints(minHeight: 115.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage(
                                "assets/backround/bacround_sound.webp",
                              ),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.shade200.withValues(
                                  alpha: 0.5,
                                ),
                                spreadRadius: 4,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Left side
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60.w,
                                      height: 60.w,
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          40.r,
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xffb5e9f7),
                                            Color(0xff5ad4f2),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            35.r,
                                          ),
                                          color: Colors.cyan.shade50,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            alphabet[index]["alphabet"],
                                            height: 35.w,
                                            width: 35.w,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${alphabet[index]["text"]} tovushini\nrivojlantirish",
                                            style: TextStyle(
                                              color:
                                                  context.palette.textPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17.sp,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage:
                                                    const AssetImage(
                                                      "assets/icons/circle.webp",
                                                    ),
                                                radius: 15.r,
                                                child: Transform.translate(
                                                  offset: const Offset(1, -1),
                                                  child: Image.asset(
                                                    "assets/icons/play.webp",
                                                    width: 13.w,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5.w),
                                              Text(
                                                "Boshlash",
                                                style: TextStyle(
                                                  color: Color(0xff20B9E8),
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// Right side
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    color: context.palette.primarySoft,
                                  ),
                                  child: Text(
                                    _lessonsLabel(
                                      alphabet[index]["text"] as String,
                                    ),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.textPrimary,
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
