class TenantProductCategoryGroup {
  final TenantProductCategory category;
  final List<TenantProductAvailabilityGroup> products;

  const TenantProductCategoryGroup({
    required this.category,
    required this.products,
  });

  factory TenantProductCategoryGroup.fromJson(Map<String, dynamic> json) {
    return TenantProductCategoryGroup(
      category: TenantProductCategory.fromJson(
        Map<String, dynamic>.from(json['category'] as Map? ?? {}),
      ),
      products: (json['products'] as List<dynamic>? ?? [])
          .map(
            (e) => TenantProductAvailabilityGroup.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}

class TenantProductCategory {
  final int id;
  final String name;

  const TenantProductCategory({required this.id, required this.name});

  factory TenantProductCategory.fromJson(Map<String, dynamic> json) {
    return TenantProductCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Uncategorized',
    );
  }
}

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

  TenantProductAvailabilityGroup copyWith({
    List<TenantVariantAvailability>? variants,
  }) {
    return TenantProductAvailabilityGroup(
      id: id,
      name: name,
      slug: slug,
      isActive: isActive,
      variants: variants ?? this.variants,
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
      isActive: _toBool(json['is_active']) ?? false,
      isAvailable: _toBool(json['is_available']) ?? false,
      trackInventory: _toBool(json['track_inventory']) ?? false,
      stockQty: (json['stock_qty'] as num?)?.toInt() ?? 0,
      allowBackorder: _toBool(json['allow_backorder']) ?? false,
      canBeOrdered: _toBool(json['can_be_ordered']) ?? false,
    );
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

class TenantProductFilterCategory {
  final int id;
  final String name;

  const TenantProductFilterCategory({required this.id, required this.name});

  factory TenantProductFilterCategory.fromJson(Map<String, dynamic> json) {
    return TenantProductFilterCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
