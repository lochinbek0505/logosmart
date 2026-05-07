import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logosmart/core/storage/token_storage.dart';
import 'package:logosmart/models/login_model.dart';
import 'package:logosmart/models/pay_link_response.dart';
import 'package:logosmart/models/plan_activate_response.dart';
import 'package:logosmart/models/plans_model.dart';
import 'package:logosmart/models/profile_response.dart';

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
          if (e.response?.statusCode == 401) {
            // WebStorageService().clearAll();
            // Bu yerda navigator orqali login sahifasiga yo'naltirish kodi bo'ladi
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> login_init(context, Map<String, dynamic> data) async {
    try {
      var response = await _dio.post("auth/login/init", data: data);

      showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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
        showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");
        return LoginModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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

      showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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
        showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");
        return LoginModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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

      showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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

      showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");
      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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
      showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");

      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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
      // showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");

      if (response.statusCode == 200) {
        return PayLinkResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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
      // showSnakBar(context, response.data["message"] ?? "Muvaffaqiyatli!");

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data["message"] ??
            e.response?.statusMessage ??
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // subscriptions/plans


  Future<PlansModel?> getPlans(context) async {
    try {
      
      var response = await _dio.get("subscriptions/plans");
      print("RESPONSE: ${response.data}");
      if (response.statusCode == 200) {
        return PlansModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      print("RESPONSE: ${e}");

      String errorMessage = "Xatolik yuz berdi";

      if (e.response != null && e.response?.data != null) {
        // 1-O'ZGARISH: data qanday formatda ekanini tekshiramiz
        if (e.response?.data is Map<String, dynamic>) {
          // Agar to'g'ri JSON kelsa, "message" ni olamiz
          errorMessage = e.response?.data["message"] ??
              e.response?.statusMessage ??
              "Noma'lum xato";
        } else {
          // Agar oddiy matn (String) yoki HTML kelsa, shunchaki stringga o'giramiz
          errorMessage = e.response?.statusMessage ?? "Noma'lum xato";
          // Yoki kerak bo'lsa to'g'ridan-to'g'ri e.response?.data.toString() dan foydalanishingiz mumkin
        }
      } else {
        errorMessage = "Server bilan aloqa yo'q: ${e.message}";
      }

      showSnakBar(context, errorMessage);
      return null;
    } catch (e) {
      print("RESPONSE: ${e}");

      showSnakBar(context, "Kutilmagan xato: $e");
      return null;
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
            e.response?.data["message"] ??
                e.response?.statusMessage ??
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

}
