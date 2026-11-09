import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/network/network_status.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

const String _title = "Internet yo'q";
const String _message =
    "O'yinlar va mashqlar internet orqali ishlaydi. Internetni yoqib, "
    "qayta urinib ko'ring.";

/// Internet bo'lsa true. Bo'lmasa ogohlantirish oynasi ko'rsatiladi va false.
Future<bool> ensureOnline(BuildContext context) async {
  if (await NetworkStatus.instance.check()) return true;
  if (!context.mounted) return false;
  return showNoInternetDialog(context);
}

/// "Internet yo'q" oynasi. "Qayta urinish"da internet qaytgan bo'lsa true.
Future<bool> showNoInternetDialog(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => const _NoInternetDialog(),
  );
  return ok == true;
}

class _NoInternetDialog extends StatefulWidget {
  const _NoInternetDialog();

  @override
  State<_NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<_NoInternetDialog> {
  bool _checking = false;

  Future<void> _retry() async {
    setState(() => _checking = true);
    final ok = await NetworkStatus.instance.check();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      content: _NoInternetContent(compact: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Yopish"),
        ),
        _RetryButton(checking: _checking, onPressed: _retry),
      ],
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
    final ok = await NetworkStatus.instance.check();
    if (!mounted) return;
    setState(() => _checking = false);
    if (ok) widget.onOnline();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Container(
          key: const ValueKey('no_internet_view'),
          padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 18.h),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _NoInternetContent(),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: _RetryButton(checking: _checking, onPressed: _retry),
              ),
              if (widget.onBack != null) ...[
                SizedBox(height: 6.h),
                TextButton(
                  onPressed: widget.onBack,
                  child: const Text("Orqaga"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoInternetContent extends StatelessWidget {
  const _NoInternetContent({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: (compact ? 64 : 84).r,
          height: (compact ? 64 : 84).r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.red_500.withValues(alpha: 0.12),
          ),
          child: Icon(
            Icons.wifi_off_rounded,
            size: (compact ? 34 : 44).sp,
            color: AppColors.red_500,
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          _title,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: (compact ? 18 : 21).sp,
            fontWeight: FontWeight.w800,
            color: context.palette.textStrong,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _message,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: context.palette.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.checking, required this.onPressed});

  final bool checking;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.main_blue_600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      onPressed: checking ? null : onPressed,
      child: checking
          ? SizedBox(
              width: 18.r,
              height: 18.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            )
          : const Text("Qayta urinish"),
    );
  }
}
