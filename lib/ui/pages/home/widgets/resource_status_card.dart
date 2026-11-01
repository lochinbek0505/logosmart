import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

/// Bosh sahifada: orqa fonda resurslar yuklanayotgani (videolar, modellar, yangilanishlar).
/// Hech narsa yuklanmayotgan bo'lsa ko'rinmaydi.
class ResourceStatusCard extends StatelessWidget {
  const ResourceStatusCard({super.key});

  static String _what(Set<String> groups) {
    if (groups.contains(ResourceManager.coreGroup)) return "Mashg'ulotlar";
    final video = groups.contains('videos'), models = groups.contains('models');
    if (video && models) return "Video va kamera mashqlari";
    if (video) return "Video mashqlar";
    if (models) return "Kamera mashqlari";
    return "Mashg'ulotlar";
  }

  static String _mb(num bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final manager = ResourceManager.instance;
    return ValueListenableBuilder<ResourceStatus>(
      valueListenable: manager.status,
      builder: (context, st, _) {
        if (st.phase == ResourcePhase.idle) return const SizedBox.shrink();
        final p = st.progress;
        final what = _what(st.groups);

        final (IconData icon, Color color, String title, String? subtitle) = switch (st.phase) {
          ResourcePhase.downloading => (
              Icons.cloud_download_rounded,
              AppColors.main_blue_600,
              "$what yuklanmoqda: ${(p.fraction * 100).round()}%",
              p.retrying
                  ? "Aloqa uzildi, qayta ulanilmoqda..."
                  : "${_mb(p.doneBytes)} / ${_mb(p.totalBytes)} MB"
                      "${p.bytesPerSecond > 0 ? "  ·  ${(p.bytesPerSecond / 1024).round()} KB/s" : ""}",
            ),
          ResourcePhase.waitingWifi => (
              Icons.wifi_rounded,
              Colors.orange.shade700,
              "$what Wi-Fi'da yuklanadi",
              "${_mb(st.pendingBytes)} MB. Mashg'ulot ochilsa — kerakli fayli darhol yuklanadi.",
            ),
          ResourcePhase.failed => (
              p.errorKind == ResourceErrorKind.noSpace ? Icons.sd_card_alert_rounded : Icons.wifi_off_rounded,
              AppColors.red_500,
              "$what yuklanishi to'xtadi",
              p.error,
            ),
          ResourcePhase.idle => (Icons.check, Colors.transparent, "", null),
        };

        final String? action = switch (st.phase) {
          ResourcePhase.waitingWifi => "Hozir yuklash",
          ResourcePhase.failed => "Qayta urinish",
          _ => null,
        };

        return Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 22.sp, color: color),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: context.palette.textStrong,
                        ),
                      ),
                    ),
                    if (action != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.main_blue_600,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          minimumSize: Size(0, 32.h),
                        ),
                        onPressed: st.phase == ResourcePhase.waitingWifi
                            ? manager.downloadPendingNow
                            : () => manager.syncInBackground(force: true),
                        child: Text(
                          action,
                          style: GoogleFonts.nunito(fontSize: 13.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                if (st.phase == ResourcePhase.downloading) ...[
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: p.totalFiles == 0 ? null : p.fraction,
                      minHeight: 6.h,
                      color: color,
                      backgroundColor: context.palette.border,
                    ),
                  ),
                ],
                if (subtitle != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(fontSize: 12.sp, color: context.palette.textPrimary),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
