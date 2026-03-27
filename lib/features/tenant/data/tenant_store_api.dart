import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_store_status.dart';

class TenantStoreApi {
  Future<TenantStoreStatus> fetchStore({
    required String tenantSlug,
    required String authToken,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.get(Endpoints.tenantStore);
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tenant store response');
    }

    return TenantStoreStatus.fromJson(data);
  }

  Future<TenantStoreStatus> updateStoreStatus({
    required String tenantSlug,
    required String authToken,
    required bool isOpen,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.patch(
      Endpoints.tenantStoreStatus,
      data: {'is_open': isOpen},
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['store'] is! Map) {
      throw Exception('Invalid tenant store update response');
    }

    return TenantStoreStatus.fromJson(Map<String, dynamic>.from(data['store']));
  }
}
