import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';

class OrderApi {
  Future<Map<String, dynamic>> createOrder({
    required String tenantSlug,
    required Map<String, dynamic> payload,
  }) async {
    final client = await ApiClient.create(tenantSlug: tenantSlug);

    final response = await client.dio.post(
      Endpoints.createOrder,
      data: payload,
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}
