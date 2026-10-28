import 'package:flutter/material.dart';
import 'package:logosmart/core/utils/auth_image.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

/// Sahifa tepasidagi foydalanuvchi avatari: profil rasmi, bo'lmasa standart rasm.
class ProfileAvatar extends StatelessWidget {
  final double radius;

  const ProfileAvatar({super.key, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    final url = context.select<ProfileProvider, String?>(
      (p) => p.profileResponse.profileImage,
    );
    final hasUrl = url != null && url.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundImage: const AssetImage("assets/icons/circle_bad.webp"),
      // Rasm yuklanmasa ostidagi standart rasm ko'rinib qoladi
      foregroundImage: hasUrl ? authNetworkImage(url) : null,
      onForegroundImageError: hasUrl ? (_, __) {} : null,
    );
  }
}
