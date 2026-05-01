import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/main/HomePage.dart';
import 'package:logosmart/ui/pages/start/onboard_2_page.dart';
import 'package:logosmart/ui/pages/start/onboard_3_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'onboard_1_page.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final _controller = PageController();
  int _index = 0;

  final _items = const [Onboard1Page(), Onboard2Page(), Onboard3Page()];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final isLast = _index == _items.length - 1;
    if (isLast) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  void _skip() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLast = _index == _items.length - 1;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _items.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final p = _items[i];
                return p;
              },
            ),
          ),

          // --- Indicator + Tugmalar (siz bergan dizayn) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SmoothPageIndicator(
              controller: _controller,
              count: _items.length,
              effect:  ExpandingDotsEffect(
                dotHeight: 6.h,
                dotWidth: 16.w,
                spacing: 6.w,
                expansionFactor: 2,
                radius: 8.r,
                activeDotColor: AppColors.main_blue_500,
                dotColor: AppColors.light_blue_600, // yengil ko‘k shaffof
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Asosiy tugma (Keyingisi / Boshlash)
          SizedBox(
            width: size.width,
            child: Padding(
              padding:  EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main_blue_500,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36.r),
                  ),
                ),
                onPressed: _next,
                child: Text(
                  isLast ? "Boshlash" : "Keyingisi",
                  style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14.sp,fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h,),
          SizedBox(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.main_blue_500),
                  padding:  EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36.r),
                  ),
                  foregroundColor: const Color(0xFF0C5B7B),
                ),
                onPressed: _skip,
                child:  Text(
                  "O'tkazib yuborish",
                  style: GoogleFonts.nunito(color:AppColors.grey_900, fontSize: 14.sp),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
