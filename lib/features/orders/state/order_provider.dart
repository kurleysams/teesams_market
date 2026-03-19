import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../cart/models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  bool _submitting = false;
  String? _error;

  bool get submitting => _submitting;
  String? get error => _error;

  Future<String> placeOrder({
    required String tenantSlug,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required String fulfilmentType,
    String? customerEmail,
    String? customerNote,
    required List<CartItem> items,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final api = ApiClient(tenantSlug: tenantSlug);

      final response = await api.dio.post(
        Endpoints.createOrder,
        data: {
          'customer_name': customerName,
          'customer_phone': customerPhone,
          'customer_email': customerEmail?.trim().isEmpty == true
              ? null
              : customerEmail?.trim(),
          'fulfilment_type': fulfilmentType,
          'delivery_address': deliveryAddress,
          'customer_note': customerNote?.trim().isEmpty == true
              ? null
              : customerNote?.trim(),
          'items': items.map((item) {
            return {'variant_id': item.variant.id, 'qty': item.qty};
          }).toList(),
        },
      );

      final data = response.data;

      String orderNumber = '';
      if (data is Map<String, dynamic>) {
        if (data['order'] is Map<String, dynamic>) {
          final order = data['order'] as Map<String, dynamic>;
          orderNumber =
              order['order_number']?.toString() ??
              order['number']?.toString() ??
              order['id']?.toString() ??
              '';
        } else {
          orderNumber =
              data['order_number']?.toString() ??
              data['number']?.toString() ??
              data['id']?.toString() ??
              '';
        }
      }

      if (orderNumber.isEmpty) {
        orderNumber = 'Order placed';
      }

      return orderNumber;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = e.message ?? 'Unable to place order';
      }

      throw Exception(_error);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      throw Exception(_error);
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
