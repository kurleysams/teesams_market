import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/currency.dart';
import '../../cart/state/cart_provider.dart';
import '../models/product.dart';
import '../models/variant.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Variant? selected;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      selected = widget.product.variants.firstWhere(
        (v) => v.inStock,
        orElse: () => widget.product.variants.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.icon(
          onPressed: selected == null || !(selected?.inStock ?? false)
              ? null
              : () {
                  cart.add(product, selected!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to cart: ${product.name}')),
                  );
                },
          icon: const Icon(Icons.add_shopping_cart),
          label: Text(selected == null ? 'Unavailable' : 'Add to cart'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (product.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      product.description!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Select option',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...product.variants.map((variant) {
                    final isSelected = selected?.id == variant.id;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: variant.inStock
                            ? () => setState(() => selected = variant)
                            : null,
                        title: Text(variant.name),
                        subtitle: Text(
                          variant.inStock
                              ? (variant.unitType ?? 'Option')
                              : 'Out of stock',
                        ),
                        trailing: Text(
                          gbp(variant.priceUsed),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        leading: Radio<bool>(
                          value: true,
                          groupValue: isSelected,
                          onChanged: variant.inStock
                              ? (_) => setState(() => selected = variant)
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
