import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/profile/subscription_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

/// Pullik (obunasiz foydalanuvchi uchun yopiq) level yoki mashq bosilganda
/// obunaga taklif. "Obuna bo'lish" — obuna sahifasiga o'tadi.
/// Obuna sahifasidan qaytilganda true qaytaradi (ma'lumotni yangilash uchun).
Future<bool> showSubscriptionOffer(BuildContext context) async {
  final goToSubscription = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: Row(
        children: [
          Icon(Icons.lock_rounded, color: AppColors.main_blue_600, size: 24.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "Obuna kerak",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: ctx.palette.textStrong,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        "Bu mashg'ulot faqat obunachilar uchun. Obuna bo'lib, barcha "
        "mashg'ulotlarni oching.",
        style: TextStyle(fontSize: 15.sp, color: ctx.palette.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text("Keyinroq"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.main_blue_600,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text("Obuna bo'lish"),
        ),
      ],
    ),
  );
  if (goToSubscription != true || !context.mounted) return false;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
  );
  return true;
}
