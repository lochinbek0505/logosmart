import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/pages/home/home_page.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/AlphabetPage.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/VoiceGamePage.dart';
import 'package:logosmart/ui/pages/profile/profile_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';

import '../diagnostic/diagnostic_start_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Track the currently selected tab index
  int _selectedIndex = 0;

  // List of pages corresponding to the tabs
  final List<Widget> pages = [
    const HomePage(),
    const AlphabetPage(),
    DiagnosticStartPage(),
    const VoiceGamePage(),
    const ProfilePage(),
  ];

  // Handle tab taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Rasm rangi va paddingini sozlash uchun yordamchi funksiya
  Widget _buildIcon(String assetPath, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h,top: 8.h), // Icon va label orasiga 8.h lik joy
      child: Image.asset(
        assetPath,
        width: 20.w,
        height: 20.h,
        color: color, // Rangi select/unselect holatiga qarab o'zgaradi
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the page that corresponds to the selected index
      body: pages[_selectedIndex],
      extendBody: true,
      // Custom height va corner uchun Container bilan o'raymiz
      bottomNavigationBar: Container(

        height: 84.h, // O'zingiz xohlagan custom height
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r), // Custom top corners
            topRight: Radius.circular(18.r),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0, // Container'da shadow borligi uchun default shadow olinadi

            // Colors matching your design
            selectedItemColor: AppColors.main_blue_600,
            unselectedItemColor: AppColors.grey_500,

            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),

            currentIndex: _selectedIndex,
            onTap: _onItemTapped,

            items: [
              BottomNavigationBarItem(
                icon: _buildIcon("assets/icons/home.png", AppColors.grey_500),
                activeIcon: _buildIcon("assets/icons/home.png", AppColors.main_blue_600),
                label: "Mashg'ulotlar",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon("assets/icons/game.png", AppColors.grey_500),
                activeIcon: _buildIcon("assets/icons/game.png", AppColors.main_blue_600),
                label: "O'yinlar",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon("assets/icons/consultation.png", AppColors.grey_500),
                activeIcon: _buildIcon("assets/icons/consultation.png", AppColors.main_blue_600),
                label: "Konsultatsiya",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon("assets/icons/community.png", AppColors.grey_500),
                activeIcon: _buildIcon("assets/icons/community.png", AppColors.main_blue_600),
                label: "Jamiyat",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon("assets/icons/profiles.png", AppColors.grey_500),
                activeIcon: _buildIcon("assets/icons/profiles.png", AppColors.main_blue_600),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}