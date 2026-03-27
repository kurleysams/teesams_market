import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/state/auth_provider.dart';
import '../state/tenant_product_provider.dart';
import '../state/tenant_provider.dart';
import '../state/tenant_store_provider.dart';

class TenantStoreScreen extends StatefulWidget {
  const TenantStoreScreen({super.key});

  @override
  State<TenantStoreScreen> createState() => _TenantStoreScreenState();
}

class _TenantStoreScreenState extends State<TenantStoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _didLoad = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didLoad) return;
    _didLoad = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final tenantSlug = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();

    if (tenantSlug.isEmpty || auth.token == null) {
      return;
    }

    await Future.wait([
      context.read<TenantStoreProvider>().loadStore(
        tenantSlug: tenantSlug,
        authToken: auth.token!,
      ),
      context.read<TenantProductProvider>().loadProducts(
        tenantSlug: tenantSlug,
        authToken: auth.token!,
      ),
    ]);
  }

  Future<void> _toggleStore(bool value) async {
    final tenantSlug = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();

    if (tenantSlug.isEmpty || auth.token == null) {
      return;
    }

    final provider = context.read<TenantStoreProvider>();

    final ok = await provider.updateStatus(
      tenantSlug: tenantSlug,
      authToken: auth.token!,
      isOpen: value,
    );

    if (!mounted) return;

    if (!ok && (provider.error ?? '').isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Store is now open' : 'Store is now closed'),
      ),
    );
  }

  Future<void> _toggleProduct(int productId, bool value) async {
    final tenantSlug = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();

    if (tenantSlug.isEmpty || auth.token == null) {
      return;
    }

    final provider = context.read<TenantProductProvider>();

    final ok = await provider.updateAvailability(
      tenantSlug: tenantSlug,
      authToken: auth.token!,
      productId: productId,
      isAvailable: value,
    );

    if (!mounted) return;

    if (!ok && (provider.error ?? '').isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Product available' : 'Product unavailable'),
      ),
    );
  }

  Future<void> _searchProducts() async {
    final tenantSlug = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();

    if (tenantSlug.isEmpty || auth.token == null) {
      return;
    }

    await context.read<TenantProductProvider>().loadProducts(
      tenantSlug: tenantSlug,
      authToken: auth.token!,
      search: _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<TenantStoreProvider>();
    final productProvider = context.watch<TenantProductProvider>();
    final store = storeProvider.store;

    if (storeProvider.loading && store == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Store Status',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (store == null)
                    const Text('No store data available')
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.isOpen ? 'Store is Open' : 'Store is Closed',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Switch(
                          value: store.isOpen,
                          onChanged: storeProvider.saving ? null : _toggleStore,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Timezone: ${store.timezone}'),
                    Text('Currency: ${store.currency}'),
                  ],
                  if ((storeProvider.error ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      storeProvider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Availability',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () async {
                                _searchController.clear();
                                await _searchProducts();
                                if (mounted) setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                    onSubmitted: (_) => _searchProducts(),
                  ),
                  const SizedBox(height: 12),
                  if (productProvider.loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if ((productProvider.error ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        productProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else if (productProvider.products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No products found'),
                    )
                  else
                    Column(
                      children: productProvider.products.map((product) {
                        final updating = productProvider.isUpdating(product.id);

                        return SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(product.name),
                          subtitle: Text(
                            '£${product.price.toStringAsFixed(2)}',
                          ),
                          value: product.isAvailable,
                          onChanged: updating
                              ? null
                              : (value) => _toggleProduct(product.id, value),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
