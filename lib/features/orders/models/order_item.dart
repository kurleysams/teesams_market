class OrderItemModel {
  final int? id;
  final String sku;
  final String productName;
  final String? variantName;
  final int qty;
  final double priceUsed;
  final double lineTotal;

  const OrderItemModel({
    this.id,
    required this.sku,
    required this.productName,
    required this.variantName,
    required this.qty,
    required this.priceUsed,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      sku: json['sku'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      variantName: json['variant_name'] as String?,
      qty: json['qty'] as int? ?? 0,
      priceUsed: double.parse((json['price_used'] ?? '0').toString()),
      lineTotal: double.parse((json['line_total'] ?? '0').toString()),
    );
  }
}
