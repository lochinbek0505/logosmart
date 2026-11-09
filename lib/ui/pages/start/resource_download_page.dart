import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
import 'package:logosmart/ui/pages/games/widgets/kid_widgets.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

/// Login'dan keyin birinchi marta: o'yin va mashq resurslari (asosiy guruh) yuklanadi.
/// Tugagach [onReady]. Internet yo'q / juda sekin bo'lsa foydalanuvchi [onSkip] bilan
/// ilovaga kirishi mumkin — yuklash orqa fonda davom etadi, level ochilganda uning
/// fayllari alohida yuklanadi.
class ResourceDownloadPage extends StatefulWidget {
  const ResourceDownloadPage({super.key, required this.onReady, required this.onSkip});

  final VoidCallback onReady;
  final VoidCallback onSkip;

  @override
  State<ResourceDownloadPage> createState() => _ResourceDownloadPageState();
}

class _ResourceDownloadPageState extends State<ResourceDownloadPage> {
  /// Shuncha vaqtdan keyin, yuklash hali uzoq davom etsa — "ilovaga kirish" tugmasi chiqadi
  static const Duration _skipAfter = Duration(seconds: 20);
  static const Duration _slowEta = Duration(minutes: 2);

  final _manager = ResourceManager.instance;
  bool _running = false;
  bool _waitedLong = false;
  Timer? _timer;

  /// Xatodan keyin o'zi qayta urinishgacha qolgan soniyalar (null — kutilmayapti)
  int? _retryIn;
  Timer? _retryTimer;
  int _failures = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_skipAfter, () {
      if (mounted) setState(() => _waitedLong = true);
    });
    // Internet qaytganda yuklash orqa fonda ham davom etadi — tugasa shu yerda ham
    // ilovaga o'tiladi
    _manager.coreReadyNotifier.addListener(_onCoreReady);
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _retryTimer?.cancel();
    _manager.coreReadyNotifier.removeListener(_onCoreReady);
    super.dispose();
  }

  void _onCoreReady() {
    if (_manager.coreReadyNotifier.value) _finish();
  }

  void _finish() {
    if (_done || !mounted) return;
    _done = true;
    _retryTimer?.cancel();
    widget.onReady();
  }

  Future<void> _start() async {
    if (_running || _done) return;
    _retryTimer?.cancel();
    setState(() {
      _running = true;
      _retryIn = null;
    });
    final ok = await _manager.downloadCore();
    if (!mounted) return;
    setState(() => _running = false);
    if (ok) {
      _finish();
    } else {
      _scheduleRetry();
    }
  }

  /// Foydalanuvchi tugma bosishini kutmasdan o'zi qayta urinadi: 5, 10, 20, 30 soniya.
  /// Joy yetmasa kutadi — foydalanuvchi xotirani bo'shatib "Qayta urinish" bosadi.
  void _scheduleRetry() {
    if (_manager.progress.value.errorKind == ResourceErrorKind.noSpace) return;
    final seconds = const [5, 10, 20, 30][math.min(_failures, 3)];
    _failures++;
    setState(() => _retryIn = seconds);
    _retryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      final left = (_retryIn ?? 1) - 1;
      if (left <= 0) {
        t.cancel();
        _start();
      } else {
        setState(() => _retryIn = left);
      }
    });
  }

  void _skip() {
    // Yuklash to'xtamaydi — orqa fonda davom etadi
    _manager.syncInBackground(force: true);
    widget.onSkip();
  }

  String _mb(num bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

  String _eta(Duration d) {
    if (d.inMinutes >= 1) return "~${d.inMinutes} daqiqa ${d.inSeconds % 60} soniya";
    return "~${d.inSeconds} soniya";
  }

  IconData _icon(ResourceErrorKind? kind) => switch (kind) {
        ResourceErrorKind.noSpace => Icons.sd_card_alert_rounded,
        ResourceErrorKind.server => Icons.cloud_off_rounded,
        _ => Icons.wifi_off_rounded,
      };

  /// Foizga qarab bolalarga qiziqarli izoh
  String _cheer(double f) {
    if (f < 0.25) return "Vertolyot uchishga tayyorlanmoqda...";
    if (f < 0.5) return "O'yinlar yo'lga chiqdi!";
    if (f < 0.75) return "Yarmidan o'tdik, zo'r!";
    if (f < 1) return "Oz qoldi, deyarli yetib keldik!";
    return "Tayyor!";
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = GoogleFonts.nunito(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: context.palette.textPrimary,
    );
    return Scaffold(
      body: KidSkyBackground(
        dark: dark,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ValueListenableBuilder<ResourceProgress>(
              valueListenable: _manager.progress,
              builder: (context, p, _) {
                final hasError = p.error != null && !_running;
                final eta = p.eta;
                final slow = eta != null && eta > _slowEta;
                final canSkip = hasError || (_waitedLong && (slow || p.retrying));
                final percent = (p.fraction * 100).round();
                // Katta shrift / kichik ekranda matnlar sig'masa scroll bo'ladi
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Qahramon: uchayotgan vertolyot yoki xato belgisi
                        SizedBox(
                          height: 190.h,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                            child: hasError
                                ? KidWiggle(
                                    key: const ValueKey("error"),
                                    child: Container(
                                      width: 120.w,
                                      height: 120.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.red_500,
                                        border: Border.all(color: Colors.white, width: 6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.red_500.withValues(alpha: 0.4),
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Icon(_icon(p.errorKind), size: 60.sp, color: Colors.white),
                                    ),
                                  )
                                : Stack(
                                    key: const ValueKey("loading"),
                                    alignment: Alignment.center,
                                    children: [
                                      const KidTwinkleStars(
                                        positions: [
                                          Alignment(-0.9, -0.7),
                                          Alignment(0.85, -0.85),
                                          Alignment(-0.75, 0.75),
                                          Alignment(0.95, 0.5),
                                          Alignment(0.1, -1),
                                        ],
                                        size: 24,
                                      ),
                                      KidFloating(
                                        amplitude: 10,
                                        tilt: 0.06,
                                        child: Image.asset(
                                          "assets/icons/helicopter.webp",
                                          width: 210.w,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Oq karta
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
                          decoration: BoxDecoration(
                            color: context.palette.surface.withValues(alpha: dark ? 0.9 : 0.92),
                            borderRadius: BorderRadius.circular(32.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: dark ? 0.08 : 1),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0096B5).withValues(alpha: 0.18),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hasError ? "Voy! Yuklab bo'lmadi" : "Mashg'ulotlar tayyorlanmoqda",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: context.palette.textStrong,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                hasError
                                    ? p.error!
                                    : p.totalFiles > 0
                                        ? _cheer(p.fraction)
                                        : "O'yin va mashqlar uchun rasm va ovozlar yuklab olinmoqda. "
                                            "Bu faqat bir marta bo'ladi.",
                                textAlign: TextAlign.center,
                                style: textStyle.copyWith(fontSize: 15.sp),
                              ),
                              if (!hasError && _manager.onMobileData && p.totalBytes > 0) ...[
                                SizedBox(height: 10.h),
                                KidInfoChip(
                                  icon: Icons.signal_cellular_alt_rounded,
                                  text: "Mobil internet: ~${_mb(p.totalBytes)} MB",
                                  color: AppColors.orange_700,
                                ),
                              ],
                              SizedBox(height: 22.h),
                              KidProgressBar(
                                value: p.totalFiles == 0 ? null : p.fraction,
                                height: 26.h,
                                colors: hasError
                                    ? const [Color(0xFFFF8A8A), Color(0xFFE53935)]
                                    : const [Color(0xFF54E2FF), Color(0xFF00C0E8)],
                                trackColor: dark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE6FBFF),
                              ),
                              SizedBox(height: 12.h),
                              if (p.totalFiles > 0)
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                                  child: Text(
                                    "$percent%",
                                    key: ValueKey(percent),
                                    style: GoogleFonts.nunito(
                                      fontSize: 34.sp,
                                      fontWeight: FontWeight.w900,
                                      color: hasError ? AppColors.red_500 : AppColors.main_blue_700,
                                    ),
                                  ),
                                ),
                              if (p.totalFiles > 0 || p.retrying) ...[
                                SizedBox(height: 8.h),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: [
                                    if (p.totalFiles > 0)
                                      KidInfoChip(
                                        icon: Icons.cloud_download_rounded,
                                        text: "${_mb(p.doneBytes)} / ${_mb(p.totalBytes)} MB",
                                      ),
                                    if (!hasError && p.retrying)
                                      KidInfoChip(
                                        icon: Icons.sync_rounded,
                                        text: "Qayta ulanilmoqda...",
                                        color: AppColors.orange_700,
                                      )
                                    else if (!hasError && p.bytesPerSecond > 0) ...[
                                      KidInfoChip(
                                        icon: Icons.speed_rounded,
                                        text: "${(p.bytesPerSecond / 1024).round()} KB/s",
                                      ),
                                      if (eta != null)
                                        KidInfoChip(
                                          icon: Icons.timer_rounded,
                                          text: _eta(eta),
                                        ),
                                    ],
                                  ],
                                ),
                              ],
                              if (hasError && _retryIn != null) ...[
                                SizedBox(height: 16.h),
                                KidInfoChip(
                                  icon: Icons.autorenew_rounded,
                                  text: "$_retryIn soniyadan keyin o'zi qayta urinadi",
                                ),
                              ],
                              if (hasError) ...[
                                SizedBox(height: 22.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: KidBounceButton(
                                    label: "Hozir qayta urinish",
                                    leading: Icon(Icons.refresh_rounded, color: Colors.white, size: 24.sp),
                                    onPressed: _start,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (canSkip) ...[
                          SizedBox(height: 14.h),
                          TextButton.icon(
                            onPressed: _skip,
                            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.main_blue_700),
                            label: Text(
                              "Hozircha ilovaga kirish",
                              style: textStyle.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.main_blue_700,
                              ),
                            ),
                          ),
                          Text(
                            "Yuklash orqa fonda davom etadi. Mashg'ulot ochilganda uning fayllari "
                            "alohida yuklanadi.",
                            textAlign: TextAlign.center,
                            style: textStyle.copyWith(fontSize: 12.sp),
                          ),
                        ],
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
