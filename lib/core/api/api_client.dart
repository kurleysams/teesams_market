// lib/core/api/api_client.dart
import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required String tenantSlug, String? authToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          headers: {
            'X-Tenant': tenantSlug,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
        ),
      );
}
