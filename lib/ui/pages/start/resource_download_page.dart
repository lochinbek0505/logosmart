import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
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

  @override
  void initState() {
    super.initState();
    _timer = Timer(_skipAfter, () {
      if (mounted) setState(() => _waitedLong = true);
    });
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (_running) return;
    setState(() => _running = true);
    final ok = await _manager.downloadCore();
    if (!mounted) return;
    setState(() => _running = false);
    if (ok) widget.onReady();
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
        null => Icons.cloud_download_rounded,
        _ => Icons.wifi_off_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.nunito(fontSize: 14.sp, color: context.palette.textPrimary);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/backround_xira.webp"),
            fit: BoxFit.cover,
            colorFilter: context.palette.backgroundImageFilter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: ValueListenableBuilder<ResourceProgress>(
              valueListenable: _manager.progress,
              builder: (context, p, _) {
                final hasError = p.error != null && !_running;
                final eta = p.eta;
                final slow = eta != null && eta > _slowEta;
                final canSkip = hasError || (_waitedLong && (slow || p.retrying));
                // Katta shrift / kichik ekranda matnlar sig'masa scroll bo'ladi
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _icon(hasError ? p.errorKind : null),
                      size: 72.sp,
                      color: hasError ? AppColors.red_500 : AppColors.main_blue_600,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      hasError ? "Yuklab bo'lmadi" : "Mashg'ulotlar tayyorlanmoqda",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: context.palette.textStrong,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      hasError
                          ? p.error!
                          : "O'yin va mashqlar uchun rasm va ovozlar yuklab olinmoqda. "
                              "Bu faqat bir marta bo'ladi.",
                      textAlign: TextAlign.center,
                      style: textStyle.copyWith(fontSize: 15.sp),
                    ),
                    if (!hasError && _manager.onMobileData && p.totalBytes > 0) ...[
                      SizedBox(height: 8.h),
                      Text(
                        "Mobil internet: ~${_mb(p.totalBytes)} MB sarflanadi",
                        textAlign: TextAlign.center,
                        style: textStyle.copyWith(fontSize: 13.sp, color: Colors.orange.shade700),
                      ),
                    ],
                    SizedBox(height: 28.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: p.totalFiles == 0 ? null : p.fraction,
                        minHeight: 10.h,
                        backgroundColor: context.palette.border,
                        color: hasError ? AppColors.red_500 : AppColors.main_blue_600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    if (p.totalFiles > 0)
                      Text(
                        "${(p.fraction * 100).round()}%  ·  ${_mb(p.doneBytes)} / ${_mb(p.totalBytes)} MB",
                        style: textStyle.copyWith(fontWeight: FontWeight.w700),
                      ),
                    if (!hasError && p.retrying) ...[
                      SizedBox(height: 6.h),
                      Text(
                        "Aloqa uzildi, qayta ulanilmoqda...",
                        style: textStyle.copyWith(fontSize: 13.sp, color: Colors.orange.shade700),
                      ),
                    ] else if (!hasError && p.bytesPerSecond > 0) ...[
                      SizedBox(height: 6.h),
                      Text(
                        "${(p.bytesPerSecond / 1024).round()} KB/s"
                        "${eta != null ? "  ·  qoldi ${_eta(eta)}" : ""}",
                        style: textStyle.copyWith(fontSize: 13.sp),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    if (hasError)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main_blue_600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                        ),
                        onPressed: _start,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Qayta urinish"),
                      ),
                    if (canSkip) ...[
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          "Hozircha ilovaga kirish",
                          style: textStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.main_blue_600,
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
