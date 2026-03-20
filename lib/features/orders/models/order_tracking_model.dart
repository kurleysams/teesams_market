class OrderTrackingModel {
  final int? id;
  final String orderNumber;
  final String status;
  final String? paymentStatus;
  final String? paymentProvider;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? fulfilmentType;
  final String? deliveryAddress;
  final String? customerNote;
  final String? currency;
  final double? subtotal;
  final double? discountTotal;
  final double? deliveryFee;
  final double? totalAmount;
  final String? paidAt;
  final String? placedAt;
  final List<OrderTrackingItem> items;
  final List<OrderTrackingHistoryEntry> history;

  const OrderTrackingModel({
    this.id,
    required this.orderNumber,
    required this.status,
    this.paymentStatus,
    this.paymentProvider,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.fulfilmentType,
    this.deliveryAddress,
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
    final root = json['order'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['order'] as Map<String, dynamic>)
        : Map<String, dynamic>.from(json);

    final rawItems = root['items'] is List
        ? List<Map<String, dynamic>>.from(
            (root['items'] as List).map((e) => Map<String, dynamic>.from(e)),
          )
        : json['items'] is List
        ? List<Map<String, dynamic>>.from(
            (json['items'] as List).map((e) => Map<String, dynamic>.from(e)),
          )
        : <Map<String, dynamic>>[];

    final rawHistory = root['history'] is List
        ? List<Map<String, dynamic>>.from(
            (root['history'] as List).map((e) => Map<String, dynamic>.from(e)),
          )
        : json['history'] is List
        ? List<Map<String, dynamic>>.from(
            (json['history'] as List).map((e) => Map<String, dynamic>.from(e)),
          )
        : json['events'] is List
        ? List<Map<String, dynamic>>.from(
            (json['events'] as List).map((e) => Map<String, dynamic>.from(e)),
          )
        : <Map<String, dynamic>>[];

    return OrderTrackingModel(
      id: _asInt(root['id']),
      orderNumber:
          root['order_number']?.toString() ?? root['number']?.toString() ?? '',
      status: root['status']?.toString() ?? 'pending',
      paymentStatus: root['payment_status']?.toString(),
      paymentProvider: root['payment_provider']?.toString(),
      customerName: root['customer_name']?.toString(),
      customerPhone: root['customer_phone']?.toString(),
      customerEmail: root['customer_email']?.toString(),
      fulfilmentType: root['fulfilment_type']?.toString(),
      deliveryAddress: root['delivery_address']?.toString(),
      customerNote: root['customer_note']?.toString(),
      currency: root['currency']?.toString(),
      subtotal: _asDouble(root['subtotal']),
      discountTotal: _asDouble(root['discount_total']),
      deliveryFee: _asDouble(root['delivery_fee']),
      totalAmount: _asDouble(root['total']),
      paidAt: root['paid_at']?.toString(),
      placedAt: root['placed_at']?.toString() ?? root['created_at']?.toString(),
      items: rawItems.map(OrderTrackingItem.fromJson).toList(),
      history: rawHistory.map(OrderTrackingHistoryEntry.fromJson).toList(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _asDouble(dynamic value) {
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

  const OrderTrackingItem({
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
      variant: json['variant_name']?.toString() ?? json['variant']?.toString(),
      sku: json['sku']?.toString(),
      unitType: json['unit_type']?.toString(),
      unitQty: _asDouble(json['unit_qty']),
      qty: _asInt(json['qty']) ?? 0,
      unitPrice: _asDouble(json['unit_price']) ?? _asDouble(json['price_used']),
      totalPrice:
          _asDouble(json['total_price']) ?? _asDouble(json['line_total']),
      imageUrl: json['image_url']?.toString(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class OrderTrackingHistoryEntry {
  final String status;
  final String? note;
  final String? createdAt;

  const OrderTrackingHistoryEntry({
    required this.status,
    this.note,
    this.createdAt,
  });

  factory OrderTrackingHistoryEntry.fromJson(Map<String, dynamic> json) {
    return OrderTrackingHistoryEntry(
      status: json['status']?.toString() ?? 'pending',
      note: json['note']?.toString() ?? json['message']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
