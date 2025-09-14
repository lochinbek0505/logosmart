import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/start/Onboard2Page.dart';
import 'package:logosmart/ui/pages/start/Onboard3Page.dart';
import 'package:logosmart/ui/theme/AppColors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'Onboard1Page.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final _controller = PageController();
  int _index = 0;

  final _items = const [OnboardPage(), Onboard2Page(), Onboard3Page()];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final isLast = _index == _items.length - 1;
    if (isLast) {
      Navigator.of(context).pop();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  void _skip() {
    Navigator.of(context).pop();
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
              effect: const ExpandingDotsEffect(
                dotHeight: 6,
                dotWidth: 16,
                spacing: 6,
                expansionFactor: 2,
                radius: 8,
                activeDotColor: AppColors.main_blue_500,
                dotColor: Color(0x3318A6DF), // yengil ko‘k shaffof
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Asosiy tugma (Keyingisi / Boshlash)
          SizedBox(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 15,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main_blue_500,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _next,
                child: Text(
                  isLast ? "Boshlash" : "Keyingisi",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),

          // O‘tkazib yuborish
          SizedBox(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.main_blue_500),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  foregroundColor: const Color(0xFF0C5B7B),
                ),
                onPressed: _skip,
                child: const Text(
                  "O'tkazib yuborish",
                  style: TextStyle(color: Colors.black, fontSize: 18),
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

class _PageData {
  final String title;
  final String subtitle;
  final Color topColor;
  final Color bottomColor;

  // final String imagePath;
  const _PageData({
    required this.title,
    required this.subtitle,
    required this.topColor,
    required this.bottomColor,
    // this.imagePath = '',
  });
}
