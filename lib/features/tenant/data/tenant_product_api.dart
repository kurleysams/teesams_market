import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_product_availability.dart';

class TenantProductApi {
  Future<List<TenantProductAvailability>> fetchProducts({
    required String tenantSlug,
    required String authToken,
    String? search,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.get(
      Endpoints.tenantProducts,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tenant products response');
    }

    return (data['data'] as List<dynamic>? ?? [])
        .map(
          (e) =>
              TenantProductAvailability.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<TenantProductAvailability> updateAvailability({
    required String tenantSlug,
    required String authToken,
    required int productId,
    required bool isAvailable,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.patch(
      Endpoints.tenantProductAvailability(productId),
      data: {'is_available': isAvailable},
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['product'] is! Map) {
      throw Exception('Invalid tenant product availability response');
    }

    return TenantProductAvailability.fromJson(
      Map<String, dynamic>.from(data['product']),
    );
  }
}
