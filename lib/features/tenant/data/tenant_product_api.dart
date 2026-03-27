import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_product_availability.dart';

class TenantProductApi {
  Future<List<TenantProductAvailabilityGroup>> fetchProducts({
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
          (e) => TenantProductAvailabilityGroup.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<TenantVariantAvailability> updateAvailability({
    required String tenantSlug,
    required String authToken,
    required int variantId,
    required bool isAvailable,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.patch(
      Endpoints.tenantVariantAvailability(variantId),
      data: {'is_available': isAvailable},
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['variant'] is! Map) {
      throw Exception('Invalid tenant variant availability response');
    }

    return TenantVariantAvailability.fromJson(
      Map<String, dynamic>.from(data['variant']),
    );
  }
}
