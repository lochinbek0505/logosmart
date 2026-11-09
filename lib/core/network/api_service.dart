import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logosmart/core/storage/token_storage.dart';
import 'package:logosmart/models/avatars_model.dart';
import 'package:logosmart/models/billings_model.dart';
import 'package:logosmart/models/diagnostic_group_model.dart';
import 'package:logosmart/models/diagnostic_submit_model.dart';
import 'package:logosmart/models/login_model.dart';
import 'package:logosmart/models/notification_model.dart';
import 'package:logosmart/models/pay_link_response.dart';
import 'package:logosmart/models/plan_activate_response.dart';
import 'package:logosmart/models/plan_checkout_response.dart';
import 'package:logosmart/models/plans_model.dart';
import 'package:logosmart/models/profile_response.dart';
import 'package:logosmart/models/promo_check_model.dart';

class ApiService {
  late Dio _dio;

  final String baseUrl =
      "https://api.smartlogo.uz/api/v1/"; // O'zingizni URLingizni qo'ying

  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;
  TokenStorage _cacheService = TokenStorage();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Storage'dan tokenni olish
          final token = await _cacheService.getAccessToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer ${token}';
          }

          return handler.next(options); // So'rovni davom ettirish
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (_isSessionExpired(e)) _handleSessionExpired();
          return handler.next(e);
        },
      ),
    );
  }

  /// Sessiya tugaganda chaqiriladi (main.dart da o'rnatiladi):
  /// tokenni tozalab login sahifasiga qaytaradi.
  static Future<void> Function()? onSessionExpired;
  bool _expiring = false;

  /// Javob body sidagi "message" — body JSON bo'lmasa (masalan 502 da nginx
  /// HTML qaytaradi) null.
  static String? messageOf(dynamic data) {
    if (data is Map) {
      final m = data["message"];
      if (m != null && m.toString().isNotEmpty) return m.toString();
    }
    return null;
  }

  /// 5xx (server/nginx xatosi) uchun tushunarli matn, aks holda statusMessage
  static String? statusText(Response? response) {
    final status = response?.statusCode ?? 0;
    if (status >= 500) {
      return "Server vaqtincha ishlamayapti. Birozdan keyin urinib ko'ring.";
    }
    return response?.statusMessage;
  }

  /// Token muddati tugagan/yaroqsiz: 401, yoki body siz 403 (Spring Security).
  /// "message" li 403 — biznes taqiq (masalan "Bu level faqat obunachilar
  /// uchun."), u logout qilmaydi.
  bool _isSessionExpired(DioException e) {
    final status = e.response?.statusCode;
    if (status != 401 && status != 403) return false;
    if (e.requestOptions.path.startsWith("auth/")) return false;
    if (e.requestOptions.headers['Authorization'] == null) return false;
    return status == 401 || messageOf(e.response?.data) == null;
  }

  Future<void> _handleSessionExpired() async {
    final handler = onSessionExpired;
    if (_expiring || handler == null) return;
    _expiring = true;
    try {
      await handler();
    } finally {
      _expiring = false;
    }
  }

  Future<bool> login_init(context, Map<String, dynamic> data) async {
    try {
      var response = await _dio.post("auth/login/init", data: data);

      showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return false;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return false;
    }
  }

  Future<bool> logout(context) async {
    try {
      var response = await _dio.post("auth/logout");

      showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return false;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return false;
    }
  }

  Future<bool> deleteAccount(context) async {
    try {
      var response = await _dio.delete("profile/me/delete");

      showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return false;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return false;
    }
  }

  Future<LoginModel?> login_verify(context, Map<String, dynamic> data) async {
    try {
      var response = await _dio.post("auth/login/verify", data: data);

      // Status 200 yoki 201 bo'lishi mumkin, API hujjatiga qarab to'g'rilaysiz
      if (response.statusCode == 200) {
        showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");
        return LoginModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  Future<bool> register_init(context, Map<String, dynamic> data) async {
    try {
      var response = await _dio.post("auth/register/init", data: data);

      showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return false;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return false;
    }
  }

  Future<LoginModel?> register_verify(
    context,
    Map<String, dynamic> data,
  ) async {
    try {
      var response = await _dio.post("auth/register/verify", data: data);

      // Status 200 yoki 201 bo'lishi mumkin, API hujjatiga qarab to'g'rilaysiz
      if (response.statusCode == 200) {
        showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");
        return LoginModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  Future<bool> forgot_init(context, Map<String, dynamic> data) async {
    try {
      var response = await _dio.post("auth/forgot-password/init", data: data);

      showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return false;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return false;
    }
  }

  Future<bool> forgot_verify_otp(context, Map<String, dynamic> data) async {
    try {
      var response = await _dio.post(
        "auth/forgot-password/verify-otp",
        data: data,
      );

      showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return false;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return false;
    }
  }

  Future<bool> reset_password(context, Map<String, dynamic> data) async {
    try {
      var response = await _dio.post("auth/forgot-password/reset", data: data);
      showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");

      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return false;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return false;
    }
  }

  Future<PayLinkResponse?> getPayLink(
    context,
    Map<String, dynamic> data,
  ) async {
    try {
      var response = await _dio.post("payment/click/pay-link", data: data);
      // showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");

      if (response.statusCode == 200) {
        return PayLinkResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  Future<ProfileResponse?> getProfile(context) async {
    try {
      var response = await _dio.get("profile/me");
      // showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  void showSnakBar(context, message) {
    // Backend bo'sh "message" qaytarsa matnsiz qora chiziq chiqib qolmasin
    final text = message?.toString().trim() ?? "";
    if (text.isEmpty || context == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // subscriptions/plans

  Future<PlansModel?> getPlans(context) async {
    try {
      var response = await _dio.get("subscriptions/plans");
      debugPrint("RESPONSE: ${response.data}");
      if (response.statusCode == 200) {
        return PlansModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      debugPrint("RESPONSE: ${e}");

      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        // 1-O'ZGARISH: data qanday formatda ekanini tekshiramiz
        if (e.response?.data is Map<String, dynamic>) {
          // Agar to'g'ri JSON kelsa, "message" ni olamiz
          errorMessage =
              messageOf(e.response?.data) ??
              statusText(e.response) ??
              "Noma'lum xato";
        } else {
          // Agar oddiy matn (String) yoki HTML kelsa, shunchaki stringga o'giramiz
          errorMessage = statusText(e.response) ?? "Noma'lum xato";
          // Yoki kerak bo'lsa to'g'ridan-to'g'ri e.response?.data.toString() dan foydalanishingiz mumkin
        }
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      debugPrint("RESPONSE: ${e}");

      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  Future<AvatarsModel?> getAvatars(context) async {
    try {
      var response = await _dio.get("avatars");
      debugPrint("RESPONSE: ${response.data}");
      if (response.statusCode == 200) {
        return AvatarsModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      debugPrint("RESPONSE: ${e}");

      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        // 1-O'ZGARISH: data qanday formatda ekanini tekshiramiz
        if (e.response?.data is Map<String, dynamic>) {
          // Agar to'g'ri JSON kelsa, "message" ni olamiz
          errorMessage =
              messageOf(e.response?.data) ??
              statusText(e.response) ??
              "Noma'lum xato";
        } else {
          // Agar oddiy matn (String) yoki HTML kelsa, shunchaki stringga o'giramiz
          errorMessage = statusText(e.response) ?? "Noma'lum xato";
          // Yoki kerak bo'lsa to'g'ridan-to'g'ri e.response?.data.toString() dan foydalanishingiz mumkin
        }
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      debugPrint("RESPONSE: ${e}");

      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  /// Obunani sotib olish: balans yetsa darhol faollashadi, yetmasa yetmagan
  /// summa uchun Click havolasi qaytadi.
  Future<PlanCheckoutResponse?> checkoutPlan(
    context,
    Map<String, dynamic> data,
  ) async {
    try {
      var response = await _dio.post("subscriptions/checkout", data: data);
      if (response.statusCode == 200) {
        return PlanCheckoutResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  /// Click'dan qaytganda kutilayotgan obunani faollashtirishga urinadi.
  /// true — obuna faollashdi (200), false — hali pul tushmagan (204) yoki xato.
  Future<bool> settlePendingPlan() async {
    try {
      var response = await _dio.post("subscriptions/checkout/settle");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Kutilayotgan obunani tekshirishda xato: $e");
      return false;
    }
  }

  Future<PlanActivateResponse?> activatePlan(
    context,
    Map<String, dynamic> data,
  ) async {
    try {
      var response = await _dio.post("subscriptions/activate", data: data);

      if (response.statusCode == 200) {
        return PlanActivateResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  Future<PromoCheckModel?> checkPromo(context, code) async {
    try {
      var response = await _dio.get("promocodes/check/${code}");
      // showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");

      if (response.statusCode == 200) {
        return PromoCheckModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  // /api/v1/profile/me

  Future<ProfileResponse?> updateProfile(
    context,
    Map<String, dynamic> data,
  ) async {
    try {
      var response = await _dio.put("profile/me", data: data);
      // showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  Future<BillingsModel?> getBillings(context) async {
    try {
      var response = await _dio.get("payment/click/my-transactions");
      // showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");

      if (response.statusCode == 200) {
        return BillingsModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  Future<DiagnosticGroupModel?> getDiagnosticGroup(context) async {
    try {
      var response = await _dio.get("diagnostic-groups");
      // showSnakBar(context, messageOf(response.data) ?? "Muvaffaqiyatli!");

      if (response.statusCode == 200) {
        return DiagnosticGroupModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  Future<DiagnosticSubmitModel?> submitDiagnostic(
    context,
    Map<String, dynamic> data,
  ) async {
    try {
      var response = await _dio.post("diagnostic/submit", data: data);

      if (response.statusCode == 200) {
        return DiagnosticSubmitModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            messageOf(e.response?.data) ??
            statusText(e.response) ??
            "Noma'lum xato";
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }
      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
    }
  }

  // ---------------- Bildirishnomalar (NOTIFICATIONS.md) ----------------
  // Bular fonda chaqiriladi, shuning uchun snackbar ko'rsatmaydi.

  /// Qurilma FCM tokenini joriy userga bog'lash. platform: ANDROID | IOS
  Future<bool> registerDeviceToken(String fcmToken, String platform) async {
    try {
      var response = await _dio.post(
        "notifications/device-token",
        data: {"fcmToken": fcmToken, "platform": platform},
      );
      debugPrint(
        "Device token yuborildi: ${response.statusCode} ${response.data}",
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Device token yuborishda xato: $e");
      return false;
    }
  }

  /// Push'ni o'chirish (Sozlamalar → Bildirishnomalar: o'chiq).
  Future<bool> deleteDeviceToken(String fcmToken) async {
    try {
      var response = await _dio.delete(
        "notifications/device-token",
        queryParameters: {"fcmToken": fcmToken},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Device token o'chirishda xato: $e");
      return false;
    }
  }

  Future<NotificationsPageModel?> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      var response = await _dio.get(
        "notifications",
        queryParameters: {"page": page, "size": size},
      );
      if (response.statusCode == 200) {
        return NotificationsPageModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Bildirishnomalarni olishda xato: $e");
    }
    return null;
  }

  Future<int?> getUnreadNotificationsCount() async {
    try {
      var response = await _dio.get("notifications/unread-count");
      if (response.statusCode == 200 && response.data is Map) {
        // Backend son o'rniga satr/null qaytarsa ham yiqilmasin
        return (response.data["count"] as num?)?.toInt();
      }
    } catch (e) {
      debugPrint("O'qilmaganlar sonini olishda xato: $e");
    }
    return null;
  }

  Future<bool> markNotificationRead(String id) async {
    try {
      var response = await _dio.patch("notifications/$id/read");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Bildirishnomani o'qildi qilishda xato: $e");
      return false;
    }
  }

  Future<bool> markAllNotificationsRead() async {
    try {
      var response = await _dio.patch("notifications/read-all");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Hammasini o'qildi qilishda xato: $e");
      return false;
    }
  }

  // --- OVOZ (TOVUSH) MASHQLARI ---

  /// Tovush mashqlari ro'yxati (id, name, sequenceNumber, count, ...)
  Future<List<Map<String, dynamic>>?> getVoicePractices() async {
    try {
      var response = await _dio.get("voice-practices");
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      debugPrint("Tovush mashqlarini olishda xato: $e");
    }
    return null;
  }

  /// Mashq levellari foydalanuvchi progressi (stars, locked) bilan.
  /// Obunasiz foydalanuvchiga faqat bepul levellar qaytadi.
  Future<List<dynamic>?> getVoicePracticeLevels(String voicePracticeId) async {
    try {
      var response = await _dio.get(
        "levels",
        queryParameters: {"voicePracticeId": voicePracticeId},
      );
      if (response.statusCode == 200 && response.data is List) {
        return response.data as List;
      }
    } catch (e) {
      debugPrint("Levellarni olishda xato: $e");
    }
    return null;
  }

  /// Level natijasini (yulduzlarni) serverga yuborish. [levelId] — mongo id.
  /// true — qabul qilindi, false — server rad etdi (qayta yuborish foydasiz,
  /// masalan pullik level — 403), null — tarmoq/server xatosi (keyin qayta).
  Future<bool?> submitLevelStars(String levelId, int stars) async {
    try {
      var response = await _dio.post(
        "levels/$levelId/stars",
        data: {"stars": stars.clamp(0, 3)},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("Yulduzlarni yuborishda xato: $e");
      final status = e.response?.statusCode;
      if (status != null && status >= 400 && status < 500 && status != 401) {
        // Body siz 403 — sessiya tugagan, natija keyingi login uchun qoladi
        if (status == 403 && messageOf(e.response?.data) == null) return null;
        return false;
      }
      return null;
    } catch (e) {
      debugPrint("Yulduzlarni yuborishda xato: $e");
      return null;
    }
  }

  /// O'yinlar ("games") yoki Ilk nutq ("first-speech") bo'limi: bitta xarita
  /// levellari foydalanuvchi progressi bilan ({id, name, levels: [...], ...}).
  /// Tarmoq/server xatosi yoki bo'lim hali qo'shilmagan (404) bo'lsa null.
  Future<Map<String, dynamic>?> getSection(String path) async {
    try {
      var response = await _dio.get(path);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint("Bo'limni ($path) olishda xato: $e");
    }
    return null;
  }

  /// Serverdagi umumiy ball. Xato bo'lsa null.
  Future<int?> getBall() async {
    try {
      var response = await _dio.get("ball");
      if (response.statusCode == 200 && response.data is Map) {
        return (response.data["ball"] as num?)?.toInt();
      }
    } catch (e) {
      debugPrint("Ballni olishda xato: $e");
    }
    return null;
  }

  /// Ball o'zgarishlarini ({id, delta}) yuboradi. Server id bo'yicha
  /// takrorlarni e'tiborsiz qoldiradi, shuning uchun qayta yuborish xavfsiz.
  Future<BallPostResult?> postBallEvents(
    List<Map<String, dynamic>> events,
  ) async {
    try {
      var response = await _dio.post("ball/events", data: {"events": events});
      if (response.statusCode == 200 && response.data is Map) {
        return BallPostResult((response.data["ball"] as num?)?.toInt());
      }
      return null;
    } on DioException catch (e) {
      debugPrint("Ballni yuborishda xato: $e");
      final status = e.response?.statusCode;
      // 400 — hodisalar yaroqsiz, qayta yuborish foydasiz
      if (status == 400) return const BallPostResult(null, rejected: true);
      return null;
    } catch (e) {
      debugPrint("Ballni yuborishda xato: $e");
      return null;
    }
  }

  /// Server bilan aloqa bormi: har qanday HTTP javob (hatto 401/404) — bor,
  /// ulanish xatosi yoki timeout — yo'q.
  Future<bool> ping() async {
    try {
      final uri = Uri.parse(_dio.options.baseUrl);
      await _dio
          .get(
            "${uri.origin}/actuator/health",
            options: Options(
              validateStatus: (_) => true,
              sendTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          )
          .timeout(const Duration(seconds: 6));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Yulduzlar tarixi (eng yangisi birinchi) — oxirgi o'ynalgan mashqni topish uchun
  Future<List<dynamic>?> getStarHistory() async {
    try {
      var response = await _dio.get("stars/history");
      if (response.statusCode == 200 && response.data is List) {
        return response.data as List;
      }
    } catch (e) {
      debugPrint("Yulduzlar tarixini olishda xato: $e");
    }
    return null;
  }

  // --- ILOVA RESURSLARI (rasm, ovoz, video, model) ---

  /// Resurslar manifesti. [version] serverdagi bilan teng bo'lsa server 304 qaytaradi —
  /// unda `{"notModified": true}` qaytariladi. Xato bo'lsa null.
  /// Faqat testlar uchun: so'rovlarni lokal test serverga yo'naltirish
  @visibleForTesting
  set baseUrlForTesting(String url) => _dio.options.baseUrl = url;

  /// Oxirgi muvaffaqiyatsiz manifest so'rovining status kodi (null — tarmoq xatosi)
  int? lastResourceManifestStatus;

  Future<Map<String, dynamic>?> getResourceManifest({int? version}) async {
    lastResourceManifestStatus = null;
    try {
      var response = await _dio.get(
        "resources/manifest",
        queryParameters: {
          if (version != null && version >= 0) "version": version,
        },
        options: Options(validateStatus: (s) => s == 200 || s == 304),
      );
      if (response.statusCode == 304) return {"notModified": true};
      if (response.data is Map) return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      lastResourceManifestStatus = e.response?.statusCode;
      debugPrint("Resurslar manifestini olishda xato: $e");
    } catch (e) {
      debugPrint("Resurslar manifestini olishda xato: $e");
    }
    return null;
  }

  /// Resurs faylini oqim (stream) sifatida ochadi. [from] > 0 bo'lsa `Range: bytes=from-`
  /// yuboriladi — uzilgan yuklash shu joyidan davom etadi (server 206 qaytaradi).
  /// Xato bo'lsa DioException tashlaydi (status kodi bilan).
  Future<Response<ResponseBody>> openResourceStream(
    String path, {
    int from = 0,
    CancelToken? cancelToken,
  }) {
    return _dio.get<ResponseBody>(
      "resources/file",
      queryParameters: {"path": path},
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: {if (from > 0) "Range": "bytes=$from-"},
        // 416 — so'ralgan joy fayl oxiridan keyin (qism eskirgan), qaytadan yuklanadi
        validateStatus: (s) => s == 200 || s == 206 || s == 416,
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }
}

/// POST /ball/events natijasi: [ball] — serverdagi yangi qiymat;
/// [rejected] — server hodisalarni yaroqsiz deb rad etdi (navbatdan olinadi).
class BallPostResult {
  const BallPostResult(this.ball, {this.rejected = false});

  final int? ball;
  final bool rejected;
}
