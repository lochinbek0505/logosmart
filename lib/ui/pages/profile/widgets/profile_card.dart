import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/models/avatars_model.dart';

class ProfileCard extends StatelessWidget {
  final String? currentAvatarUrl;

  const ProfileCard({Key? key, required this.currentAvatarUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle, // To'rtburchak emas, doira shaklida ixchamlashtirildi
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 36.r,
        backgroundColor: Colors.grey.shade100,
        backgroundImage: currentAvatarUrl != null ? NetworkImage(currentAvatarUrl!) : null,
        child: currentAvatarUrl == null
            ? Icon(Icons.person, size: 36.sp, color: Colors.grey.shade400)
            : null,
      ),
    );
  }
}