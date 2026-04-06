import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_dashboard.dart';

class TenantDashboardApi {
  Future<TenantDashboard> fetchDashboard({
    required String tenantSlug,
    required String authToken,
  }) async {
    final api = ApiClient.create(tenantSlug: tenantSlug, authToken: authToken);

    final response = await api.dio.get(Endpoints.sellerTenantDashboard);
    final data = response.data;

    debugPrint('DASHBOARD STATUS CODE -> ${response.statusCode}');
    debugPrint('DASHBOARD RAW RESPONSE -> $data');

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tenant dashboard response');
    }

    final payload = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'] as Map)
        : Map<String, dynamic>.from(data);

    if (payload.isEmpty) {
      throw Exception('Empty tenant dashboard payload');
    }

    return TenantDashboard.fromJson(payload);
  }
}
