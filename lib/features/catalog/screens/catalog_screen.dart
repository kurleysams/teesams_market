import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/currency.dart';
import '../../../features/cart/screens/cart_screen.dart';
import '../../../features/cart/state/cart_provider.dart';
import '../../../features/tenant/screens/tenant_selector.dart';
import '../../../features/tenant/state/tenant_provider.dart';
import '../../../shared/components/store_header.dart';
import '../../../shared/widgets/product_tile.dart';
import '../models/product.dart';
import '../state/catalog_provider.dart';
import 'category_screen.dart';
import 'product_details_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final tenant = context.watch<TenantProvider>().tenant;
    final catalog = context.watch<CatalogProvider>();
    final cart = context.watch<CartProvider>();
    final products = catalog.search(query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teesams Market'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: catalog.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StoreHeader(
              title: tenant.displayName,
              subtitle: 'Browse • Search • Cart • Checkout',
              onChangeStore: () => showModalBottomSheet(
                context: context,
                builder: (_) => const TenantSelectorSheet(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search products…',
              ),
              onChanged: (v) => setState(() => query = v),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: catalog.categories.map((c) {
                return ActionChip(
                  label: Text(c.name),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryScreen(category: c),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (catalog.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (catalog.error != null)
              Text(catalog.error!, style: const TextStyle(color: Colors.red)),
            if (!catalog.loading) ...[
              Text(
                'Results (${products.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...products.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductTile(
                    product: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: p),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
