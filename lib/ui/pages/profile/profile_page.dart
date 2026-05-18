import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/profile/NotificationPage.dart';
import 'package:logosmart/ui/pages/profile/SettingsPage.dart';
import 'package:logosmart/ui/pages/profile/payment_page.dart';
import 'package:logosmart/ui/pages/profile/profile_edit_page.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/pages/profile/subscription_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import 'billings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var provider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    Text(
                      "Profil",
                      style: GoogleFonts.nunito(
                        color: AppColors.main_blue_900,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 39.r,
                        backgroundColor: Colors.blueGrey.shade200,
                        backgroundImage: NetworkImage(
                          provider.profileResponse?.profileImage ??
                              "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-High-Quality-Image.png",
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        provider.profileResponse.fullName ?? "",
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: AppColors.main_blue_900,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Container(
                        width: size.width,
                        height: 1.h,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => PaymentPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          width: size.width,
                          height: 80.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                spreadRadius: 2.r,
                                blurRadius: 2.r,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Balans : ${provider.profileResponse.amount ?? 0} so'm",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: AppColors.main_blue_600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Balansni to'ldirish",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                    color: AppColors.light_blue_800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),
                    _widget(
                      title:
                          "${provider.profileResponse.subscriptionCode == "DEFAULT" ? "Obuna bo'lish" : "${provider.profileResponse.subscriptionName} obuna"}",
                      icon: "assets/icons/crown.png",
                      navigation: SubscriptionPage(),
                    ),
                    _widget(
                      title: "To'lov tarixi",
                      icon: "assets/icons/bill.png",
                      navigation: BillingsPage(),
                    ),
                    _widget(
                      title: "Mening ma'lumotlarim",
                      icon: "assets/icons/user.png",
                      navigation: FlutterEditPage(),
                    ),
                    _widget(
                      title: "Sozlamalar",
                      icon: "assets/icons/settings.png",
                      navigation: SettingsPage(),
                    ),
                    _widget(
                      title: "Bildirishnoma",
                      icon: "assets/icons/qungiroq.png",
                      navigation: NotificationPage(),
                    ),
                    SizedBox(height: 36.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 11.w),
                          width: size.width,
                          height: 52.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: Colors.white,
                            border: Border.all(color: AppColors.red_200),
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.red_200,
                                  radius: 14.r,
                                  child: Center(
                                    child: Image.asset(
                                      "assets/icons/delete.png",
                                      width: 16.w,
                                      height: 16.h,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  "Hisobni o'chirish",
                                  style: GoogleFonts.nunito(
                                    color: AppColors.red_400,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),

            if (provider.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.main_blue_600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _widget({
    required String title,
    required final icon,
    required final navigation,
  }) {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (builder) => navigation));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w),
          width: size.width,
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                spreadRadius: 2.r,
                blurRadius: 2.r,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.main_blue_600,
                      radius: 14.r,
                      child: Center(
                        child: Image.asset(icon, width: 16.w, height: 16.h),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        color: AppColors.main_blue_900,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20.w,
                  color: AppColors.main_blue_900,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
