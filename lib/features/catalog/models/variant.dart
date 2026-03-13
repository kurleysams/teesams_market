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
      id: _toInt(json['id']) ?? 0,
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unitType: json['unit_type']?.toString(),
      unitQty: _toDouble(json['unit_qty']),
      price: _toDouble(json['price']) ?? 0,
      salePrice: _toDouble(json['sale_price']),
      priceUsed: _toDouble(json['price_used']) ?? 0,
      hasDiscount: _toBool(json['has_discount']) ?? false,
      isAvailable: _toBool(json['is_available']) ?? true,
      trackInventory: _toBool(json['track_inventory']) ?? false,
      stockQty: _toInt(json['stock_qty']),
      allowBackorder: _toBool(json['allow_backorder']) ?? false,
      inStock: _toBool(json['in_stock']) ?? true,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final v = value.toLowerCase().trim();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return null;
  }
}
