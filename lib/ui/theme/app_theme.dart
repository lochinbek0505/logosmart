import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Ilova bo'ylab ishlatiladigan semantik ranglar.
///
/// Sahifalarda to'g'ridan-to'g'ri `Colors.white` / `AppColors.grey_900` o'rniga
/// `context.palette.surface`, `context.palette.textPrimary` kabi tokenlardan
/// foydalaning — ular yorug' va qorong'i mavzuda o'zi almashadi.
/// Barcha qiymatlar [AppColors] bazasidan olingan.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.backgroundTinted,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.shadow,
    required this.textPrimary,
    required this.textStrong,
    required this.textSecondary,
    required this.textMuted,
    required this.icon,
    required this.primary,
    required this.primarySoft,
    required this.danger,
    required this.dangerSoft,
    required this.dangerBorder,
    required this.success,
    required this.navBar,
    required this.switchOff,
    required this.backgroundImageFilter,
  });

  /// Oddiy sahifa foni
  final Color background;

  /// Ko'k tusli sahifa foni (bosh sahifa va h.k.)
  final Color backgroundTinted;

  /// Karta, panel, dialog foni
  final Color surface;

  /// Kirish maydonlari, ikkilamchi bloklar foni
  final Color surfaceVariant;
  final Color border;
  final Color shadow;

  /// Sarlavhalar va asosiy matn (ko'k tusli)
  final Color textPrimary;

  /// Kuchli neytral matn (kulrang-qora)
  final Color textStrong;
  final Color textSecondary;
  final Color textMuted;

  /// Orqaga tugmasi va oddiy ikonkalar
  final Color icon;

  final Color primary;

  /// Asosiy rangning yumshoq foni (belgilar, chiplar)
  final Color primarySoft;
  final Color danger;
  final Color dangerSoft;
  final Color dangerBorder;
  final Color success;
  final Color navBar;
  final Color switchOff;

  /// Yorug' fon rasmlarini qorong'i mavzuda xiralashtirish uchun (yorug'da null)
  final ColorFilter? backgroundImageFilter;

  static const light = AppPalette(
    background: AppColors.white,
    backgroundTinted: AppColors.main_blue_50,
    surface: AppColors.white,
    surfaceVariant: AppColors.grey_50,
    border: AppColors.light_grey_500,
    shadow: AppColors.light_grey_500,
    textPrimary: AppColors.main_blue_900,
    textStrong: AppColors.grey_900,
    textSecondary: AppColors.grey_700,
    textMuted: AppColors.grey_500,
    icon: AppColors.grey_800,
    primary: AppColors.main_blue_600,
    primarySoft: AppColors.main_blue_50,
    danger: AppColors.red_400,
    dangerSoft: AppColors.red_50,
    dangerBorder: AppColors.red_200,
    success: AppColors.green_700,
    navBar: AppColors.white,
    switchOff: AppColors.grey_200,
    backgroundImageFilter: null,
  );

  static const dark = AppPalette(
    background: AppColors.light_blue_900,
    backgroundTinted: AppColors.light_blue_900,
    surface: AppColors.grey_900,
    surfaceVariant: AppColors.grey_800,
    border: AppColors.grey_800,
    shadow: Color(0x40000000),
    textPrimary: AppColors.light_blue_500,
    textStrong: AppColors.light_grey_300,
    textSecondary: AppColors.grey_300,
    textMuted: AppColors.grey_400,
    icon: AppColors.light_grey_400,
    primary: AppColors.main_blue_500,
    primarySoft: AppColors.main_blue_900,
    danger: AppColors.red_300,
    dangerSoft: AppColors.red_900,
    dangerBorder: AppColors.red_800,
    success: AppColors.green_700,
    navBar: AppColors.grey_900,
    switchOff: AppColors.grey_700,
    backgroundImageFilter: ColorFilter.mode(
      Color(0xD9253035), // light_blue_900, 85%
      BlendMode.srcATop,
    ),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: c(background, other.background),
      backgroundTinted: c(backgroundTinted, other.backgroundTinted),
      surface: c(surface, other.surface),
      surfaceVariant: c(surfaceVariant, other.surfaceVariant),
      border: c(border, other.border),
      shadow: c(shadow, other.shadow),
      textPrimary: c(textPrimary, other.textPrimary),
      textStrong: c(textStrong, other.textStrong),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      icon: c(icon, other.icon),
      primary: c(primary, other.primary),
      primarySoft: c(primarySoft, other.primarySoft),
      danger: c(danger, other.danger),
      dangerSoft: c(dangerSoft, other.dangerSoft),
      dangerBorder: c(dangerBorder, other.dangerBorder),
      success: c(success, other.success),
      navBar: c(navBar, other.navBar),
      switchOff: c(switchOff, other.switchOff),
      backgroundImageFilter:
          t < 0.5 ? backgroundImageFilter : other.backgroundImageFilter,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Fon rasmi: qorong'i mavzuda avtomatik xiralashtiriladi.
  DecorationImage themedBackground(String asset, {BoxFit fit = BoxFit.fill}) {
    return DecorationImage(
      image: AssetImage(asset),
      fit: fit,
      colorFilter: palette.backgroundImageFilter,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light, AppPalette.light);

  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.orange_400,
      onSecondary: AppColors.white,
      error: p.danger,
      onError: AppColors.white,
      surface: p.surface,
      onSurface: p.textStrong,
      surfaceContainerHighest: p.surfaceVariant,
      onSurfaceVariant: p.textSecondary,
      outline: p.border,
      outlineVariant: p.border,
      shadow: p.shadow,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: "Nunito",
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.border,
      textSelectionTheme: const TextSelectionThemeData(
        selectionHandleColor: Colors.transparent, // tomchi rangi
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.textPrimary,
        iconTheme: IconThemeData(color: p.icon),
        elevation: 0,
      ),
      iconTheme: IconThemeData(color: p.icon),
      cardTheme: CardThemeData(color: p.surface, surfaceTintColor: Colors.transparent),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: "Nunito",
          color: p.textStrong,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(fontFamily: "Nunito", color: p.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(color: p.surface),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: p.surfaceVariant,
        hintStyle: TextStyle(color: p.textMuted),
        labelStyle: TextStyle(color: p.textSecondary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      extensions: [p],
    );
  }
}
