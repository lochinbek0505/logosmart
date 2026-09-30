import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'map_route_page.dart';

class AlphabetPage extends StatefulWidget {
  const AlphabetPage({super.key});

  @override
  State<AlphabetPage> createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  final List<Map<String, dynamic>> alphabet = [
    {"alphabet": "assets/alphabet/r.png", "text": "R", "number": 32},
    {"alphabet": "assets/alphabet/l.png", "text": "L", "number": 32},
    {"alphabet": "assets/alphabet/s.png", "text": "S", "number": 32},
    {"alphabet": "assets/alphabet/y.png", "text": "Y", "number": 32},
  ];

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
              image: AssetImage("assets/images/backround_xira.png"),
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
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Tovush mashqlari",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: Colors.blueGrey.shade800,
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
                        if (index == 0) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MapRoadPage()),
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
                                "assets/backround/bacround_sound.png",
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
                                      borderRadius: BorderRadius.circular(40.r),
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
                                        borderRadius: BorderRadius.circular(35.r),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${alphabet[index]["text"]} tovushini\nrivojlantirish",
                                        style: TextStyle(
                                          color: Color(0xff093e5e),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17.sp,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: const AssetImage(
                                              "assets/icons/circle.png",
                                            ),
                                            radius: 15.r,
                                            child: Transform.translate(
                                              offset: const Offset(1, -1),
                                              child: Image.asset(
                                                "assets/icons/play.png",
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
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    color: const Color(0xffd9F6FB),
                                  ),
                                  child: Text(
                                    "${alphabet[index]["number"]} ta mashg'ulot",
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff093e5e),
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
