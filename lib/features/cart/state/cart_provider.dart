import 'package:flutter/foundation.dart';

import '../../catalog/models/product.dart';
import '../../catalog/models/variant.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.qty);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);

  void add(Product product, Variant variant) {
    final existing = _items
        .where((i) => i.product.id == product.id && i.variant.id == variant.id)
        .toList();
    if (existing.isNotEmpty) {
      existing.first.qty += 1;
    } else {
      _items.add(CartItem(product: product, variant: variant));
    }
    notifyListeners();
  }

  void changeQty(CartItem item, int qty) {
    if (qty <= 0) {
      _items.remove(item);
    } else {
      item.qty = qty;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
