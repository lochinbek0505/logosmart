import 'package:dio/dio.dart';
import 'package:logosmart/core/storage/token_storage.dart';

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
}
