import '../../catalog/models/product.dart';
import '../../catalog/models/variant.dart';

class CartItem {
  final Product product;
  final Variant variant;
  int qty;

  CartItem({required this.product, required this.variant, this.qty = 1});

  double get unitPrice => variant.priceUsed;

  double get lineTotal => unitPrice * qty;

  String get productName => product.name;

  String? get imageUrl => product.imageUrl;

  String get variantLabel {
    if (variant.name.trim().isNotEmpty) return variant.name.trim();

    final unit = variant.unitType?.trim() ?? '';
    final qtyValue = variant.unitQty;

    if (unit.isNotEmpty && qtyValue != null) {
      final qtyText = qtyValue % 1 == 0
          ? qtyValue.toInt().toString()
          : qtyValue.toString();
      return '$qtyText $unit';
    }

    if (unit.isNotEmpty) return unit;

    return 'Default';
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'variant': variant.toJson(),
      'qty': qty,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(
        Map<String, dynamic>.from(json['product'] as Map),
      ),
      variant: Variant.fromJson(
        Map<String, dynamic>.from(json['variant'] as Map),
      ),
      qty: (json['qty'] as num?)?.toInt() ?? 1,
    );
  }
}
