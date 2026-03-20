class OrderTrackingModel {
  final int? id;
  final String orderNumber;
  final String status;
  final String? paymentStatus;
  final String? paymentProvider;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? deliveryAddress;
  final String? fulfilmentType;
  final String? customerNote;
  final String? currency;
  final double? subtotal;
  final double? discountTotal;
  final double? deliveryFee;
  final double? totalAmount;
  final String? paidAt;
  final String? placedAt;
  final List<OrderTrackingItem> items;
  final List<OrderTrackingHistory> history;

  OrderTrackingModel({
    this.id,
    required this.orderNumber,
    required this.status,
    this.paymentStatus,
    this.paymentProvider,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.deliveryAddress,
    this.fulfilmentType,
    this.customerNote,
    this.currency,
    this.subtotal,
    this.discountTotal,
    this.deliveryFee,
    this.totalAmount,
    this.paidAt,
    this.placedAt,
    required this.items,
    required this.history,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    final root = (json['order'] is Map<String, dynamic>)
        ? json['order'] as Map<String, dynamic>
        : json;

    return OrderTrackingModel(
      id: int.tryParse((root['id'] ?? '').toString()),
      orderNumber: root['order_number']?.toString() ?? '',
      status: root['status']?.toString() ?? 'pending',
      paymentStatus: root['payment_status']?.toString(),
      paymentProvider: root['payment_provider']?.toString(),
      customerName: root['customer_name']?.toString(),
      customerPhone: root['customer_phone']?.toString(),
      customerEmail: root['customer_email']?.toString(),
      deliveryAddress: root['delivery_address']?.toString(),
      fulfilmentType: root['fulfilment_type']?.toString(),
      customerNote: root['customer_note']?.toString(),
      currency: root['currency']?.toString(),
      subtotal: _toDouble(root['subtotal']),
      discountTotal: _toDouble(root['discount_total']),
      deliveryFee: _toDouble(root['delivery_fee']),
      totalAmount: _toDouble(root['total_amount'] ?? root['total']),
      paidAt: root['paid_at']?.toString(),
      placedAt: root['placed_at']?.toString() ?? root['created_at']?.toString(),
      items: ((root['items'] as List?) ?? [])
          .map((e) => OrderTrackingItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      history: ((root['history'] as List?) ?? [])
          .map(
            (e) => OrderTrackingHistory.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class OrderTrackingItem {
  final String name;
  final String? variant;
  final String? sku;
  final String? unitType;
  final double? unitQty;
  final int qty;
  final double? unitPrice;
  final double? totalPrice;
  final String? imageUrl;

  OrderTrackingItem({
    required this.name,
    this.variant,
    this.sku,
    this.unitType,
    this.unitQty,
    required this.qty,
    this.unitPrice,
    this.totalPrice,
    this.imageUrl,
  });

  factory OrderTrackingItem.fromJson(Map<String, dynamic> json) {
    return OrderTrackingItem(
      name:
          json['product_name']?.toString() ??
          json['name']?.toString() ??
          'Item',
      variant: json['variant_name']?.toString(),
      sku: json['sku']?.toString(),
      unitType: json['unit_type']?.toString(),
      unitQty: OrderTrackingModel._toDouble(json['unit_qty']),
      qty: int.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      unitPrice: OrderTrackingModel._toDouble(
        json['unit_price'] ?? json['price_used'] ?? json['price'],
      ),
      totalPrice: OrderTrackingModel._toDouble(
        json['total_price'] ?? json['line_total'],
      ),
      imageUrl: json['image_url']?.toString(),
    );
  }
}

class OrderTrackingHistory {
  final String status;
  final String? note;
  final String? createdAt;

  OrderTrackingHistory({required this.status, this.note, this.createdAt});

  factory OrderTrackingHistory.fromJson(Map<String, dynamic> json) {
    return OrderTrackingHistory(
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
