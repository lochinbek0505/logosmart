import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/login_model.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Kalitlar
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  /// LoginModel'ni to'liq saqlash (Tokenlar va User ma'lumotlari)
  Future<void> saveLoginData(LoginModel model) async {
    try {
      if (model.accessToken != null) {
        await _storage.write(key: _accessTokenKey, value: model.accessToken);
      }
      if (model.refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: model.refreshToken);
      }
      if (model.user != null) {
        // User obyektini JSON String ko'rinishida saqlaymiz
        String userJson = jsonEncode(model.user!.toJson());
        await _storage.write(key: _userKey, value: userJson);
      }
    } catch (e) {
      print("Ma'lumot saqlashda xatolik: $e");
    }
  }

  /// Umumiy LoginModel ko'rinishida barcha ma'lumotlarni qaytarish
  Future<LoginModel?> getFullLoginData() async {
    try {
      final access = await getAccessToken();
      final refresh = await getRefreshToken();
      final userString = await _storage.read(key: _userKey);

      User? user;
      if (userString != null) {
        user = User.fromJson(jsonDecode(userString));
      }

      if (access == null && refresh == null && user == null) return null;

      return LoginModel(
        accessToken: access,
        refreshToken: refresh,
        user: user,
      );
    } catch (e) {
      print("Ma'lumotni o'qishda xatolik: $e");
      return null;
    }
  }

  /// Faqat Access Tokenni olish
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Faqat Refresh Tokenni olish
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Ma'lumotlarni o'chirish (Logout uchun)
  Future<void> deleteAuthData() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Hamma narsani tozalash
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}