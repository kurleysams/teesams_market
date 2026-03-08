import '../../catalog/models/product.dart';
import '../../catalog/models/variant.dart';

class CartItem {
  final Product product;
  final Variant variant;
  int qty;

  CartItem({required this.product, required this.variant, this.qty = 1});

  double get lineTotal => variant.priceUsed * qty;

  String get title => '${product.name} • ${variant.name}';
}
