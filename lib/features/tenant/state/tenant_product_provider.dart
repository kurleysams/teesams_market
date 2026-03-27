import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/tenant_product_api.dart';
import '../models/tenant_product_availability.dart';

class TenantProductProvider extends ChangeNotifier {
  final TenantProductApi _api = TenantProductApi();

  bool _loading = false;
  final Set<int> _updatingIds = {};
  String? _error;
  List<TenantProductAvailability> _products = [];
  String _search = '';

  bool get loading => _loading;
  String? get error => _error;
  List<TenantProductAvailability> get products => _products;
  String get search => _search;

  bool isUpdating(int productId) => _updatingIds.contains(productId);

  Future<void> loadProducts({
    required String tenantSlug,
    required String authToken,
    String? search,
  }) async {
    _loading = true;
    _error = null;
    if (search != null) {
      _search = search;
    }
    notifyListeners();

    try {
      _products = await _api.fetchProducts(
        tenantSlug: tenantSlug,
        authToken: authToken,
        search: _search,
      );
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

  Future<bool> updateAvailability({
    required String tenantSlug,
    required String authToken,
    required int productId,
    required bool isAvailable,
  }) async {
    _updatingIds.add(productId);
    _error = null;
    notifyListeners();

    try {
      final updated = await _api.updateAvailability(
        tenantSlug: tenantSlug,
        authToken: authToken,
        productId: productId,
        isAvailable: isAvailable,
      );

      _products = _products.map((p) {
        if (p.id == productId) return updated;
        return p;
      }).toList();

      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to update product';
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _updatingIds.remove(productId);
      notifyListeners();
    }
  }
}
