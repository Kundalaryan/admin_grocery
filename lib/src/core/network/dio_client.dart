// lib/src/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Needed for MaterialPageRoute

// --- IMPORTS FOR LOGIC ---
import '../../../../main.dart'; // To access navigatorKey
import '../utils/token_storage.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://api.expertsec.in/api/",
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
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print("🚀 [${options.method}] ${options.path}");
          }
          return handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            print("✅ [${response.statusCode}] ${response.requestOptions.path}");
          }
          return handler.next(response);
        },

        // --- UPDATED ERROR HANDLING ---
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print("❌ [${e.response?.statusCode}] ${e.message}");
          }

          // 1. Check for Unauthorized (401) or Forbidden (403)
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            if (kDebugMode) {
              print("🚨 Session Expired. Logging out...");
            }

            // 2. Clear Token
            await TokenStorage.clearToken();

            // 3. Force Navigate to Login using Global Key
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false, // Remove all back history
              );
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}