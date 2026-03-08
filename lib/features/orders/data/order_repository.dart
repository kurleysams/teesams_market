import '../../cart/models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import 'order_api.dart';

class OrderRepository {
  final OrderApi api;

  OrderRepository({OrderApi? api}) : api = api ?? OrderApi();

  Future<OrderModel> createOrder({
    required String tenantSlug,
    required String customerName,
    required String? customerPhone,
    required String? customerEmail,
    required String fulfilmentType,
    required String? deliveryAddress,
    required String? customerNote,
    required List<CartItem> cartItems,
  }) async {
    final payload = {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'fulfilment_type': fulfilmentType,
      'delivery_address': deliveryAddress,
      'customer_note': customerNote,
      'items': cartItems
          .map((i) => {'variant_id': i.variant.id, 'qty': i.qty})
          .toList(),
    };

    final json = await api.createOrder(
      tenantSlug: tenantSlug,
      payload: payload,
    );
    final order = OrderModel.fromJson(
      Map<String, dynamic>.from(json['order'] as Map),
    );
    final items = ((json['items'] as List?) ?? const [])
        .map(
          (e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    return order.copyWithItems(items);
  }
}
