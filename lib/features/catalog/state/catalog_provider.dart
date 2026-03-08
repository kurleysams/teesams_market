import 'package:flutter/foundation.dart' hide Category;

import '../../tenant/state/tenant_provider.dart';
import '../data/catalog_repository.dart';
import '../models/category.dart';
import '../models/product.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogRepository _repository = CatalogRepository();

  List<Category> _categories = [];
  bool _loading = false;
  String? _error;
  String _tenantSlug = 'default';

  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;

  void bindTenant(TenantProvider tenantProvider) {
    if (_tenantSlug != tenantProvider.slug) {
      _tenantSlug = tenantProvider.slug;
      load();
    }
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.fetchCategories(tenantSlug: _tenantSlug);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<Product> search(String query) {
    final q = query.trim().toLowerCase();

    final List<Product> allProducts = _categories
        .expand<Product>((category) => category.products)
        .toList();

    if (q.isEmpty) return allProducts;

    return allProducts.where((product) {
      return product.name.toLowerCase().contains(q) ||
          (product.description?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
