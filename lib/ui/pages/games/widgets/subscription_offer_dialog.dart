import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/games/widgets/kid_widgets.dart';
import 'package:logosmart/ui/pages/profile/subscription_page.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

/// Pullik (obunasiz foydalanuvchi uchun yopiq) level yoki mashq bosilganda
/// obunaga taklif. Yagona tugma — "Obuna bo'lish" (obuna tariflariga o'tadi);
/// dialog tashqarisiga bosib yoki orqaga tugmasi bilan yopiladi.
/// Obuna sahifasidan qaytilganda true qaytaradi (ma'lumotni yangilash uchun).
Future<bool> showSubscriptionOffer(BuildContext context) async {
  final goToSubscription = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Yopish",
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 550),
    pageBuilder: (ctx, _, _) => const _SubscriptionOfferDialog(),
    transitionBuilder: (ctx, anim, _, child) {
      final scale = CurvedAnimation(
        parent: anim,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInBack,
      );
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
  if (goToSubscription != true || !context.mounted) return false;
  await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SubscriptionPage()));
  return true;
}

class _SubscriptionOfferDialog extends StatelessWidget {
  const _SubscriptionOfferDialog();

  static const _badge = [Color(0xFFFFC754), Color(0xFFFF8A00)];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final badgeSize = 112.w;
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Asosiy karta
                Container(
                  margin: EdgeInsets.only(top: badgeSize / 2),
                  padding: EdgeInsets.fromLTRB(
                    22.w,
                    badgeSize / 2 + 18.h,
                    22.w,
                    24.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: dark
                          ? [context.palette.surface, const Color(0xFF123F52)]
                          : const [Colors.white, Color(0xFFE6FBFF)],
                    ),
                    borderRadius: BorderRadius.circular(34.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: dark ? 0.1 : 1),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C0E8).withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Bu bosqich hali yopiq",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 23.sp,
                          fontWeight: FontWeight.w900,
                          color: context.palette.textStrong,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Obuna bo'ling va barcha o'yin hamda mashg'ulotlarni "
                        "oching!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: context.palette.textSecondary,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      const _Perks(),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        child: KidBounceButton(
                          label: "Obuna bo'lish",
                          colors: const [Color(0xFF33DCFF), Color(0xFF0096B5)],
                          leading: Image.asset(
                            "assets/icons/crown.webp",
                            width: 24.w,
                            height: 24.w,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ),
                    ],
                  ),
                ),

                // Yuqoridagi toj nishoni + qulf
                SizedBox(
                  width: badgeSize * 2.2,
                  height: badgeSize * 1.25,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      const KidTwinkleStars(
                        positions: [
                          Alignment(-0.95, -0.2),
                          Alignment(-0.7, 0.7),
                          Alignment(0.9, -0.5),
                          Alignment(0.75, 0.6),
                          Alignment(-0.45, -1),
                        ],
                        size: 22,
                      ),
                      KidFloating(
                        amplitude: 5,
                        child: SizedBox(
                          width: badgeSize,
                          height: badgeSize,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _badge,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _badge.last.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/icons/crown.webp",
                                  width: badgeSize * 0.52,
                                  height: badgeSize * 0.52,
                                ),
                              ),
                              Positioned(
                                right: -4.w,
                                bottom: -2.h,
                                child: KidWiggle(
                                  child: Container(
                                    padding: EdgeInsets.all(7.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C0E8),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Obuna imkoniyatlari — ketma-ket "sakrab" chiqadigan pufakchalar.
class _Perks extends StatelessWidget {
  const _Perks();

  static const _items = [
    (Icons.videogame_asset_rounded, "Barcha\no'yinlar", Color(0xFF7C5CFF)),
    (Icons.lock_open_rounded, "Barcha\nbosqichlar", Color(0xFF00B37E)),
    (Icons.star_rounded, "Ko'proq\nyulduzlar", Color(0xFFFF8A00)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < _items.length; i++)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 500 + i * 180),
            curve: Interval(0.4, 1, curve: Curves.elasticOut),
            builder: (context, t, child) =>
                Transform.scale(scale: t, child: child),
            child: _Perk(
              icon: _items[i].$1,
              label: _items[i].$2,
              color: _items[i].$3,
            ),
          ),
      ],
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54.w,
          height: 54.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
          ),
          child: Icon(icon, color: color, size: 30.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: context.palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
