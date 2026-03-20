// lib/features/cart/state/cart_provider.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../catalog/models/product.dart';
import '../../catalog/models/variant.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  static const String _storageKey = 'teesams_market_cart_items';

  final List<CartItem> _items = [];
  bool _loaded = false;

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.qty);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);

  bool get loaded => _loaded;

  Future<void> loadCart() async {
    if (_loaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _items
            ..clear()
            ..addAll(
              decoded.map(
                (e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)),
              ),
            );
        }
      }
    } catch (_) {
      _items.clear();
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (_) {}
  }

  Future<void> add(Product product, Variant variant) async {
    final existing = _items.where(
      (i) => i.product.id == product.id && i.variant.id == variant.id,
    );

    if (existing.isNotEmpty) {
      existing.first.qty += 1;
    } else {
      _items.add(CartItem(product: product, variant: variant));
    }

    notifyListeners();
    await _saveCart();
  }

  Future<void> changeQty(CartItem item, int qty) async {
    if (qty <= 0) {
      _items.remove(item);
    } else {
      item.qty = qty;
    }

    notifyListeners();
    await _saveCart();
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _saveCart();
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _saveCart();
  }
}
