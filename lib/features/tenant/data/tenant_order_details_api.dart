import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/tenant_order_details.dart';

class TenantOrderDetailsApi {
  Future<TenantOrderDetails> fetchOrderDetails({
    required String tenantSlug,
    required String authToken,
    required int orderId,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.get(Endpoints.tenantOrderDetails(orderId));

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tenant order details response');
    }

    return TenantOrderDetails.fromJson(data);
  }

  Future<TenantOrderActionResult> transitionOrder({
    required String tenantSlug,
    required String authToken,
    required int orderId,
    required String action,
    String? reasonCode,
    String? note,
  }) async {
    final api = await ApiClient.create(
      tenantSlug: tenantSlug,
      authToken: authToken,
    );

    final response = await api.dio.post(
      Endpoints.tenantOrderTransition(orderId),
      data: {
        'action': action,
        if (reasonCode != null && reasonCode.trim().isNotEmpty)
          'reason_code': reasonCode.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tenant order transition response');
    }

    return TenantOrderActionResult.fromJson(data);
  }
}

class TenantOrderActionResult {
  final String message;
  final int orderId;
  final String status;
  final String statusLabel;
  final List<TenantOrderActionSummary> allowedActions;

  const TenantOrderActionResult({
    required this.message,
    required this.orderId,
    required this.status,
    required this.statusLabel,
    required this.allowedActions,
  });

  factory TenantOrderActionResult.fromJson(Map<String, dynamic> json) {
    final order = Map<String, dynamic>.from(json['order'] as Map? ?? {});
    return TenantOrderActionResult(
      message: json['message']?.toString() ?? 'Order updated',
      orderId: (order['id'] as num?)?.toInt() ?? 0,
      status: order['status']?.toString() ?? '',
      statusLabel: order['status_label']?.toString() ?? '',
      allowedActions: (json['allowed_actions'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                TenantOrderActionSummary.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}
