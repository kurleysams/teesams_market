class TenantProductAvailabilityGroup {
  final int id;
  final String name;
  final String slug;
  final bool isActive;
  final List<TenantVariantAvailability> variants;

  const TenantProductAvailabilityGroup({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    required this.variants,
  });

  factory TenantProductAvailabilityGroup.fromJson(Map<String, dynamic> json) {
    return TenantProductAvailabilityGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      isActive: json['is_active'] == true,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map(
            (e) => TenantVariantAvailability.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}

class TenantVariantAvailability {
  final int id;
  final int productId;
  final String productName;
  final String sku;
  final String variantName;
  final String unitType;
  final double unitQty;
  final double price;
  final double? salePrice;
  final bool isActive;
  final bool isAvailable;
  final bool trackInventory;
  final int stockQty;
  final bool allowBackorder;
  final bool canBeOrdered;

  const TenantVariantAvailability({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.variantName,
    required this.unitType,
    required this.unitQty,
    required this.price,
    required this.salePrice,
    required this.isActive,
    required this.isAvailable,
    required this.trackInventory,
    required this.stockQty,
    required this.allowBackorder,
    required this.canBeOrdered,
  });

  factory TenantVariantAvailability.fromJson(Map<String, dynamic> json) {
    return TenantVariantAvailability(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      variantName: json['variant_name']?.toString() ?? '',
      unitType: json['unit_type']?.toString() ?? '',
      unitQty: (json['unit_qty'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      isActive: json['is_active'] == true,
      isAvailable: json['is_available'] == true,
      trackInventory: json['track_inventory'] == true,
      stockQty: (json['stock_qty'] as num?)?.toInt() ?? 0,
      allowBackorder: json['allow_backorder'] == true,
      canBeOrdered: json['can_be_ordered'] == true,
    );
  }

  TenantVariantAvailability copyWith({bool? isAvailable}) {
    return TenantVariantAvailability(
      id: id,
      productId: productId,
      productName: productName,
      sku: sku,
      variantName: variantName,
      unitType: unitType,
      unitQty: unitQty,
      price: price,
      salePrice: salePrice,
      isActive: isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      trackInventory: trackInventory,
      stockQty: stockQty,
      allowBackorder: allowBackorder,
      canBeOrdered: canBeOrdered,
    );
  }
}
