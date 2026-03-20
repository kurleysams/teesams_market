import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/customer_order_summary.dart';
import '../models/order_tracking_model.dart';

class OrderProvider extends ChangeNotifier {
  bool _loadingOrders = false;
  bool _loadingOrderDetails = false;
  String? _error;

  List<CustomerOrderSummary> _orders = [];
  OrderTrackingModel? _selectedOrder;

  bool get loadingOrders => _loadingOrders;
  bool get loadingOrderDetails => _loadingOrderDetails;
  String? get error => _error;

  List<CustomerOrderSummary> get orders => _orders;
  OrderTrackingModel? get selectedOrder => _selectedOrder;

  Future<List<CustomerOrderSummary>> fetchMyOrders({
    required String tenantSlug,
  }) async {
    _loadingOrders = true;
    _error = null;
    notifyListeners();

    try {
      final api = await ApiClient.create(tenantSlug: tenantSlug);

      final response = await api.dio.get(Endpoints.myOrders);

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid orders response');
      }

      _orders = ((data['orders'] as List?) ?? [])
          .map(
            (e) => CustomerOrderSummary.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();

      return _orders;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to fetch orders';
      }

      throw Exception(_error);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      throw Exception(_error);
    } finally {
      _loadingOrders = false;
      notifyListeners();
    }
  }

  Future<OrderTrackingModel> fetchOrderDetails({
    required String tenantSlug,
    required int orderId,
  }) async {
    _loadingOrderDetails = true;
    _error = null;
    _selectedOrder = null;
    notifyListeners();

    try {
      final api = await ApiClient.create(tenantSlug: tenantSlug);

      final response = await api.dio.get(Endpoints.myOrderDetails(orderId));

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid order details response');
      }

      final order = OrderTrackingModel.fromJson(response.data);
      _selectedOrder = order;
      return order;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else if (e.response?.statusCode == 404) {
        _error = 'Order not found';
      } else {
        _error = e.message ?? 'Unable to fetch order';
      }

      throw Exception(_error);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      throw Exception(_error);
    } finally {
      _loadingOrderDetails = false;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
