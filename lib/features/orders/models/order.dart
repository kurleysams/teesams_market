import 'order_item.dart';

class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final String currency;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      currency: json['currency'] as String? ?? 'GBP',
      subtotal: double.parse((json['subtotal'] ?? '0').toString()),
      deliveryFee: double.parse((json['delivery_fee'] ?? '0').toString()),
      total: double.parse((json['total'] ?? '0').toString()),
      items: const [],
    );
  }

  OrderModel copyWithItems(List<OrderItemModel> newItems) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      status: status,
      currency: currency,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      items: newItems,
    );
  }
}
