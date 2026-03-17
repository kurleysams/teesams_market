import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
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
    String? notes,
    required List<CartItem> items,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      final dio = Dio();

      final response = await dio.post(
        '${AppConfig.baseUrl}/v1/orders',
        options: Options(headers: {'X-Tenant': tenantSlug}),
        data: {
          'customer_name': customerName,
          'customer_phone': customerPhone,
          'delivery_address': deliveryAddress,
          'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
          'items': items
              .map(
                (item) => {
                  'product_id': item.product.id,
                  'variant_id': item.variant.id > 0 ? item.variant.id : null,
                  'qty': item.qty,
                },
              )
              .toList(),
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
      _error =
          e.response?.data?.toString() ?? e.message ?? 'Unable to place order';
      throw Exception(_error);
    } catch (e) {
      _error = e.toString();
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
