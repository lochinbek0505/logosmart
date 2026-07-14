import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/main/widgets/custom_text_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

class KeyboardGamePage extends StatefulWidget {
  const KeyboardGamePage({super.key});

  @override
  State<KeyboardGamePage> createState() => _KeyboardGamePageState();
}

class _KeyboardGamePageState extends State<KeyboardGamePage> {
  final Color keyColor = const Color(0xFF5CB3D6);
  final Color boxBorderColor = const Color(0xFF6EC4E7);
  final Color starColor = const Color(0xFFFFCC4D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey_50,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/star.png",
                        width: 40.w,
                        height: 40.h,
                      ),
                      SizedBox(width: 8.w),
                      CustomTextWidget(text: "20", sizeText: 32.sp),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 8.5,
                      bottom: 11.5,
                    ),
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/icons/circle.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        "assets/icons/circle_bad.png",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 60.h),

            // 2. Markazdagi Raketa (Rasm o'rnida Icon ishlatilgan, asset bilan almashtirishingiz mumkin)
            Image.asset(
              "assets/images/dog_house.png",
              width: 80.w,
              height: 80.h,
            ),

            SizedBox(height: 60.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Container(
                    width: 44.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: boxBorderColor, width: 1.5.w),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            _buildKeyboard(),

            SizedBox(height: 30.h),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: "QWERTYUIOP".split('').map((e) => _buildKey(e)).toList(),
        ),
        // 2-qator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: "ASDFGHJKL".split('').map((e) => _buildKey(e)).toList(),
        ),
        // 3-qator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionKey(Icons.arrow_upward_rounded),
            ..."ZXCVBNM".split('').map((e) => _buildKey(e)),
            _buildActionKey(Icons.backspace_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String text) {
    return Container(
      width: 29.w,
      height: 42.h,
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 4.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: keyColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionKey(IconData icon) {
    return Container(
      width: 44.w,
      height: 48.h,
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 4.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: keyColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, color: Colors.white, size: 20.sp),
    );
  }
}
