import 'package:flutter/foundation.dart';

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
  final bool canBeOrdered;

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
    required this.canBeOrdered,
  });

  bool get canPurchase => isAvailable && canBeOrdered;

  factory Variant.fromJson(Map<String, dynamic> json) {
    final isAvailable = _toStrictBool(json['is_available']) ?? true;
    final trackInventory = _toStrictBool(json['track_inventory']) ?? false;
    final stockQty = _toInt(json['stock_qty']);
    final allowBackorder = _toStrictBool(json['allow_backorder']) ?? false;

    final inStock =
        _toStrictBool(json['in_stock']) ??
        (!trackInventory || allowBackorder || (stockQty ?? 0) > 0);

    final canBeOrdered =
        _toStrictBool(json['can_be_ordered']) ?? (isAvailable && inStock);

    final variant = Variant(
      id: _toInt(json['id']) ?? 0,
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unitType: json['unit_type']?.toString(),
      unitQty: _toDouble(json['unit_qty']),
      price: _toDouble(json['price']) ?? 0,
      salePrice: _toDouble(json['sale_price']),
      priceUsed: _toDouble(json['price_used']) ?? 0,
      hasDiscount: _toStrictBool(json['has_discount']) ?? false,
      isAvailable: isAvailable,
      trackInventory: trackInventory,
      stockQty: stockQty,
      allowBackorder: allowBackorder,
      inStock: inStock,
      canBeOrdered: canBeOrdered,
    );

    debugPrint(
      'VARIANT PARSED -> '
      'id=${variant.id}, '
      'sku=${variant.sku}, '
      'isAvailable=${variant.isAvailable}, '
      'trackInventory=${variant.trackInventory}, '
      'stockQty=${variant.stockQty}, '
      'allowBackorder=${variant.allowBackorder}, '
      'inStock=${variant.inStock}, '
      'canBeOrdered=${variant.canBeOrdered}, '
      'raw=${json.toString()}',
    );

    return variant;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'unit_type': unitType,
      'unit_qty': unitQty,
      'price': price,
      'sale_price': salePrice,
      'price_used': priceUsed,
      'has_discount': hasDiscount,
      'is_available': isAvailable,
      'track_inventory': trackInventory,
      'stock_qty': stockQty,
      'allow_backorder': allowBackorder,
      'in_stock': inStock,
      'can_be_ordered': canBeOrdered,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static bool? _toStrictBool(dynamic value) {
    if (value == null) return null;

    if (value is bool) return value;

    if (value is int) {
      if (value == 1) return true;
      if (value == 0) return false;
      return null;
    }

    if (value is num) {
      final normalized = value.toInt();
      if (normalized == 1) return true;
      if (normalized == 0) return false;
      return null;
    }

    if (value is String) {
      final v = value.toLowerCase().trim();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
      return null;
    }

    return null;
  }
}
