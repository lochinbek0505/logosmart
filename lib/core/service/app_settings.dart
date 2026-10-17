import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Ilova sozlamalari (Sozlamalar sahifasi). Qiymatlar storage'da saqlanadi.
class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _pushEnabledKey = 'settings_push_enabled';
  static const _notificationSoundKey = 'settings_notification_sound';
  static const _gameMusicKey = 'settings_game_music';
  static const _vibrationKey = 'settings_vibration';
  static const _themeModeKey = 'settings_theme_mode';

  bool _pushEnabled = true;
  bool _notificationSound = true;
  bool _gameMusic = true;
  bool _vibration = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get pushEnabled => _pushEnabled;
  bool get notificationSound => _notificationSound;
  bool get gameMusic => _gameMusic;
  bool get vibration => _vibration;

  /// Ilova mavzusi: tizimga mos, yorug' yoki qorong'i.
  ThemeMode get themeMode => _themeMode;

  /// Ilova ishga tushganda bir marta chaqiriladi.
  Future<void> load() async {
    try {
      _pushEnabled = await _read(_pushEnabledKey);
      _notificationSound = await _read(_notificationSoundKey);
      _gameMusic = await _read(_gameMusicKey);
      _vibration = await _read(_vibrationKey);
      final mode = await _storage.read(key: _themeModeKey);
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == mode,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Sozlamalarni o'qishda xato: $e");
    }
  }

  /// Backend bilan bog'lash NotificationService.setPushEnabled() da.
  Future<void> setPushEnabled(bool value) async {
    _pushEnabled = value;
    notifyListeners();
    await _write(_pushEnabledKey, value);
  }

  Future<void> setNotificationSound(bool value) async {
    _notificationSound = value;
    notifyListeners();
    await _write(_notificationSoundKey, value);
  }

  Future<void> setGameMusic(bool value) async {
    _gameMusic = value;
    notifyListeners();
    await _write(_gameMusicKey, value);
  }

  Future<void> setVibration(bool value) async {
    _vibration = value;
    notifyListeners();
    await _write(_vibrationKey, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      await _storage.write(key: _themeModeKey, value: mode.name);
    } catch (e) {
      debugPrint("Mavzuni saqlashda xato: $e");
    }
  }

  /// To'g'ri javobda qisqa vibratsiya.
  void vibrateSuccess() {
    if (_vibration) HapticFeedback.mediumImpact();
  }

  /// Xato javobda kuchliroq vibratsiya.
  void vibrateError() {
    if (_vibration) HapticFeedback.heavyImpact();
  }

  Future<bool> _read(String key) async {
    final value = await _storage.read(key: key);
    return value == null ? true : value == 'true';
  }

  Future<void> _write(String key, bool value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      debugPrint("Sozlamani saqlashda xato: $e");
    }
  }
}
