class Variant {
  final int id;
  final String sku;
  final String name;
  final String? unitType;
  final double? unitQty;
  final double price;
  final double? salePrice;
  final double priceUsed;
  final bool hasDiscount;
  final bool isAvailable;
  final bool trackInventory;
  final int? stockQty;
  final bool allowBackorder;
  final bool inStock;

  const Variant({
    required this.id,
    required this.sku,
    required this.name,
    required this.unitType,
    required this.unitQty,
    required this.price,
    required this.salePrice,
    required this.priceUsed,
    required this.hasDiscount,
    required this.isAvailable,
    required this.trackInventory,
    required this.stockQty,
    required this.allowBackorder,
    required this.inStock,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'] as int,
      sku: json['sku'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unitType: json['unit_type'] as String?,
      unitQty: (json['unit_qty'] as num?)?.toDouble(),
      price: double.parse((json['price'] ?? '0').toString()),
      salePrice: json['sale_price'] == null
          ? null
          : double.parse(json['sale_price'].toString()),
      priceUsed: double.parse((json['price_used'] ?? '0').toString()),
      hasDiscount: json['has_discount'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      trackInventory: json['track_inventory'] as bool? ?? false,
      stockQty: json['stock_qty'] as int?,
      allowBackorder: json['allow_backorder'] as bool? ?? false,
      inStock: json['in_stock'] as bool? ?? true,
    );
  }
}
