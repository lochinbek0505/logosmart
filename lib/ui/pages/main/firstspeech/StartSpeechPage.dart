import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'first_speech_categories_page.dart';

class StartSpeechPage extends StatefulWidget {
  const StartSpeechPage({super.key});

  @override
  State<StartSpeechPage> createState() => _StartSpeechPageState();
}

class _StartSpeechPageState extends State<StartSpeechPage> {
  bool _isPressed = false;
  // Tez-tez bosilganda sahifa ikki marta ochilmasligi uchun
  bool _isNavigating = false;

  void _onStart() {
    if (_isNavigating) return;
    _isNavigating = true;

    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 160), () {
      if (!mounted) return;
      setState(() => _isPressed = false);
    });

    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FirstSpeechCategoriesPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/backround_xira.webp"),
            fit: BoxFit.fill,
            colorFilter: context.palette.backgroundImageFilter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Image.asset(
                      "assets/images/arow_back.webp",
                      width: 24.w,
                      color: context.palette.icon,
                    ),
                  ),
                ),
              ),

              // Bulut + qizcha mavjud joyni egallaydi, tugmaga hech qachon
              // tegib ketmaydi (ekran kichik bo'lsa rasm kichrayadi)
              Expanded(
                // Pastdan yuqoriga joylanadi: qizcha avval chiziladi, bulut esa
                // keyin — pastga surilgan bulut qizcha ustida ko'rinadi
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  verticalDirection: VerticalDirection.up,
                  children: [
                    Flexible(
                      child: Image.asset(
                        "assets/images/women.webp",
                        width: size.width * 0.58,
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, 15.h),
                      child: Container(
                        width: size.width * 0.78,
                        height: 175.h,
                        padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 26.h),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/icons/cloud.webp"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Nutq chiqarish\nmashqlariga xush\nkelibsan!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                // Bulut har doim oq — matn mavzudan qat'i nazar to'q
                                color: AppColors.grey_900,
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Qizcha rasmi va tugma orasidagi bo'sh joy
              SizedBox(height: 20.h),
              GestureDetector(onTap: _onStart, child: _buildButton(size)),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(Size size) {
    final label = Text(
      "BOSHLA!",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22.sp,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(7),
      width: size.width * 0.7,
      height: 65,
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(40),
      ),
      child: _isPressed
          ? Container(
              decoration: BoxDecoration(
                color: const Color(0xff20B9E8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(child: label),
            )
          : Container(
              padding: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                color: const Color(0xff47809e),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(29),
                  gradient: const LinearGradient(
                    colors: [Color(0xffbee9f7), Color(0xff20B9E8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(child: label),
              ),
            ),
    );
  }
}
