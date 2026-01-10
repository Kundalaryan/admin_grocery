import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart'; // Import your storage

class DioClient {
  // 1. Singleton Pattern (Only one instance of Dio exists globally)
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://api.expertsec.in/api/", // Adjust if needed
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 2. Add The "Magic" Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // A. Get Token from Storage
          final token = await TokenStorage.getToken();

          // B. If token exists, add it to Header
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print("🚀 [${options.method}] ${options.path}");
            print("   Token: ${token != null ? 'Attached ✅' : 'Missing ❌'}");
          }
          return handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            print("✅ [${response.statusCode}] ${response.requestOptions.path}");
          }
          return handler.next(response);
        },

        onError: (DioException e, handler) {
          if (kDebugMode) {
            print("❌ [${e.response?.statusCode}] ${e.message}");
          }
          // Optional: If 403/401, maybe logout user automatically?
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}