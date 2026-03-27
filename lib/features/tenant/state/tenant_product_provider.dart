import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/tenant_product_api.dart';
import '../models/tenant_product_availability.dart';

class TenantProductProvider extends ChangeNotifier {
  final TenantProductApi _api = TenantProductApi();

  bool _loading = false;
  bool _loadingMore = false;
  final Set<int> _updatingIds = {};
  String? _error;

  List<TenantProductCategoryGroup> _groups = [];
  String _search = '';
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 20;
  int _total = 0;
  bool _hasMore = false;

  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  List<TenantProductCategoryGroup> get groups => _groups;

  // Backward-friendly alias if you referenced products in UI
  List<TenantProductCategoryGroup> get products => _groups;

  String get search => _search;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get perPage => _perPage;
  int get total => _total;
  bool get hasMore => _hasMore;

  bool isUpdating(int variantId) => _updatingIds.contains(variantId);

  Future<void> loadProducts({
    required String tenantSlug,
    required String authToken,
    String? search,
    int? categoryId,
  }) async {
    _loading = true;
    _error = null;
    _currentPage = 1;

    if (search != null) {
      _search = search;
    }

    notifyListeners();

    try {
      final response = await _api.fetchProducts(
        tenantSlug: tenantSlug,
        authToken: authToken,
        search: _search,
        page: 1,
        perPage: _perPage,
        categoryId: categoryId,
      );

      _groups = response.groups;
      _currentPage = response.currentPage;
      _lastPage = response.lastPage;
      _perPage = response.perPage;
      _total = response.total;
      _hasMore = response.hasMore;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to load products';
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({
    required String tenantSlug,
    required String authToken,
    int? categoryId,
  }) async {
    if (_loading || _loadingMore || !_hasMore) return;

    _loadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      final response = await _api.fetchProducts(
        tenantSlug: tenantSlug,
        authToken: authToken,
        search: _search,
        page: nextPage,
        perPage: _perPage,
        categoryId: categoryId,
      );

      _groups = _mergeGroups(_groups, response.groups);
      _currentPage = response.currentPage;
      _lastPage = response.lastPage;
      _perPage = response.perPage;
      _total = response.total;
      _hasMore = response.hasMore;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to load more products';
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> updateAvailability({
    required String tenantSlug,
    required String authToken,
    required int variantId,
    required bool isAvailable,
  }) async {
    _updatingIds.add(variantId);
    _error = null;
    notifyListeners();

    try {
      final updated = await _api.updateAvailability(
        tenantSlug: tenantSlug,
        authToken: authToken,
        variantId: variantId,
        isAvailable: isAvailable,
      );

      _groups = _groups.map((categoryGroup) {
        final updatedProducts = categoryGroup.products.map((product) {
          final updatedVariants = product.variants.map((variant) {
            if (variant.id == variantId) return updated;
            return variant;
          }).toList();

          return product.copyWith(variants: updatedVariants);
        }).toList();

        return TenantProductCategoryGroup(
          category: categoryGroup.category,
          products: updatedProducts,
        );
      }).toList();

      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to update variant';
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _updatingIds.remove(variantId);
      notifyListeners();
    }
  }

  List<TenantProductCategoryGroup> _mergeGroups(
    List<TenantProductCategoryGroup> existing,
    List<TenantProductCategoryGroup> incoming,
  ) {
    final Map<int, TenantProductCategoryGroup> map = {
      for (final group in existing) group.category.id: group,
    };

    for (final incomingGroup in incoming) {
      if (!map.containsKey(incomingGroup.category.id)) {
        map[incomingGroup.category.id] = incomingGroup;
        continue;
      }

      final existingGroup = map[incomingGroup.category.id]!;
      map[incomingGroup.category.id] = TenantProductCategoryGroup(
        category: existingGroup.category,
        products: [...existingGroup.products, ...incomingGroup.products],
      );
    }

    return map.values.toList();
  }
}
