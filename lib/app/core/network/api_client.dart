import 'dart:convert';
import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_exception.dart';
import 'package:budgetbook_2026/app/core/storage/token_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppUrl.baseUrl,
        connectTimeout: Duration(seconds: AppUrl.timeout),
        receiveTimeout: Duration(seconds: AppUrl.timeout),
        headers: {"Accept": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          ////////////////////////////////////////////////////////////
          /// 🔐 ATTACH TOKEN FROM TOKEN MANAGER
          ////////////////////////////////////////////////////////////

          final token = TokenManager().token;

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          ////////////////////////////////////////////////////////////
          /// 🔎 TOKEN DEBUG SECTION (PRODUCTION-LEVEL DEBUG)
          ////////////////////////////////////////////////////////////

          if (kDebugMode) {
            debugPrint("🔐 TOKEN DEBUG START");

            if (token == null) {
              debugPrint("❌ No token found in TokenManager");
            } else {
              debugPrint("✅ Token exists");
              debugPrint(
                "🔑 Token (first 40 chars): ${token.substring(0, 40)}...",
              );

              try {
                final parts = token.split(".");

                if (parts.length == 3) {
                  final payload = parts[1];

                  // Decode Base64 payload
                  final normalized = base64Url.normalize(payload);
                  final decoded = utf8.decode(base64Url.decode(normalized));

                  debugPrint("📦 JWT Payload: $decoded");

                  final payloadMap = jsonDecode(decoded);

                  if (payloadMap.containsKey("exp")) {
                    final exp = payloadMap["exp"];
                    final expiry = DateTime.fromMillisecondsSinceEpoch(
                      exp * 1000,
                    );

                    debugPrint("⏰ Token expires at: $expiry");

                    if (DateTime.now().isAfter(expiry)) {
                      debugPrint("❌ TOKEN IS EXPIRED");
                    } else {
                      final remaining = expiry.difference(DateTime.now());

                      debugPrint(
                        "✅ Token valid for: ${remaining.inMinutes} minutes",
                      );
                    }
                  }
                } else {
                  debugPrint("⚠️ Invalid JWT format");
                }
              } catch (e) {
                debugPrint("❌ Token decode error: $e");
              }
            }

            debugPrint("🔐 TOKEN DEBUG END");
          }

          ////////////////////////////////////////////////////////////
          /// DEBUG LOGS
          ////////////////////////////////////////////////////////////

          if (kDebugMode) {
            debugPrint("🚀 API REQUEST");
            debugPrint("➡️ URL: ${options.baseUrl}${options.path}");
            debugPrint("➡️ METHOD: ${options.method}");
            debugPrint("➡️ HEADERS: ${options.headers}");
            debugPrint("➡️ BODY: ${options.data}");
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint("✅ API RESPONSE");
            debugPrint("⬅️ STATUS CODE: ${response.statusCode}");
            debugPrint("⬅️ DATA: ${response.data}");
          }
          handler.next(response);
        },

        onError: (error, handler) async {
          String message = "Something went wrong";

          if (error.response != null) {
            final data = error.response?.data;

            ////////////////////////////////////////////////////////////
            /// SAFE MESSAGE PARSING
            ////////////////////////////////////////////////////////////

            if (data is Map<String, dynamic>) {
              message = data['message']?.toString() ?? message;
            } else if (data is String) {
              message = data;
            }

            if (kDebugMode) {
              debugPrint("❌ API ERROR RESPONSE");
              debugPrint("⬅️ STATUS CODE: ${error.response?.statusCode}");
              debugPrint("⬅️ ERROR DATA: $data");
            }

            ////////////////////////////////////////////////////////////
            /// AUTO LOGOUT ON 401
            ////////////////////////////////////////////////////////////

            if (error.response?.statusCode == 401) {
              await TokenManager().clearToken();
            }
          } else if (error.type == DioExceptionType.connectionTimeout) {
            message = "Connection timeout";
          } else if (error.type == DioExceptionType.connectionError) {
            message = "No internet connection";
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response, // ⭐ KEEP ORIGINAL RESPONSE
              type: error.type,
              error: ApiException(message),
            ),
          );
        },
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// POST METHOD
  //////////////////////////////////////////////////////////////

  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw ApiException(e.error.toString());
    }
  }

  //////////////////////////////////////////////////////////////
  /// GET METHOD
  //////////////////////////////////////////////////////////////

  Future<Response> get(String endpoint) async {
    try {
      return await dio.get(endpoint);
    } on DioException catch (e) {
      throw ApiException(e.error.toString());
    }
  }

  // Delete Method
  Future<Response> delete(String endpoint, {dynamic data}) async {
  try {
    return await dio.delete(endpoint, data: data);
  } on DioException catch (e) {
    throw ApiException(e.error.toString());
  }
}
}
