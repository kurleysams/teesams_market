// lib/features/catalog/state/catalog_provider.dart
import 'package:flutter/foundation.dart';

import '../data/catalog_repository.dart';
import '../models/category.dart' as catalog_model;
import '../models/product.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider({CatalogRepository? repository})
    : _repository = repository ?? CatalogRepository();

  final CatalogRepository _repository;

  List<catalog_model.Category> _categories = [];
  String _searchQuery = '';
  catalog_model.Category? _selectedCategory;
  bool _loading = false;
  String? _error;
  String? _loadedTenantSlug;

  List<catalog_model.Category> get categories => _categories;
  String get searchQuery => _searchQuery;
  catalog_model.Category? get selectedCategory => _selectedCategory;
  int? get selectedCategoryId => _selectedCategory?.id;
  bool get loading => _loading;
  String? get error => _error;

  List<Product> get allProducts {
    return _categories.expand((c) => c.products).toList();
  }

  List<Product> get filteredProducts {
    final source = _selectedCategory == null
        ? allProducts
        : _selectedCategory!.products;

    if (_searchQuery.trim().isEmpty) {
      return source;
    }

    final q = _searchQuery.toLowerCase().trim();

    return source.where((product) {
      final name = product.name.toLowerCase();
      final description = (product.description ?? '').toLowerCase();
      return name.contains(q) || description.contains(q);
    }).toList();
  }

  Future<void> loadCatalogForTenant(String tenantSlug) async {
    if (_loadedTenantSlug == tenantSlug && _categories.isNotEmpty) {
      debugPrint('Catalog already loaded for tenant: $tenantSlug');
      return;
    }

    debugPrint('--- loadCatalogForTenant ---');
    debugPrint('TENANT SLUG: $tenantSlug');

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _repository.fetchCategories(tenantSlug: tenantSlug);

      debugPrint('CATEGORIES LOADED: ${items.length}');

      _categories = items;
      _loadedTenantSlug = tenantSlug;

      if (_selectedCategory != null) {
        final match = _categories.where((c) => c.id == _selectedCategory!.id);
        _selectedCategory = match.isNotEmpty ? match.first : null;
      }
    } catch (e) {
      debugPrint('CATALOG LOAD ERROR: $e');
      _error = e.toString();
      _categories = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectCategory(catalog_model.Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void reset() {
    _categories = [];
    _searchQuery = '';
    _selectedCategory = null;
    _loading = false;
    _error = null;
    _loadedTenantSlug = null;
    notifyListeners();
  }
}
