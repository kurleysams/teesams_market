import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/customer_order_summary.dart';
import '../models/order_tracking_model.dart';

class OrderProvider extends ChangeNotifier {
  Future<List<CustomerOrderSummary>> fetchMyOrders({
    required String tenantSlug,
    required String authToken,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.get(Endpoints.myOrders);
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid orders response');
    }

    final items = (data['data'] ?? data['orders'] ?? []) as List<dynamic>;

    return items
        .map(
          (e) => CustomerOrderSummary.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<OrderTrackingModel> fetchOrderDetails({
    required String tenantSlug,
    required String authToken,
    required int orderId,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.get(Endpoints.myOrderDetails(orderId));
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid order details response');
    }

    final payload = data['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['data'] as Map)
        : data;

    return OrderTrackingModel.fromJson(payload);
  }
}
