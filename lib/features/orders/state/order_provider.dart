import 'package:flutter/foundation.dart';

import '../../cart/models/cart_item.dart';
import '../../tenant/state/tenant_provider.dart';
import '../data/order_repository.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  String _tenantSlug = 'default';
  bool _loading = false;
  String? _error;
  OrderModel? _latestOrder;

  bool get loading => _loading;
  String? get error => _error;
  OrderModel? get latestOrder => _latestOrder;

  void bindTenant(TenantProvider tenantProvider) {
    _tenantSlug = tenantProvider.slug;
  }

  Future<OrderModel?> createOrder({
    required String customerName,
    required String? customerPhone,
    required String? customerEmail,
    required String fulfilmentType,
    required String? deliveryAddress,
    required String? customerNote,
    required List<CartItem> cartItems,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _latestOrder = await _repository.createOrder(
        tenantSlug: _tenantSlug,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        fulfilmentType: fulfilmentType,
        deliveryAddress: deliveryAddress,
        customerNote: customerNote,
        cartItems: cartItems,
      );
      return _latestOrder;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
