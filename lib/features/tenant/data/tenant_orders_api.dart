// lib/features/tenant/data/tenant_orders_api.dart

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_order_filter.dart';
import '../models/tenant_order_summary.dart';

class TenantOrdersApi {
  Future<TenantOrdersResponse> fetchOrders({
    required String tenantSlug,
    required int storeId,
    required String authToken,
    required TenantOrderFilter filter,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final query = <String, dynamic>{'store_id': storeId, ...filter.toQuery()};

    final response = await api.dio.get(
      Endpoints.tenantOrders,
      queryParameters: query,
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tenant orders response');
    }

    final items = (data['data'] as List<dynamic>? ?? [])
        .map((e) => TenantOrderSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final meta = data['meta'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['meta'])
        : <String, dynamic>{};

    return TenantOrdersResponse(
      orders: items,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      perPage: (meta['per_page'] as num?)?.toInt() ?? 20,
      total: (meta['total'] as num?)?.toInt() ?? items.length,
    );
  }
}

class TenantOrdersResponse {
  final List<TenantOrderSummary> orders;
  final int currentPage;
  final int perPage;
  final int total;

  const TenantOrdersResponse({
    required this.orders,
    required this.currentPage,
    required this.perPage,
    required this.total,
  });
}
