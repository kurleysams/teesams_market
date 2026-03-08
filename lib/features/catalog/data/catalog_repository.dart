import '../models/category.dart';
import 'catalog_api.dart';

class CatalogRepository {
  final CatalogApi api;

  CatalogRepository({CatalogApi? api}) : api = api ?? CatalogApi();

  Future<List<Category>> fetchCategories({required String tenantSlug}) async {
    final json = await api.fetchCatalog(tenantSlug: tenantSlug);
    final snapshot = Map<String, dynamic>.from(json['snapshot'] as Map);
    final catalog = Map<String, dynamic>.from(snapshot['catalog'] as Map);
    final categories = (catalog['categories'] as List?) ?? const [];

    return categories
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
