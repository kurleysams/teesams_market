import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  static Future<ApiClient> create({
    required String tenantSlug,
    String? authToken,
  }) async {
    final storedToken = await AuthStorage().getToken();
    final token = authToken ?? storedToken;

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        headers: {
          'X-Tenant': tenantSlug,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final authHeader = options.headers['Authorization'];
          final hasAuth =
              authHeader != null && authHeader.toString().trim().isNotEmpty;

          debugPrint('API REQUEST -> ${options.method} ${options.uri}');
          debugPrint('API TENANT -> ${options.headers['X-Tenant']}');
          debugPrint('API AUTH HEADER PRESENT -> $hasAuth');

          handler.next(options);
        },
      ),
    );

    return ApiClient._(dio);
  }
}
