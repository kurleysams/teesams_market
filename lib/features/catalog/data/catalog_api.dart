import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../models/category.dart' as catalog_model;

class CatalogApi {
  CatalogApi({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<catalog_model.Category>> fetchCategories({
    required String tenantSlug,
  }) async {
    final url = '${AppConfig.baseUrl}/v1/catalog';

    debugPrint('--- fetchCatalog/categories ---');
    debugPrint('REQUEST URL: $url');
    debugPrint('TENANT HEADER: $tenantSlug');

    final response = await _dio.get(
      url,
      options: Options(headers: {'X-Tenant': tenantSlug}),
    );

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RAW RESPONSE: ${response.data}');

    final data = response.data;

    List rawCategories = const [];

    if (data is Map<String, dynamic>) {
      if (data['categories'] is List) {
        rawCategories = data['categories'] as List;
      } else if (data['snapshot'] is Map<String, dynamic>) {
        final snapshot = data['snapshot'] as Map<String, dynamic>;

        if (snapshot['catalog'] is Map<String, dynamic>) {
          final catalog = snapshot['catalog'] as Map<String, dynamic>;
          rawCategories = catalog['categories'] as List? ?? const [];
        }
      } else if (data['data'] is Map<String, dynamic>) {
        final nested = data['data'] as Map<String, dynamic>;
        rawCategories = nested['categories'] as List? ?? const [];
      } else if (data['data'] is List) {
        rawCategories = data['data'] as List;
      }
    } else if (data is List) {
      rawCategories = data;
    }

    debugPrint('PARSED CATEGORIES: ${rawCategories.length}');

    return rawCategories
        .map(
          (e) => catalog_model.Category.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}
