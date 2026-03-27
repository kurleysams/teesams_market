import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_product_availability.dart';

class TenantProductApi {
  Future<TenantProductResponse> fetchProducts({
    required String tenantSlug,
    required String authToken,
    String? search,
    int page = 1,
    int perPage = 20,
    int? categoryId,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.get(
      Endpoints.tenantProducts,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'per_page': perPage,
        if (categoryId != null) 'category_id': categoryId,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tenant products response');
    }

    final groups = (data['data'] as List<dynamic>? ?? [])
        .map(
          (e) =>
              TenantProductCategoryGroup.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();

    final meta = data['meta'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['meta'])
        : <String, dynamic>{};

    return TenantProductResponse(
      groups: groups,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      perPage: (meta['per_page'] as num?)?.toInt() ?? perPage,
      total: (meta['total'] as num?)?.toInt() ?? groups.length,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
      hasMore: meta['has_more'] == true,
    );
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

class TenantProductResponse {
  final List<TenantProductCategoryGroup> groups;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final bool hasMore;

  const TenantProductResponse({
    required this.groups,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasMore,
  });
}
