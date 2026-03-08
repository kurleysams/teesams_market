import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';

class CatalogApi {
  Future<Map<String, dynamic>> fetchCatalog({
    required String tenantSlug,
  }) async {
    final client = ApiClient(tenantSlug: tenantSlug);
    final response = await client.dio.get(Endpoints.catalog);
    return Map<String, dynamic>.from(response.data as Map);
  }
}
