import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  static Future<ApiClient> create({
    String? tenantSlug,
    String? authToken,
  }) async {
    final headers = <String, dynamic>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (tenantSlug != null && tenantSlug.trim().isNotEmpty)
        'X-Tenant': tenantSlug,
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };

    final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl, headers: headers));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final authHeader = options.headers['Authorization'];
          final hasAuth =
              authHeader != null && authHeader.toString().trim().isNotEmpty;

          final tenantHeader = options.headers['X-Tenant'];
          final hasTenant =
              tenantHeader != null && tenantHeader.toString().trim().isNotEmpty;

          debugPrint('API REQUEST -> ${options.method} ${options.uri}');
          debugPrint('API TENANT HEADER PRESENT -> $hasTenant');
          debugPrint('API AUTH HEADER PRESENT -> $hasAuth');

          handler.next(options);
        },
      ),
    );

    return ApiClient._(dio);
  }

  Future<void> setAuthToken(String? token) async {
    if (token == null || token.trim().isEmpty) {
      dio.options.headers.remove('Authorization');
      return;
    }

    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> setTenantSlug(String? tenantSlug) async {
    if (tenantSlug == null || tenantSlug.trim().isEmpty) {
      dio.options.headers.remove('X-Tenant');
      return;
    }

    dio.options.headers['X-Tenant'] = tenantSlug;
  }

  Future<void> clearTenantSlug() async {
    dio.options.headers.remove('X-Tenant');
  }

  Future<void> clearAuthToken() async {
    dio.options.headers.remove('Authorization');
  }
}
