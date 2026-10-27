import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:logosmart/core/utils/auth_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/models/profile_response.dart';
import 'package:logosmart/ui/pages/profile/profile_edit_info_page.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/pages/profile/widgets/avatar_selector_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class FlutterEditPage extends StatefulWidget {
  const FlutterEditPage({super.key});

  @override
  State<FlutterEditPage> createState() => _FlutterEditPageState();
}

class _FlutterEditPageState extends State<FlutterEditPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var provider = Provider.of<ProfileProvider>(context);
    ProfileResponse profile = provider.profileResponse;
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        // Kichik ekran / katta shriftda sig'may qolmasligi uchun scroll;
        // ma'lumot kam bo'lsa tugma baribir pastda turadi
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            "assets/images/arow_back.webp",
                            width: 24.w,
                            color: context.palette.textPrimary,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Mening Ma'lumotlarim",
                          style: GoogleFonts.nunito(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: context.palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: context.palette.surface,
                        boxShadow: [
                          BoxShadow(
                            color: context.palette.shadow,
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Profil rasmi",
                              style: TextStyle(
                                color: context.palette.textStrong,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rasm uchun tavsiya etilgan\navatarlardan birini tanlang",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: context.palette.textSecondary,
                                  fontSize: 14.sp,
                                ),
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: profile.profileImage != null
                                    ? authNetworkImage(profile.profileImage!)
                                    : const AssetImage(
                                            "assets/icons/circle_avatar.webp",
                                          )
                                          as ImageProvider,
                                onBackgroundImageError: (_, __) {},
                              ),
                            ],
                          ),
                          SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 45,
                                width: size.width * 0.41,

                                child: OutlinedButton(
                                  // Rasm bo'lmasa yoki so'rov ketayotganda o'chirilmaydi
                                  onPressed:
                                      profile.profileImage == null ||
                                          provider.isActionLoading
                                      ? null
                                      : () => _removeImage(provider),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Color(0xff20B9E8),
                                      width: 1.2,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    "O'chirish",
                                    style: TextStyle(
                                      color: context.palette.textStrong,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.41,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final avatars =
                                        provider.avatarsModel.dataListList ??
                                        [];
                                    if (avatars.isEmpty) {
                                      // Avatarlar yuklanmagan bo'lsa ilova yiqilardi
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Avatarlarni yuklab bo'lmadi, birozdan so'ng urinib ko'ring",
                                          ),
                                        ),
                                      );
                                      provider.init(context, silent: true);
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (builder) =>
                                            AvatarSelectionPage(
                                              avatars: avatars,
                                              initialAvatarUrl:
                                                  profile.profileImage,
                                            ),
                                      ),
                                    );
                                  },

                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Color(0xff20B9E8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    "Yangilash",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 24.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: context.palette.surface,
                        boxShadow: [
                          BoxShadow(
                            color: context.palette.shadow,
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _infoRow("Ism", profile.fullName),
                          SizedBox(height: 24.h),
                          _infoRow("Yoshi", profile.age?.toString()),
                          SizedBox(height: 24.h),
                          _infoRow("Telefon raqam", profile.phoneNumber),
                          SizedBox(height: 24.h),
                          _infoRow("Viloyat", profile.region),
                          SizedBox(height: 24.h),
                          _infoRow("Tuman", profile.district),
                        ],
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main_blue_600,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          disabledBackgroundColor: AppColors.main_blue_600
                              .withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileEditInfoPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Ma’lumotlarni o’zgartirish",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeImage(ProfileProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Profil rasmini o'chirish"),
        content: const Text("Profil rasmini o'chirmoqchimisiz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Bekor qilish"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("O'chirish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await provider.removeProfileImage(context);
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profil rasmi o'chirildi")));
  }

  /// Uzun qiymat (ism, tuman) qatordan chiqib ketmasin; bo'sh qator "Noma'lum"
  Widget _infoRow(String label, String? value) {
    final text = value?.trim() ?? "";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: context.palette.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            text.isEmpty ? "Noma'lum" : text,
            textAlign: TextAlign.end,
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: context.palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
