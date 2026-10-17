import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/alphabet_page.dart';
import 'package:logosmart/ui/pages/main/videolesson/VideoLessonsPage.dart';
import 'package:logosmart/ui/pages/profile/NotificationPage.dart';
import 'package:logosmart/ui/pages/profile/providers/notifications_provider.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shiny_striped_progress_bar/shiny_striped_progress_bar.dart';

import '../diagnostic/diagnostic_group_page.dart';
import '../games/alphabet_map/map_route_page.dart';
import '../games/alphabet_map/provider/level_provider.dart';
import '../main/firstspeech/StartSpeechPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> cards = [
    {
      "title": "Ilk nutqni\nrivojlantirish",
      "image": "assets/images/mashgulot_bad.png",
      "mainColor": const Color(0xffebb6ae),
      "text": "4+ yosh",
      "page": StartSpeechPage(),
    },
    {
      "title": "Tovushlar\ntalaffuzini\nrivojlantirish",
      "image": "assets/images/mashgulot_son.png",
      "mainColor": const Color(0xff20B9E8),
      "text": "3-5 yosh",
      "page": AlphabetPage(),
    },
    {
      "title": "Video\nmashg'ulotlar",
      "image": "assets/images/mashgulot_nice.png",
      "mainColor": Colors.blueGrey,
      "text": "0-5 yosh",
      "page": VideoLessonsPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).init(context, silent: true);
      context.read<NotificationsProvider>().refreshUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final profile = context.watch<ProfileProvider>().profileResponse;
    final unreadCount = context.watch<NotificationsProvider>().unreadCount;

    return Scaffold(
      backgroundColor: context.palette.backgroundTinted,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header AppBar
            SliverAppBar(
              automaticallyImplyLeading: false,
              collapsedHeight: 70.h,
              backgroundColor: context.palette.backgroundTinted,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SizedBox(
                  height: 55.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Assalomu alaykum",
                                    style: GoogleFonts.nunito(
                                      fontSize: 19.sp,
                                      color: context.palette.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    (profile.fullName ?? "").isEmpty
                                        ? ""
                                        : "${profile.fullName} !",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.nunito(
                                      fontSize: 23.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationPage(),
                            ),
                          );
                          if (!context.mounted) return;
                          context
                              .read<NotificationsProvider>()
                              .refreshUnreadCount();
                        },
                        child: Badge(
                          isLabelVisible: unreadCount > 0,
                          label: Text(
                            unreadCount > 99 ? "99+" : "$unreadCount",
                          ),
                          backgroundColor: AppColors.red_400,
                          child: ImageIcon(
                            const AssetImage("assets/icons/notification.png"),
                            size: 24.w,
                            color: context.palette.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _LastActionHeaderDelegate(
                minHeight: 110.h,
                maxHeight: 110.h,
                child: _buildLastActionCard(context, size),
              ),
            ),

            // Diagnostic card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: 8.h,
                  top: 20.h,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (builder) => DiagnosticGroupPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 152.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/diagnostika.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ekpress-\ndiagnostika",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Container(
                                width: 125.w,
                                height: 45.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.orange.shade400,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Boshlash",
                                        style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Card(
                                        elevation: 2,
                                        margin: EdgeInsets.zero,
                                        // Standart bo'shliqni olib tashlash
                                        shape: const CircleBorder(),
                                        // <--- Asosiy yechim
                                        shadowColor: Colors.orange.shade800,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.orange,
                                          radius: 10.r,
                                          child: ImageIcon(
                                            AssetImage(
                                              "assets/icons/right_back.png",
                                            ),
                                            size: 5.w,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Cards list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: cards.length,
                (context, index) => Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0.h,
                    horizontal: 16.w,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 190.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(cards[index]["image"]),
                        fit: BoxFit.fill,
                        // Karta rasmi oq fonli — qorong'i mavzuda ko'zni
                        // qamashtirmasligi uchun biroz xiralashtiramiz
                        colorFilter: context.isDarkMode
                            ? const ColorFilter.mode(
                                Color(0x26000000),
                                BlendMode.srcATop,
                              )
                            : null,
                      ),
                      boxShadow: context.isDarkMode
                          ? [
                              BoxShadow(
                                color: context.palette.shadow,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            top: 14,
                            bottom: 14,
                          ),
                          // Elementlar sig'may qolsa scroll bo'lishi uchun qo'shildi
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            // Scroll yumshoq va bilinmaydigan bo'lishi uchun
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cards[index]["title"],
                                  style: GoogleFonts.nunito(
                                    // Karta foni har doim och — matn mavzudan
                                    // qat'i nazar to'q bo'lishi kerak
                                    color: AppColors.grey_900,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (builder) =>
                                            cards[index]["page"],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 125.w,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(35.r),
                                      color: cards[index]["mainColor"],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Boshlash",
                                            style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 11.w,
                                            child: Transform.translate(
                                              offset: const Offset(0.9, 0),
                                              child: ImageIcon(
                                                const AssetImage(
                                                  "assets/icons/right_back.png",
                                                ),
                                                size: 12.w,
                                                color:
                                                    cards[index]["mainColor"],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                Row(
                                  children: [
                                    Container(
                                      width: 70.w,
                                      height: 25.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.green_600,
                                        borderRadius: BorderRadius.circular(
                                          46.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "40 ta o'yin",
                                          style: GoogleFonts.nunito(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Container(
                                      width: 60.w,
                                      height: 25.h,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade300,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          cards[index]["text"],
                                          style: GoogleFonts.nunito(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // "So'ngi harakat": oxirgi ochilgan tovush mashqi va undagi progress.
  // Bosilganda xarita bola kelib qolgan levelga surilgan holda ochiladi.
  Widget _buildLastActionCard(BuildContext context, Size size) {
    final activity = context.watch<LevelProvider>().lastActivity;

    final String title = activity == null
        ? "Mashg'ulotni boshlang"
        : "${activity.sound} tovushi: ${activity.levelNumber}-mashq";
    final String letterAsset =
        "assets/alphabet/${(activity?.sound ?? LevelProvider.defaultSound).toLowerCase()}.png";

    return Container(
      color: context.palette.backgroundTinted,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.center,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => activity == null
                  ? const AlphabetPage()
                  : MapRoadPage(sound: activity.sound, scrollToCurrent: true),
            ),
          );
        },
        child: Container(
          width: size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: context.palette.surface,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 26,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xff20B9E8),
                    radius: 13.r,
                    child: Transform.translate(
                      offset: const Offset(0.9, 0),
                      child: ImageIcon(
                        const AssetImage("assets/icons/right_back.png"),
                        size: 10.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "So'ngi harakat",
                      style: GoogleFonts.nunito(
                        fontSize: 14.sp,
                        color: context.palette.textStrong,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Container(
                          width: 50.r,
                          height: 50.r,
                          padding: EdgeInsets.all(2.r),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xffb5e9f7), Color(0xff5ad4f2)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.cyan.shade50,
                            ),
                            child: Center(
                              child: Image.asset(
                                letterAsset,
                                width: 28.r,
                                height: 28.r,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width - 146,
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  color: context.palette.textStrong,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: size.width - 146,
                              height: 9.h,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: ShinyStripedProgressBar(
                                  // Progress o'zgarsa bar qayta chiziladi
                                  key: ValueKey(activity?.progress ?? 0),
                                  progressColor: AppColors.orange_200,
                                  stripeColor: AppColors.orange_500,
                                  targetProgress: activity?.progress ?? 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LastActionHeaderDelegate extends SliverPersistentHeaderDelegate {
  _LastActionHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_LastActionHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
