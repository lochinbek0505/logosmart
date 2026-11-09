import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/home/home_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/map_route_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:logosmart/ui/pages/main/coming_soon_page.dart';
import 'package:logosmart/ui/pages/profile/profile_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
import 'package:logosmart/ui/pages/start/resource_download_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Track the currently selected tab index
  int _selectedIndex = 0;

  /// O'yin/mashq resurslari qurilmada bormi — yo'q bo'lsa avval yuklash ekrani
  bool _resourcesReady = ResourceManager.instance.coreReady;

  @override
  void initState() {
    super.initState();
    // Avval yuklangan bo'lsa — yangilanishlar va videolar orqa fonda
    if (_resourcesReady) ResourceManager.instance.syncInBackground(force: true);
  }

  // List of pages corresponding to the tabs
  List<Widget> get pages => [
    const HomePage(),
    // O'yinlar: barcha o'yinlar bitta xaritada (serverdan, GET /games), ketma-ket ochiladi
    MapRoadPage(sound: LevelProvider.gamesSound, embedded: true),
    ComingSoonPage(
      title: "Konsultatsiya",
      image: "assets/images/women.webp",
      description:
          "Tez orada farzandingiz nutqi bo'yicha logoped mutaxassislardan "
          "to'g'ridan-to'g'ri maslahat olishingiz mumkin bo'ladi.",
      features: const [
        ComingSoonFeature(Icons.video_call_rounded, "Logoped bilan onlayn uchrashuv"),
        ComingSoonFeature(Icons.chat_bubble_rounded, "Mutaxassisga savol yuborish"),
        ComingSoonFeature(Icons.event_note_rounded, "Shaxsiy mashg'ulot rejasi"),
      ],
      onAction: () => _onItemTapped(0),
    ),
    ComingSoonPage(
      title: "Jamiyat",
      image: "assets/images/ask_girl.webp",
      description:
          "Ota-onalar va mutaxassislar tajriba almashadigan, bir-birini "
          "qo'llab-quvvatlaydigan hamjamiyat tayyorlanmoqda.",
      features: const [
        ComingSoonFeature(Icons.forum_rounded, "Ota-onalar bilan muhokamalar"),
        ComingSoonFeature(Icons.lightbulb_rounded, "Mutaxassislardan foydali maslahatlar"),
        ComingSoonFeature(Icons.emoji_events_rounded, "Farzandingiz yutuqlarini ulashish"),
      ],
      onAction: () => _onItemTapped(0),
    ),
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
      padding: EdgeInsets.only(bottom: 8.h, top: 8.h),
      // Icon va label orasiga 8.h lik joy
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
    if (!_resourcesReady) {
      return ResourceDownloadPage(
        onReady: () => setState(() => _resourcesReady = true),
        onSkip: () => setState(() => _resourcesReady = true),
      );
    }
    return Scaffold(
      // Display the page that corresponds to the selected index
      body: Stack(
        children: [
          Positioned.fill(child: pages[_selectedIndex]),
          // Birinchi yuklash o'tkazib yuborilgan bo'lsa — boshqa tablarda ham yuklanish holati
          // (Bosh sahifada o'rniga ResourceStatusCard turadi)
          if (_selectedIndex != 0)
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 96.h,
              child: const _ResourceBanner(),
            ),
        ],
      ),
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
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: context.palette.navBar,
            elevation: 0,
            // Container'da shadow borligi uchun default shadow olinadi

            // Colors matching your design
            selectedItemColor: AppColors.main_blue_600,
            unselectedItemColor: AppColors.grey_500,

            selectedLabelStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),

            unselectedLabelStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),

            currentIndex: _selectedIndex,
            onTap: _onItemTapped,

            items: [
              BottomNavigationBarItem(
                icon: _buildIcon("assets/icons/home.webp", AppColors.grey_500),
                activeIcon: _buildIcon(
                  "assets/icons/home.webp",
                  AppColors.main_blue_600,
                ),
                label: "Mashg'ulotlar",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon("assets/icons/game.webp", AppColors.grey_500),
                activeIcon: _buildIcon(
                  "assets/icons/game.webp",
                  AppColors.main_blue_600,
                ),
                label: "O'yinlar",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  "assets/icons/consultation.webp",
                  AppColors.grey_500,
                ),
                activeIcon: _buildIcon(
                  "assets/icons/consultation.webp",
                  AppColors.main_blue_600,
                ),
                label: "Konsultatsiya",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  "assets/icons/community.webp",
                  AppColors.grey_500,
                ),
                activeIcon: _buildIcon(
                  "assets/icons/community.webp",
                  AppColors.main_blue_600,
                ),
                label: "Jamiyat",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  "assets/icons/profiles.webp",
                  AppColors.grey_500,
                ),
                activeIcon: _buildIcon(
                  "assets/icons/profiles.webp",
                  AppColors.main_blue_600,
                ),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asosiy resurslar to'liq yuklanmaguncha pastda kichik holat paneli
class _ResourceBanner extends StatelessWidget {
  const _ResourceBanner();

  @override
  Widget build(BuildContext context) {
    final manager = ResourceManager.instance;
    return ValueListenableBuilder<bool>(
      valueListenable: manager.coreReadyNotifier,
      builder: (context, ready, _) {
        if (ready) return const SizedBox.shrink();
        return ValueListenableBuilder<ResourceProgress>(
          valueListenable: manager.progress,
          builder: (context, p, _) {
            final failed = p.error != null;
            return Material(
              color: context.palette.surface,
              elevation: 4,
              borderRadius: BorderRadius.circular(14.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(14.r),
                // Xato bo'lsa — bosib qayta urinish
                onTap: failed ? () => manager.syncInBackground(force: true) : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Icon(
                        failed ? Icons.wifi_off_rounded : Icons.cloud_download_rounded,
                        size: 20.sp,
                        color: failed ? AppColors.red_500 : AppColors.main_blue_600,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              failed
                                  ? "Yuklash to'xtadi — qayta urinish uchun bosing"
                                  : "Mashg'ulotlar yuklanmoqda: ${(p.fraction * 100).round()}%",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: context.palette.textStrong,
                              ),
                            ),
                            if (!failed) ...[
                              SizedBox(height: 6.h),
                              LinearProgressIndicator(
                                value: p.totalFiles == 0 ? null : p.fraction,
                                minHeight: 4.h,
                                color: AppColors.main_blue_600,
                                backgroundColor: context.palette.border,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
