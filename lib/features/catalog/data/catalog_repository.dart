import '../models/category.dart';
import 'catalog_api.dart';

class CatalogRepository {
  CatalogRepository({CatalogApi? api}) : _api = api ?? CatalogApi();

  final CatalogApi _api;

  Future<List<Category>> fetchCategories({required String tenantSlug}) {
    return _api.fetchCategories(tenantSlug: tenantSlug);
  }
}
