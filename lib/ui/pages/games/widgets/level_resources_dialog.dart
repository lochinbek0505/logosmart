import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/resources/level_resources.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
import 'package:logosmart/core/storage/level_state.dart';
import 'package:logosmart/ui/pages/games/widgets/kid_widgets.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

/// Level ochishdan oldin: uning fayllari qurilmada bo'lmasa (birinchi yuklash o'tkazib
/// yuborilgan, video hali orqa fonda yuklanmagan va h.k.) — shu yerda yuklab olinadi.
/// Hammasi tayyor bo'lsa true; yuklab bo'lmasa (internet yo'q) false.
Future<bool> prepareLevelResources(
  BuildContext context,
  LevelState level,
) async {
  final manager = ResourceManager.instance;
  final paths = resourcePathsOfLevel(level);
  if (paths.isEmpty) return true;
  if (manager.hasManifest && manager.missingOf(paths).isEmpty) return true;

  final ok = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => _LevelResourcesDialog(paths: paths),
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

class _LevelResourcesDialog extends StatefulWidget {
  const _LevelResourcesDialog({required this.paths});

  final Set<String> paths;

  @override
  State<_LevelResourcesDialog> createState() => _LevelResourcesDialogState();
}

class _LevelResourcesDialogState extends State<_LevelResourcesDialog> {
  int _done = 0;
  int _total = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _failed = false;
      _done = 0;
      _total = 0;
    });
    final ok = await ResourceManager.instance.ensureAll(
      widget.paths,
      onProgress: (done, total) {
        if (!mounted) return;
        setState(() {
          _done = done;
          _total = total;
        });
      },
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final percent = _total == 0 ? 0 : (_done / _total * 100).round();
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
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
                    padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 22.h),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (c, a) =>
                                ScaleTransition(scale: a, child: c),
                            child: _failed
                                ? KidWiggle(
                                    key: const ValueKey("fail"),
                                    child: _Bubble(
                                      color: AppColors.red_500,
                                      child: Icon(
                                        Icons.wifi_off_rounded,
                                        size: 44.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : KidFloating(
                                    key: const ValueKey("load"),
                                    amplitude: 7,
                                    tilt: 0.06,
                                    child: Image.asset(
                                      "assets/icons/helicopter.webp",
                                      width: 130.w,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            _failed
                                ? "Voy! Yuklab bo'lmadi"
                                : "Mashg'ulot yo'lda!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w900,
                              color: context.palette.textStrong,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _failed
                                ? "Internetni tekshirib, qaytadan urinib ko'ring."
                                : "Rasm va ovozlar yuklanmoqda, biroz kuting...",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: context.palette.textPrimary,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          if (!_failed) ...[
                            KidProgressBar(
                              value: _total == 0 ? null : _done / _total,
                            ),
                            SizedBox(height: 10.h),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _total == 0 ? "..." : "$percent%",
                                key: ValueKey(percent),
                                style: GoogleFonts.nunito(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.main_blue_700,
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: KidBounceButton(
                                label: "Qayta urinish",
                                leading: Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                                onPressed: _run,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                "Yopish",
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
            ),
          ),
        ),
      ),
    );
  }
}

/// Rangli dumaloq "pufak" ichidagi belgi.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92.w,
      height: 92.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
