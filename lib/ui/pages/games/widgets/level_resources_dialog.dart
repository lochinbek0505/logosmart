import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/resources/level_resources.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
import 'package:logosmart/core/storage/level_state.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

/// Level ochishdan oldin: uning fayllari qurilmada bo'lmasa (birinchi yuklash o'tkazib
/// yuborilgan, video hali orqa fonda yuklanmagan va h.k.) — shu yerda yuklab olinadi.
/// Hammasi tayyor bo'lsa true; yuklab bo'lmasa (internet yo'q) false.
Future<bool> prepareLevelResources(BuildContext context, LevelState level) async {
  final manager = ResourceManager.instance;
  final paths = resourcePathsOfLevel(level);
  if (paths.isEmpty) return true;
  if (manager.hasManifest && manager.missingOf(paths).isEmpty) return true;

  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LevelResourcesDialog(paths: paths),
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
    return AlertDialog(
      backgroundColor: context.palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _failed ? Icons.wifi_off_rounded : Icons.cloud_download_rounded,
            size: 44.sp,
            color: _failed ? AppColors.red_500 : AppColors.main_blue_600,
          ),
          SizedBox(height: 12.h),
          Text(
            _failed
                ? "Mashg'ulotni yuklab bo'lmadi. Internetni tekshiring."
                : "Mashg'ulot tayyorlanmoqda...",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: context.palette.textStrong,
            ),
          ),
          if (!_failed) ...[
            SizedBox(height: 16.h),
            LinearProgressIndicator(
              value: _total == 0 ? null : _done / _total,
              color: AppColors.main_blue_600,
              backgroundColor: context.palette.border,
            ),
          ],
        ],
      ),
      actions: _failed
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Yopish"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main_blue_600,
                  foregroundColor: Colors.white,
                ),
                onPressed: _run,
                child: const Text("Qayta urinish"),
              ),
            ]
          : null,
    );
  }
}
