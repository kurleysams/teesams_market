import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/tenant_order_details_api.dart';

class TenantOrderActionProvider extends ChangeNotifier {
  final TenantOrderDetailsApi _api = TenantOrderDetailsApi();

  bool _loading = false;
  String? _error;
  String? _message;

  bool get loading => _loading;
  String? get error => _error;
  String? get message => _message;

  Future<TenantOrderActionResult?> submitAction({
    required String tenantSlug,
    required String authToken,
    required int orderId,
    required String action,
    String? reasonCode,
    String? note,
  }) async {
    _loading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final TenantOrderActionResult result;

      if (action == 'cancel_order') {
        if (reasonCode == null || reasonCode.trim().isEmpty) {
          throw Exception('Cancellation reason is required');
        }

        result = await _api.cancelOrder(
          tenantSlug: tenantSlug,
          authToken: authToken,
          orderId: orderId,
          reasonCode: reasonCode,
          note: note,
        );
      } else {
        result = await _api.transitionOrder(
          tenantSlug: tenantSlug,
          authToken: authToken,
          orderId: orderId,
          action: action,
          note: note,
        );
      }

      _message = result.message;
      return result;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to update order';
      }
      return null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearFeedback() {
    _error = null;
    _message = null;
    notifyListeners();
  }
}
