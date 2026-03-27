import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/tenant_order_details_api.dart';
import '../models/tenant_order_details.dart';

class TenantOrderDetailsProvider extends ChangeNotifier {
  final TenantOrderDetailsApi _api = TenantOrderDetailsApi();

  bool _loading = false;
  String? _error;
  TenantOrderDetails? _order;

  bool get loading => _loading;
  String? get error => _error;
  TenantOrderDetails? get order => _order;

  Future<void> loadOrder({
    required String tenantSlug,
    required String authToken,
    required int orderId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _order = await _api.fetchOrderDetails(
        tenantSlug: tenantSlug,
        authToken: authToken,
        orderId: orderId,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to load order details';
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void replaceOrder(TenantOrderDetails order) {
    _order = order;
    notifyListeners();
  }

  void clear() {
    _order = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }
}
