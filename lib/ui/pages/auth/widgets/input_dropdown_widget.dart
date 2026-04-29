import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/AppColors.dart';

class InputDropdownWidget<T extends Object> extends StatelessWidget {
  final T? value;
  final String label;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final String hintText;

  // Matnni qanday ko'rsatishni o'zimiz belgilashimiz uchun
  final String Function(T)? itemAsString;

  const InputDropdownWidget({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.hintText = "Tanlang",
    this.itemAsString,
  });

  // Ekranga matn chiqarish uchun yordamchi funksiya
  String _getDisplayText(T item) {
    if (itemAsString != null) {
      return itemAsString!(item);
    }
    // Agar oldingi Map tizimida ishlatilsa xato bermasligi uchun ehtiyot chorasi
    if (item is Map<String, dynamic> && item.containsKey('name')) {
      return item['name'].toString();
    }
    return item
        .toString(); // Oddiy int yoki String kelsa, to'g'ridan-to'g'ri o'zini qaytaradi
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 15.w, bottom: 8.h),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: AppColors.grey_700,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: CustomDropdown<T>(
            items: items,
            initialItem: value,
            hintText: hintText,
            onChanged: onChanged,
            validator: validator,

            decoration: CustomDropdownDecoration(
              closedFillColor: Colors.white,
              expandedFillColor: Colors.white,

              // 1. ODDIY HOLAT UCHUN DIZAYN
              closedBorder: Border.all(
                color: AppColors.light_grey_500,
                width: 1,
              ),
              closedBorderRadius: BorderRadius.circular(36.r),

              // 2. ERROR HOLATI UCHUN DIZAYN (Oddiy holat bilan mutlaqo bir xil qilindi)
              closedErrorBorder: Border.all(
                color: AppColors.light_grey_500,
                // Xohlasangiz buni qizilga (Colors.red) o'zgartirishingiz mumkin
                width: 1, // Qalinlik o'zgarmaydi
              ),
              closedErrorBorderRadius: BorderRadius.circular(36.r),

              // Radius o'zgarmaydi
              expandedBorder: Border.all(
                color: const Color(0xFF00C2E8),
                width: 1.5,
              ),
              expandedBorderRadius: BorderRadius.circular(20.r),

              // Xatolik matni (qizil yozuv) chiqqanda ko'rinishini sozlash (Ixtiyoriy)
              errorStyle: GoogleFonts.nunito(
                color: Colors.red,
                fontSize: 12.sp,
              ),

              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.grey_700, size: 20.sp)
                  : null,
            ),
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Text(
                        _getDisplayText(item),
                        style: GoogleFonts.nunito(
                          color: AppColors.grey_900,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },

            headerBuilder: (context, selectedItem, enabled) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Text(
                  _getDisplayText(selectedItem),
                  style: GoogleFonts.nunito(
                    color: AppColors.grey_900,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            },
            hintBuilder: (context, hint, enabled) {
              return Text(
                hint,
                style: GoogleFonts.nunito(
                  color: AppColors.grey_700.withOpacity(0.5),
                  fontSize: 16.sp,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
