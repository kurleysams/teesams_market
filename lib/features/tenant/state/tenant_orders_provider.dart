import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/tenant_orders_api.dart';
import '../models/tenant_order_filter.dart';
import '../models/tenant_order_summary.dart';

class TenantOrdersProvider extends ChangeNotifier {
  final TenantOrdersApi _api = TenantOrdersApi();

  bool _loading = false;
  String? _error;

  TenantOrderFilter _filter = const TenantOrderFilter();
  List<TenantOrderSummary> _orders = [];

  int _currentPage = 1;
  int _perPage = 20;
  int _total = 0;

  bool get loading => _loading;
  String? get error => _error;
  TenantOrderFilter get filter => _filter;
  List<TenantOrderSummary> get orders => _orders;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  int get total => _total;

  Future<void> loadOrders({
    required String tenantSlug,
    required int storeId,
    required String authToken,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.fetchOrders(
        tenantSlug: tenantSlug,
        storeId: storeId,
        authToken: authToken,
        filter: _filter,
      );

      _orders = result.orders;
      _currentPage = result.currentPage;
      _perPage = result.perPage;
      _total = result.total;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to load tenant orders';
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setLifecycle(String lifecycle) {
    _filter = _filter.copyWith(lifecycle: lifecycle, page: 1);
    notifyListeners();
  }

  void setStatus(String? status) {
    _filter = _filter.copyWith(
      status: status,
      page: 1,
      clearStatus: status == null || status.isEmpty,
    );
    notifyListeners();
  }

  void setOrderType(String? orderType) {
    _filter = _filter.copyWith(
      orderType: orderType,
      page: 1,
      clearOrderType: orderType == null || orderType.isEmpty,
    );
    notifyListeners();
  }

  void setSearch(String search) {
    _filter = _filter.copyWith(
      search: search,
      page: 1,
      clearSearch: search.trim().isEmpty,
    );
    notifyListeners();
  }

  void clearFilters() {
    _filter = const TenantOrderFilter();
    notifyListeners();
  }
}
