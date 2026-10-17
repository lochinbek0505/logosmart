import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:logosmart/core/utils/auth_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/models/avatars_model.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart'; // O'zingizning manzilingiz

class AvatarSelectionPage extends StatefulWidget {
  final List<DataList> avatars;
  final String? initialAvatarUrl;

  const AvatarSelectionPage({
    Key? key,
    required this.avatars,
    this.initialAvatarUrl,
  }) : super(key: key);

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  String? _currentAvatarUrl;
  DataList? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _currentAvatarUrl = widget.initialAvatarUrl;
  }

  void _onAvatarSelected(DataList avatar) {
    setState(() {
      _selectedAvatar = avatar;
      _currentAvatarUrl = avatar.url;
    });
  }

  @override
  Widget build(BuildContext context) {
    final males = widget.avatars.where((e) => e.gender == "MALE").toList();
    final females = widget.avatars.where((e) => e.gender == "FEMALE").toList();
    var provider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        backgroundColor: context.palette.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: context.palette.textStrong),
        title: Text(
          "Profil rasmini tanlash",
          style: GoogleFonts.nunito(
            color: context.palette.textPrimary,
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 24.h),

          Center(
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200, width: 3.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.15),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Container(
                width: 120.r, // 2 * 60.r radius
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.palette.surface,
                ),
                child: ClipOval(
                  child: _currentAvatarUrl != null
                      ? Image.network(
                          _currentAvatarUrl!,
                          headers: authImageHeaders(_currentAvatarUrl!),
                          fit: BoxFit
                              .cover, // Rasmni bo'sh joysiz to'liq sig'diradi
                          width: 120.r,
                          height: 120.r,
                        )
                      : Icon(
                          Icons.person,
                          size: 60.sp,
                          color: context.palette.textMuted,
                        ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30.h),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 24.h, left: 16.w),
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, -4.h),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (males.isNotEmpty) ...[
                      _buildSectionTitle("Bolalar"),
                      SizedBox(height: 12.h),
                      _buildHorizontalList(males),
                      SizedBox(height: 24.h),
                    ],
                    if (females.isNotEmpty) ...[
                      _buildSectionTitle("Qizlar"),
                      SizedBox(height: 12.h),
                      _buildHorizontalList(females),
                      SizedBox(height: 30.h),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Saqlash tugmasi
      bottomNavigationBar: Container(
        color: context.palette.surface,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              if (_selectedAvatar != null) {
                var map = {
                  "fullName": provider.profileResponse.fullName,
                  "age": provider.profileResponse.age,
                  "profileImage": _selectedAvatar!.url,
                  "region": provider.profileResponse.region,
                  "district": provider.profileResponse.district,
                };
                debugPrint(map.toString());
                provider.updateProfile(context, map);
              }

              Navigator.pop(context, _selectedAvatar);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main_blue_600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              elevation: 2,
            ),
            child: Text(
              "Yangilash",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: context.palette.textPrimary,
      ),
    );
  }

  Widget _buildHorizontalList(List<DataList> items) {
    return SizedBox(
      height: 75.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final isActive = item.url == _currentAvatarUrl;

          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () => _onAvatarSelected(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 75.h,
                height: 75.h,
                padding: EdgeInsets.all(isActive ? 3.w : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.blue : Colors.transparent,
                    width: isActive ? 2.5.w : 0,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: context.palette.surfaceVariant,
                    child: item.url != null
                        ? Image.network(
                            item.url!,
                            headers: authImageHeaders(item.url!),
                            fit: BoxFit.fitWidth,
                            // Ro'yxatdagi rasmni ham to'liq yoyish
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Icon(
                            Icons.person,
                            size: 28.sp,
                            color: context.palette.textMuted,
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
