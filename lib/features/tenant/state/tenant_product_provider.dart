import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/tenant_product_api.dart';
import '../models/tenant_product_availability.dart';

class TenantProductProvider extends ChangeNotifier {
  final TenantProductApi _api = TenantProductApi();

  bool _loading = false;
  bool _loadingMore = false;
  bool _bulkUpdating = false;
  final Set<int> _updatingIds = {};
  String? _error;

  Timer? _searchDebounce;
  List<TenantProductFilterCategory> _categories = [];
  int? _selectedCategoryId;

  List<TenantProductCategoryGroup> _groups = [];
  String _search = '';
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 20;
  int _total = 0;
  bool _hasMore = false;

  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get bulkUpdating => _bulkUpdating;
  String? get error => _error;

  List<TenantProductCategoryGroup> get groups => _groups;
  List<TenantProductCategoryGroup> get products => _groups;

  List<TenantProductFilterCategory> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;

  String get search => _search;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get perPage => _perPage;
  int get total => _total;
  bool get hasMore => _hasMore;

  int get categoryCount => _groups.length;

  int get productCount =>
      _groups.fold(0, (sum, group) => sum + group.products.length);

  int get variantCount => _groups.fold(
    0,
    (sum, group) =>
        sum +
        group.products.fold(
          0,
          (productSum, product) => productSum + product.variants.length,
        ),
  );

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

    _selectedCategoryId = categoryId;
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
      _categories = response.categories;
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
        categoryId: categoryId ?? _selectedCategoryId,
      );

      _groups = _mergeGroups(_groups, response.groups);
      _categories = response.categories;
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

    final previousGroups = _groups;
    _groups = _applyOptimisticVariantUpdate(
      groups: _groups,
      variantId: variantId,
      isAvailable: isAvailable,
    );
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
      _groups = previousGroups;
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to update variant';
      }
      return false;
    } catch (e) {
      _groups = previousGroups;
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _updatingIds.remove(variantId);
      notifyListeners();
    }
  }

  Future<bool> bulkUpdateProductAvailability({
    required String tenantSlug,
    required String authToken,
    required int productId,
    required bool isAvailable,
  }) async {
    _bulkUpdating = true;
    _error = null;
    notifyListeners();

    try {
      await _api.bulkUpdateAvailability(
        tenantSlug: tenantSlug,
        authToken: authToken,
        productId: productId,
        isAvailable: isAvailable,
      );

      await loadProducts(
        tenantSlug: tenantSlug,
        authToken: authToken,
        search: _search,
        categoryId: _selectedCategoryId,
      );

      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to bulk update product';
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _bulkUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> bulkUpdateCategoryAvailability({
    required String tenantSlug,
    required String authToken,
    required int categoryId,
    required bool isAvailable,
  }) async {
    _bulkUpdating = true;
    _error = null;
    notifyListeners();

    try {
      await _api.bulkUpdateAvailability(
        tenantSlug: tenantSlug,
        authToken: authToken,
        categoryId: categoryId,
        isAvailable: isAvailable,
      );

      await loadProducts(
        tenantSlug: tenantSlug,
        authToken: authToken,
        search: _search,
        categoryId: _selectedCategoryId,
      );

      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to bulk update category';
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _bulkUpdating = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void debounceSearch({
    required String tenantSlug,
    required String authToken,
    required String search,
    int? categoryId,
  }) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      loadProducts(
        tenantSlug: tenantSlug,
        authToken: authToken,
        search: search,
        categoryId: categoryId ?? _selectedCategoryId,
      );
    });
  }

  List<TenantProductCategoryGroup> _applyOptimisticVariantUpdate({
    required List<TenantProductCategoryGroup> groups,
    required int variantId,
    required bool isAvailable,
  }) {
    return groups.map((categoryGroup) {
      final updatedProducts = categoryGroup.products.map((product) {
        final updatedVariants = product.variants.map((variant) {
          if (variant.id == variantId) {
            return variant.copyWith(isAvailable: isAvailable);
          }
          return variant;
        }).toList();

        return product.copyWith(variants: updatedVariants);
      }).toList();

      return TenantProductCategoryGroup(
        category: categoryGroup.category,
        products: updatedProducts,
      );
    }).toList();
  }

  List<TenantProductCategoryGroup> _mergeGroups(
    List<TenantProductCategoryGroup> existing,
    List<TenantProductCategoryGroup> incoming,
  ) {
    final map = <int, TenantProductCategoryGroup>{
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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
