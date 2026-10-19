import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/core/storage/level_state.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/map_route_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shiny_striped_progress_bar/shiny_striped_progress_bar.dart';

class _Category {
  final String title;
  final String sound;
  final String image;

  /// Ikonka halqasi gradienti (och → to'q)
  final List<Color> ring;

  const _Category({
    required this.title,
    required this.sound,
    required this.image,
    required this.ring,
  });
}

// Rasmlar: Microsoft Fluent Emoji 3D (MIT litsenziya)
const List<_Category> _categories = [
  _Category(
    title: "Artikulatsion\nmashqlar",
    sound: LevelProvider.firstSpeechArticulation,
    image: "assets/images/fs_artikulatsion.webp",
    ring: [Color(0xfffbd3cc), Color(0xffef8f80)],
  ),
  _Category(
    title: "Nafas\nmashqlari",
    sound: LevelProvider.firstSpeechBreath,
    image: "assets/images/fs_nafas.webp",
    ring: [Color(0xffb5e9f7), Color(0xff5ad4f2)],
  ),
  _Category(
    title: "Barmoq\nmashqlari",
    sound: LevelProvider.firstSpeechFinger,
    image: "assets/images/fs_barmoq.webp",
    ring: [Color(0xfffde7b0), Color(0xfff5be3c)],
  ),
  _Category(
    title: "Chiziq\nmashqlari",
    sound: LevelProvider.firstSpeechLine,
    image: "assets/images/fs_chiziq.webp",
    ring: [Color(0xffc8edc4), Color(0xff6cc864)],
  ),
];

/// "Ilk nutqni rivojlantirish" bo'limlari — har biri o'z xaritasini ochadi
class FirstSpeechCategoriesPage extends StatefulWidget {
  const FirstSpeechCategoriesPage({super.key});

  @override
  State<FirstSpeechCategoriesPage> createState() =>
      _FirstSpeechCategoriesPageState();
}

class _FirstSpeechCategoriesPageState extends State<FirstSpeechCategoriesPage> {
  @override
  void initState() {
    super.initState();
    // Kartalardagi progress uchun barcha bo'lim levellari oldindan yuklanadi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LevelProvider>();
      for (final c in _categories) {
        provider.preloadSound(c.sound);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/backround_xira.webp"),
            fit: BoxFit.fill,
            colorFilter: context.palette.backgroundImageFilter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60, width: double.infinity),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      "assets/images/arow_back.webp",
                      width: 24.w,
                      color: context.palette.icon,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Ilk nutqni rivojlantirish",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: context.palette.textStrong,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Sarlavha aniq o'rtada turishi uchun orqaga tugmasi bilan teng joy
                  SizedBox(width: 24.w),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _CategoryCard(
                    category: category,
                    levels: provider.levelsOf(category.sound),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MapRoadPage(
                          sound: category.sound,
                          scrollToCurrent: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _Category category;
  final List<LevelState>? levels;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.levels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = levels?.length ?? 0;
    final done = levels?.where((lv) => lv.stars > 0).length ?? 0;
    final progress = total == 0 ? 0.0 : done / total;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 7.h),
        child: Container(
          constraints: BoxConstraints(minHeight: 130.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/backround/bacround_sound.webp"),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.shade200.withValues(alpha: 0.5),
                spreadRadius: 4,
                blurRadius: 4,
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  // Rangli halqa ichida emoji
                  Container(
                    width: 76.w,
                    height: 76.w,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: category.ring,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          category.ring.first,
                          Colors.white,
                          0.6,
                        ),
                      ),
                      padding: EdgeInsets.all(10.w),
                      child: Image.asset(category.image),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // O'ng yuqoridagi yorliq bilan ustma-ust tushmasligi uchun
                        Padding(
                          padding: EdgeInsets.only(right: 70.w),
                          child: Text(
                            category.title,
                            style: TextStyle(
                              color: context.palette.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.sp,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 9.h,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: ShinyStripedProgressBar(
                                    // Progress o'zgarsa bar qayta chiziladi
                                    key: ValueKey(
                                      '${category.sound}_$progress',
                                    ),
                                    progressColor: AppColors.orange_200,
                                    stripeColor: AppColors.orange_500,
                                    targetProgress: progress,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "$done/$total",
                              style: TextStyle(
                                color: context.palette.textPrimary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: const AssetImage(
                                "assets/icons/circle.webp",
                              ),
                              radius: 15.r,
                              child: Transform.translate(
                                offset: const Offset(1, -1),
                                child: Image.asset(
                                  "assets/icons/play.webp",
                                  width: 13.w,
                                ),
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              done == 0 ? "Boshlash" : "Davom etish",
                              style: TextStyle(
                                color: const Color(0xff20B9E8),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: context.palette.primarySoft,
                  ),
                  child: Text(
                    total == 0 ? "..." : "$total ta mashq",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: context.palette.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
