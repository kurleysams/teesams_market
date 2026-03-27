import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_dashboard.dart';

class TenantDashboardApi {
  Future<TenantDashboard> fetchDashboard({
    required String tenantSlug,
    required String authToken,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.get(Endpoints.tenantDashboard);

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tenant dashboard response');
    }

    return TenantDashboard.fromJson(data);
  }
}
