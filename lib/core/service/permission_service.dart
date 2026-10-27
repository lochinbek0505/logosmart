import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';

/// Ilova uchun kerakli ruxsatlarni birinchi ochilishda bir marta so'raydi.
/// Keyinchalik har bir funksiya (o'yinlar, diagnostika) kerak bo'lsa
/// ruxsatni o'zi qayta tekshiradi.
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _requestedKey = 'permissions_requested_v1';

  // Bildirishnoma ruxsatini NotificationService o'zi so'raydi
  static const _permissions = [Permission.camera, Permission.microphone];

  Future<void> requestOnFirstLaunch() async {
    try {
      if (await _storage.read(key: _requestedKey) == 'true') return;
      // Dialoglar bir-biriga to'qnashmasligi uchun ketma-ket so'raymiz
      for (final permission in _permissions) {
        final status = await permission.request();
        debugPrint("$permission ruxsati: $status");
      }
      await _storage.write(key: _requestedKey, value: 'true');
    } catch (e) {
      debugPrint("Ruxsatlarni so'rashda xato: $e");
    }
  }
}
