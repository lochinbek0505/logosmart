import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/network/network_status.dart';
import 'package:logosmart/ui/pages/games/widgets/kid_widgets.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

const String _title = "Internet yo'q";
const String _message =
    "Internet uxlab qolibdi! Kattalardan Wi-Fi yoki mobil internetni "
    "yoqib berishni so'ra. Internet qaytsa, o'zim davom ettiraman!";
const String _checkingTitle = "Internetni qidiryapman...";
const String _checkingMessage = "Bir zumda! Server bilan salomlashyapman.";

/// Tekshiruv shundan tez tugasa oyna umuman ko'rinmaydi (miltillamasin)
const Duration _showDialogAfter = Duration(milliseconds: 300);

/// Internet bo'lsa true. Tekshiruv cho'zilsa — "Internet qidirilmoqda" oynasi
/// darhol ko'rinadi (noma'lum kutish bo'lmasin); internet topilmasa o'sha oyna
/// "Internet yo'q" holatiga o'tadi va false qaytadi.
Future<bool> ensureOnline(BuildContext context) async {
  final status = NetworkStatus.instance;
  if (status.recentlyOnline) return true;

  final check = status.check();
  final quick = await Future.any<bool?>([
    check,
    Future<bool?>.delayed(_showDialogAfter, () => null),
  ]);
  if (quick == true) return true;
  if (!context.mounted) return false;
  return _showInternetDialog(context, pending: quick == null ? check : null);
}

/// "Internet yo'q" oynasi. "Qayta urinish"da internet qaytgan bo'lsa true.
Future<bool> showNoInternetDialog(BuildContext context) =>
    _showInternetDialog(context);

Future<bool> _showInternetDialog(
  BuildContext context, {
  Future<bool>? pending,
}) async {
  final ok = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'no_internet',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => _InternetDialog(pending: pending),
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        child: child,
      ),
    ),
  );
  return ok == true;
}

class _InternetDialog extends StatefulWidget {
  const _InternetDialog({this.pending});

  /// Allaqachon boshlangan tekshiruv (bo'lsa — "qidiryapman" holatida ochiladi)
  final Future<bool>? pending;

  @override
  State<_InternetDialog> createState() => _InternetDialogState();
}

class _InternetDialogState extends State<_InternetDialog> {
  late bool _checking = widget.pending != null;

  @override
  void initState() {
    super.initState();
    NetworkStatus.instance.addListener(_onNetwork);
    final pending = widget.pending;
    if (pending != null) _await(pending);
  }

  @override
  void dispose() {
    NetworkStatus.instance.removeListener(_onNetwork);
    super.dispose();
  }

  /// Internet qaytdi — bola tugma bosishini kutmasdan davom etamiz
  void _onNetwork() {
    if (!_checking && NetworkStatus.instance.isOnline) _retry();
  }

  Future<void> _retry() => _await(NetworkStatus.instance.check(force: true));

  Future<void> _await(Future<bool> check) async {
    if (mounted) setState(() => _checking = true);
    final ok = await check;
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _InternetCard(
              key: const ValueKey('no_internet_dialog'),
              checking: _checking,
              onRetry: _retry,
              secondaryLabel: _checking ? "Bekor qilish" : "Yopish",
              onSecondary: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
      ),
    );
  }
}

/// Xarita o'rnida ko'rsatiladigan to'liq ekran: internet yo'q, kirib bo'lmaydi.
/// Internet qaytsa (tarmoq o'zgarishi yoki "Qayta urinish") [onOnline] chaqiriladi.
class NoInternetView extends StatefulWidget {
  const NoInternetView({super.key, required this.onOnline, this.onBack});

  final VoidCallback onOnline;

  /// Tab ichida emas, alohida sahifa bo'lsa — "Orqaga" tugmasi
  final VoidCallback? onBack;

  @override
  State<NoInternetView> createState() => _NoInternetViewState();
}

class _NoInternetViewState extends State<NoInternetView> {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    NetworkStatus.instance.addListener(_onNetwork);
  }

  @override
  void dispose() {
    NetworkStatus.instance.removeListener(_onNetwork);
    super.dispose();
  }

  void _onNetwork() {
    if (NetworkStatus.instance.isOnline && mounted) widget.onOnline();
  }

  Future<void> _retry() async {
    setState(() => _checking = true);
    final ok = await NetworkStatus.instance.check(force: true);
    if (!mounted) return;
    setState(() => _checking = false);
    if (ok) widget.onOnline();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _InternetCard(
            key: const ValueKey('no_internet_view'),
            checking: _checking,
            onRetry: _retry,
            secondaryLabel: widget.onBack == null ? null : "Orqaga",
            onSecondary: widget.onBack,
          ),
        ),
      ),
    );
  }
}

/// Oyna va to'liq ekran uchun umumiy karta: osmon foni, sahna, matn, tugmalar.
/// [checking] — internet qidirilmoqda (radar + to'lib boruvchi halqa),
/// aks holda — yomg'irli bulut va "Qayta urinish".
class _InternetCard extends StatelessWidget {
  const _InternetCard({
    super.key,
    required this.checking,
    required this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
  });

  final bool checking;
  final VoidCallback onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(34.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: dark ? 0.1 : 1),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(34.r),
        ),
        child: KidSkyBackground(
          dark: dark,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 16.h),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 160.h,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      transitionBuilder: (c, a) => ScaleTransition(
                        scale: CurvedAnimation(
                          parent: a,
                          curve: Curves.elasticOut,
                        ),
                        child: FadeTransition(opacity: a, child: c),
                      ),
                      child: checking
                          ? const _SearchScene(key: ValueKey('search'))
                          : const KidRainCloud(key: ValueKey('rain')),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _FadeText(
                    text: checking ? _checkingTitle : _title,
                    style: GoogleFonts.nunito(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: context.palette.textStrong,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _FadeText(
                    text: checking ? _checkingMessage : _message,
                    style: GoogleFonts.nunito(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: context.palette.textPrimary,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  if (!checking)
                    SizedBox(
                      width: double.infinity,
                      child: KidBounceButton(
                        label: "Qayta urinish",
                        leading: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                        onPressed: onRetry,
                      ),
                    ),
                  if (secondaryLabel != null) ...[
                    SizedBox(height: 4.h),
                    TextButton(
                      onPressed: onSecondary,
                      child: Text(
                        secondaryLabel!,
                        style: GoogleFonts.nunito(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: context.palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeText extends StatelessWidget {
  const _FadeText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}

/// "Qidiryapman": markazda sakrab turgan Wi-Fi belgisi, undan tarqaluvchi
/// radar to'lqinlari, atrofida aylanuvchi yulduzcha va eng uzoq kutish
/// vaqtiga ([NetworkStatus.maxCheckDuration]) qarab to'lib boruvchi halqa.
class _SearchScene extends StatefulWidget {
  const _SearchScene({super.key});

  @override
  State<_SearchScene> createState() => _SearchSceneState();
}

class _SearchSceneState extends State<_SearchScene>
    with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  late final AnimationController _wait = AnimationController(
    vsync: this,
    duration: NetworkStatus.maxCheckDuration,
  )..forward();

  @override
  void dispose() {
    _loop.dispose();
    _wait.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double core = 76.w;
    final double ring = 132.w;
    const blue = Color(0xFF00B4D8);

    return AnimatedBuilder(
      animation: Listenable.merge([_loop, _wait]),
      builder: (context, _) {
        final t = _loop.value;
        final bounce = math.sin(t * 2 * math.pi) * 4;
        return Center(
          child: SizedBox(
            width: ring + 24.w,
            height: ring + 24.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Radar to'lqinlari
                for (var i = 0; i < 3; i++)
                  Builder(
                    builder: (_) {
                      final p = (t + i / 3) % 1;
                      return Opacity(
                        opacity: (1 - p) * 0.55,
                        child: Container(
                          width: core + (ring - core) * p,
                          height: core + (ring - core) * p,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: blue, width: 3),
                          ),
                        ),
                      );
                    },
                  ),
                // Kutish halqasi: qancha kutish qolganini ko'rsatadi
                SizedBox(
                  width: ring,
                  height: ring,
                  child: CircularProgressIndicator(
                    value: _wait.value,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    color: AppColors.main_blue_600,
                  ),
                ),
                // Halqa bo'ylab aylanuvchi yulduzcha
                Transform.translate(
                  offset: Offset.fromDirection(
                    t * 2 * math.pi - math.pi / 2,
                    ring / 2,
                  ),
                  child: Image.asset(
                    "assets/icons/star_orange.webp",
                    width: 22.w,
                    height: 22.w,
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, bounce),
                  child: Container(
                    width: core,
                    height: core,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: blue.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _WifiBars(
                      progress: t,
                      color: blue,
                      size: core * 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Wi-Fi belgisi: chiziqlari navbatma-navbat yonib-o'chadi ("signal qidirish")
class _WifiBars extends StatelessWidget {
  const _WifiBars({
    required this.progress,
    required this.color,
    required this.size,
  });

  final double progress;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    // 0..3 — nechta yoy yonib turibdi
    final lit = (progress * 4).floor().clamp(0, 3);
    final icons = [
      Icons.wifi_1_bar_rounded,
      Icons.wifi_2_bar_rounded,
      Icons.wifi_rounded,
    ];
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.wifi_rounded,
            size: size,
            color: color.withValues(alpha: 0.18),
          ),
          if (lit > 0) Icon(icons[lit - 1], size: size, color: color),
        ],
      ),
    );
  }
}
