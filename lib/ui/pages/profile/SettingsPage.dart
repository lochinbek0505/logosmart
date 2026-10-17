import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/core/service/app_settings.dart';
import 'package:logosmart/core/service/notification_service.dart';
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
                        "assets/images/arow_back.png",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        height: 55,
        decoration: _tileDecoration(p, 30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item["text"],
                style: TextStyle(
                  color: p.textStrong,
                  fontWeight: FontWeight.w400,
                  fontSize: 17.sp,
                ),
              ),
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
                    alignment:
                        isOn ? Alignment.centerRight : Alignment.centerLeft,
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
