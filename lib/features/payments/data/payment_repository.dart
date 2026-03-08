import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';

class PaymentRepository {
  Future<Map<String, dynamic>> createPaymentIntent({
    required String tenantSlug,
    required int orderId,
  }) async {
    final client = ApiClient(tenantSlug: tenantSlug);
    final response = await client.dio.post(
      Endpoints.createPayment,
      data: {'order_id': orderId},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
