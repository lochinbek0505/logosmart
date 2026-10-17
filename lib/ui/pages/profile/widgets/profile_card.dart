import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:logosmart/core/utils/auth_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCard extends StatelessWidget {
  final String? currentAvatarUrl;

  const ProfileCard({Key? key, required this.currentAvatarUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: context.palette.surface,
        shape: BoxShape.circle, // To'rtburchak emas, doira shaklida ixchamlashtirildi
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 36.r,
        backgroundColor: context.palette.surfaceVariant,
        backgroundImage: currentAvatarUrl != null ? authNetworkImage(currentAvatarUrl!) : null,
        onBackgroundImageError: currentAvatarUrl != null ? (_, __) {} : null,
        child: currentAvatarUrl == null
            ? Icon(Icons.person, size: 36.sp, color: context.palette.textMuted)
            : null,
      ),
    );
  }
}