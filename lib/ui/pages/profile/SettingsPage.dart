import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/core/service/app_settings.dart';
import 'package:logosmart/core/service/notification_service.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
import 'package:logosmart/ui/pages/main/main_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppSettings _settings = AppSettings();

  late final List<Map<String, dynamic>> settings = [
    {
      "text": "Bildirishnomalar",
      "value": () => _settings.pushEnabled,
      // Backendda qurilma tokenini o'chiradi / qayta ro'yxatdan o'tkazadi
      "onChanged": NotificationService().setPushEnabled,
    },
    {
      "text": "Bildirishnoma ovozi",
      "value": () => _settings.notificationSound,
      "onChanged": _settings.setNotificationSound,
    },
    {
      "text": "O'yinlar fon ovozi",
      "value": () => _settings.gameMusic,
      "onChanged": _settings.setGameMusic,
    },
    {
      "text": "Vibratsiya",
      "value": () => _settings.vibration,
      "onChanged": (bool value) async {
        await _settings.setVibration(value);
        // Yoqilganini his qilish uchun
        _settings.vibrateSuccess();
      },
    },
    {
      "text": "Videolarni mobil internetda yuklash",
      "value": () => _settings.downloadOnMobile,
      "onChanged": (bool value) async {
        await _settings.setDownloadOnMobile(value);
        // Yoqilsa — kutib turgan videolar darhol yuklana boshlaydi
        if (value) ResourceManager.instance.syncInBackground(force: true);
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "assets/images/arow_back.webp",
                        width: 22,
                        color: p.icon,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "Sozlamalar",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: p.textStrong,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    _buildThemeSelector(p),
                    for (final item in settings) _buildSwitchTile(p, item),
                    _buildResourcesTile(p),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Yuklab olingan o'yin/mashq resurslari: hajmi va o'chirib qayta yuklash (sinash uchun)
  Widget _buildResourcesTile(AppPalette p) {
    final manager = ResourceManager.instance;
    return ValueListenableBuilder<ResourceStatus>(
      valueListenable: manager.status,
      builder: (context, status, _) {
        final mb = (manager.localBytes / (1024 * 1024)).toStringAsFixed(1);
        final busy = _clearing;
        return Padding(
          padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10, top: 6),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _tileDecoration(p, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yuklab olingan resurslar",
                  style: TextStyle(
                    color: p.textStrong,
                    fontWeight: FontWeight.w600,
                    fontSize: 17.sp,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${manager.localFiles} ta fayl · $mb MB"
                  "${status.phase == ResourcePhase.downloading ? " · yuklanmoqda..." : ""}",
                  style: TextStyle(color: p.textMuted, fontSize: 14.sp),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red_500,
                      side: const BorderSide(color: AppColors.red_500),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: busy ? null : _clearResources,
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_sweep_rounded),
                    label: Text(
                      "O'chirish va qayta yuklash",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
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

  bool _clearing = false;

  Future<void> _clearResources() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Resurslarni o'chirish"),
        content: const Text(
          "Yuklab olingan barcha rasm, ovoz, video va modellar o'chiriladi va "
          "qaytadan yuklab olinadi. Davom etilsinmi?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Bekor qilish"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "O'chirish",
              style: TextStyle(color: AppColors.red_500),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _clearing = true);
    await ResourceManager.instance.clearAll();
    if (!mounted) return;
    setState(() => _clearing = false);
    // Asosiy oyna qaytadan ochiladi — resurslar yo'q, shuning uchun yuklash ekrani chiqadi
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainPage()),
      (route) => false,
    );
  }

  BoxDecoration _tileDecoration(AppPalette p, double radius) {
    return BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: p.shadow,
          spreadRadius: 2,
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: p.border),
    );
  }

  Widget _buildThemeSelector(AppPalette p) {
    const options = [
      (ThemeMode.system, "Tizim", Icons.brightness_auto_rounded),
      (ThemeMode.light, "Yorug'", Icons.light_mode_rounded),
      (ThemeMode.dark, "Qorong'i", Icons.dark_mode_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: _tileDecoration(p, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mavzu",
              style: TextStyle(
                color: p.textStrong,
                fontWeight: FontWeight.w400,
                fontSize: 17.sp,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final (mode, label, icon) in options)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _ThemeOption(
                        label: label,
                        icon: icon,
                        selected: _settings.themeMode == mode,
                        onTap: () => _settings.setThemeMode(mode),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(AppPalette p, Map<String, dynamic> item) {
    final bool isOn = item["value"]();

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
      child: Container(
        width: double.infinity,
        // Uzun matn / katta shriftda qator kattalashadi (qat'iy 55 px emas)
        constraints: const BoxConstraints(minHeight: 55),
        decoration: _tileDecoration(p, 30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item["text"],
                  style: TextStyle(
                    color: p.textStrong,
                    fontWeight: FontWeight.w400,
                    fontSize: 17.sp,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  item["onChanged"](!isOn);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: 42,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: isOn ? p.primary : p.switchOff,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    alignment: isOn
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOn ? Colors.white : p.textMuted,
                        ),
                      ),
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

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? p.primarySoft : p.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? p.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: selected ? p.primary : p.textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? p.textPrimary : p.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
