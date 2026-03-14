import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant.dart';

class TenantService {
  const TenantService();

  Future<Tenant> fetchCurrentTenant({
    required String tenantSlug,
    String? authToken,
  }) async {
    final api = ApiClient(tenantSlug: tenantSlug, authToken: authToken);

    final requestUrl = '${api.dio.options.baseUrl}${Endpoints.tenant}';

    debugPrint('--- fetchCurrentTenant ---');
    debugPrint('REQUEST URL: $requestUrl');
    debugPrint('TENANT HEADER: $tenantSlug');
    debugPrint('AUTH TOKEN SET: ${authToken != null && authToken.isNotEmpty}');

    final response = await api.dio.get(Endpoints.tenant);

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RAW RESPONSE: ${response.data}');

    final data = response.data;

    if (data is! Map) {
      throw Exception(
        'Invalid tenant response: expected JSON object, got ${data.runtimeType}',
      );
    }

    if (data['tenant'] == null) {
      throw Exception('Invalid tenant response: missing "tenant" key');
    }

    if (data['tenant'] is! Map) {
      throw Exception('Invalid tenant response: "tenant" is not an object');
    }

    return Tenant.fromJson(Map<String, dynamic>.from(data['tenant'] as Map));
  }

  Future<List<Tenant>> fetchTenants({
    required String tenantSlug,
    String? authToken,
  }) async {
    final api = ApiClient(tenantSlug: tenantSlug, authToken: authToken);

    const endpoint = '/v1/tenants';
    final requestUrl = '${api.dio.options.baseUrl}$endpoint';

    debugPrint('--- fetchTenants ---');
    debugPrint('REQUEST URL: $requestUrl');
    debugPrint('TENANT HEADER: $tenantSlug');
    debugPrint('AUTH TOKEN SET: ${authToken != null && authToken.isNotEmpty}');

    final response = await api.dio.get(endpoint);

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RAW RESPONSE: ${response.data}');

    final data = response.data;

    if (data is List) {
      return data
          .map((e) => Tenant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Tenant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    if (data is Map && data['tenants'] is List) {
      return (data['tenants'] as List)
          .map((e) => Tenant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    throw Exception(
      'Invalid tenants response: expected List or {data: List} or {tenants: List}, got ${data.runtimeType}',
    );
  }
}
