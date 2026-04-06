// lib/features/tenant/screens/tenant_store_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_product_availability.dart';
import '../state/seller_auth_provider.dart';
import '../state/tenant_mode_provider.dart';
import '../state/tenant_product_provider.dart';
import '../state/tenant_provider.dart';
import '../state/tenant_store_provider.dart';
import '../widgets/tenant_category_group_card.dart';
import '../widgets/tenant_store_filters.dart';
import '../widgets/tenant_store_status_card.dart';
import '../widgets/tenant_store_summary_bar.dart';

class TenantStoreScreen extends StatefulWidget {
  const TenantStoreScreen({super.key});

  @override
  State<TenantStoreScreen> createState() => _TenantStoreScreenState();
}

class _TenantStoreScreenState extends State<TenantStoreScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _didLoad = false;
  final Set<int> _expandedCategoryIds = <int>{};
  final Set<int> _expandedProductIds = <int>{};

  String? _activeSellerTenantSlug() {
    final sellerAuth = context.read<SellerAuthProvider>();
    final sellerSlug = sellerAuth.tenant?['slug']?.toString().trim();
    if (sellerSlug != null && sellerSlug.isNotEmpty) {
      return sellerSlug;
    }

    final storefrontSlug = context.read<TenantProvider>().tenant?.slug?.trim();
    if (storefrontSlug != null && storefrontSlug.isNotEmpty) {
      return storefrontSlug;
    }

    return null;
  }

  String? _activeSellerToken() {
    final token = context.read<SellerAuthProvider>().token?.trim();
    if (token != null && token.isNotEmpty) {
      return token;
    }
    return null;
  }

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

  void _syncExpandedState(List<TenantProductCategoryGroup> groups) {
    final validCategoryIds = groups.map((g) => g.category.id).toSet();
    final validProductIds = groups
        .expand((g) => g.products.map((p) => p.id))
        .toSet();

    _expandedCategoryIds.removeWhere((id) => !validCategoryIds.contains(id));
    _expandedProductIds.removeWhere((id) => !validProductIds.contains(id));

    final hasSearch = _searchController.text.trim().isNotEmpty;
    if (hasSearch) {
      _expandedCategoryIds.addAll(validCategoryIds);
      _expandedProductIds.addAll(validProductIds);
    }
  }

  void _expandAll(List<TenantProductCategoryGroup> groups) {
    setState(() {
      _expandedCategoryIds
        ..clear()
        ..addAll(groups.map((g) => g.category.id));
      _expandedProductIds
        ..clear()
        ..addAll(groups.expand((g) => g.products.map((p) => p.id)));
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedCategoryIds.clear();
      _expandedProductIds.clear();
    });
  }

  void _toggleCategoryExpanded(int categoryId) {
    setState(() {
      if (_expandedCategoryIds.contains(categoryId)) {
        _expandedCategoryIds.remove(categoryId);
      } else {
        _expandedCategoryIds.add(categoryId);
      }
    });
  }

  void _toggleProductExpanded(int productId) {
    setState(() {
      if (_expandedProductIds.contains(productId)) {
        _expandedProductIds.remove(productId);
      } else {
        _expandedProductIds.add(productId);
      }
    });
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadAll() async {
    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final authToken = _activeSellerToken();
    final productProvider = context.read<TenantProductProvider>();

    if (tenantSlug.isEmpty || authToken == null) return;

    await Future.wait([
      context.read<TenantStoreProvider>().loadStore(
        tenantSlug: tenantSlug,
        authToken: authToken,
      ),
      productProvider.loadProducts(
        tenantSlug: tenantSlug,
        authToken: authToken,
      ),
    ]);

    if (!mounted) return;

    setState(() {
      _syncExpandedState(productProvider.groups);
    });
  }

  Future<bool> _confirmBulkAction({
    required String title,
    required String message,
    required bool isDestructive,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: isDestructive
                  ? FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    )
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<void> _toggleStore(bool value) async {
    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final authToken = _activeSellerToken();
    if (tenantSlug.isEmpty || authToken == null) return;

    final storeProvider = context.read<TenantStoreProvider>();
    final productProvider = context.read<TenantProductProvider>();

    final ok = await storeProvider.updateStatus(
      tenantSlug: tenantSlug,
      authToken: authToken,
      isOpen: value,
    );

    if (!mounted) return;

    if (!ok) {
      _showErrorSnack(
        (storeProvider.error ?? '').trim().isNotEmpty
            ? storeProvider.error!
            : 'Unable to update store status',
      );
      return;
    }

    await Future.wait([
      storeProvider.loadStore(tenantSlug: tenantSlug, authToken: authToken),
      productProvider.loadProducts(
        tenantSlug: tenantSlug,
        authToken: authToken,
        categoryId: productProvider.selectedCategoryId,
        search: productProvider.search,
      ),
    ]);

    if (!mounted) return;

    if ((storeProvider.error ?? '').trim().isNotEmpty ||
        (productProvider.error ?? '').trim().isNotEmpty) {
      _showErrorSnack(
        (storeProvider.error ??
                productProvider.error ??
                'Unable to refresh store')
            .toString(),
      );
      return;
    }

    _showSuccessSnack(value ? 'Store is now open' : 'Store is now closed');
  }

  Future<void> _toggleVariant(int variantId, bool value) async {
    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final authToken = _activeSellerToken();
    if (tenantSlug.isEmpty || authToken == null) return;

    final provider = context.read<TenantProductProvider>();

    final ok = await provider.updateAvailability(
      tenantSlug: tenantSlug,
      authToken: authToken,
      variantId: variantId,
      isAvailable: value,
    );

    if (!mounted) return;

    if (!ok && (provider.error ?? '').isNotEmpty) {
      _showErrorSnack(provider.error!);
    }
  }

  Future<void> _bulkToggleProduct(
    TenantProductAvailabilityGroup product,
    bool isAvailable,
  ) async {
    final confirmed = await _confirmBulkAction(
      title: isAvailable ? 'Enable all variants?' : 'Disable all variants?',
      message: isAvailable
          ? 'This will mark all variants in "${product.name}" as available.'
          : 'This will mark all variants in "${product.name}" as unavailable.',
      isDestructive: !isAvailable,
      confirmLabel: isAvailable ? 'Enable All' : 'Disable All',
    );

    if (!confirmed || !mounted) return;

    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final authToken = _activeSellerToken();
    final provider = context.read<TenantProductProvider>();

    if (tenantSlug.isEmpty || authToken == null) return;

    final ok = await provider.bulkUpdateProductAvailability(
      tenantSlug: tenantSlug,
      authToken: authToken,
      productId: product.id,
      isAvailable: isAvailable,
    );

    if (!mounted) return;

    if (!ok && (provider.error ?? '').isNotEmpty) {
      _showErrorSnack(provider.error!);
      return;
    }

    setState(() {
      _expandedProductIds.add(product.id);
      _syncExpandedState(provider.groups);
    });

    _showSuccessSnack(
      isAvailable
          ? 'All variants in product enabled'
          : 'All variants in product disabled',
    );
  }

  Future<void> _bulkToggleCategory(
    TenantProductCategory category,
    bool isAvailable,
  ) async {
    final confirmed = await _confirmBulkAction(
      title: isAvailable ? 'Enable category?' : 'Disable category?',
      message: isAvailable
          ? 'This will mark all variants in "${category.name}" as available.'
          : 'This will mark all variants in "${category.name}" as unavailable.',
      isDestructive: !isAvailable,
      confirmLabel: isAvailable ? 'Enable Category' : 'Disable Category',
    );

    if (!confirmed || !mounted) return;

    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final authToken = _activeSellerToken();
    final provider = context.read<TenantProductProvider>();

    if (tenantSlug.isEmpty || authToken == null) return;

    final ok = await provider.bulkUpdateCategoryAvailability(
      tenantSlug: tenantSlug,
      authToken: authToken,
      categoryId: category.id,
      isAvailable: isAvailable,
    );

    if (!mounted) return;

    if (!ok && (provider.error ?? '').isNotEmpty) {
      _showErrorSnack(provider.error!);
      return;
    }

    setState(() {
      _expandedCategoryIds.add(category.id);
      _syncExpandedState(provider.groups);
    });

    _showSuccessSnack(
      isAvailable
          ? 'All variants in category enabled'
          : 'All variants in category disabled',
    );
  }

  Future<void> _searchProducts() async {
    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final authToken = _activeSellerToken();
    final productProvider = context.read<TenantProductProvider>();
    final selectedCategoryId = productProvider.selectedCategoryId;

    if (tenantSlug.isEmpty || authToken == null) return;

    await productProvider.loadProducts(
      tenantSlug: tenantSlug,
      authToken: authToken,
      search: _searchController.text.trim(),
      categoryId: selectedCategoryId,
    );

    if (!mounted) return;

    setState(() {
      _syncExpandedState(productProvider.groups);
    });
  }

  Future<void> _loadMore() async {
    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final authToken = _activeSellerToken();
    final productProvider = context.read<TenantProductProvider>();
    final selectedCategoryId = productProvider.selectedCategoryId;

    if (tenantSlug.isEmpty || authToken == null) return;

    await productProvider.loadMore(
      tenantSlug: tenantSlug,
      authToken: authToken,
      categoryId: selectedCategoryId,
    );

    if (!mounted) return;

    setState(() {
      _syncExpandedState(productProvider.groups);
    });
  }

  Future<void> _selectCategory(int? categoryId) async {
    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final authToken = _activeSellerToken();
    final productProvider = context.read<TenantProductProvider>();

    if (tenantSlug.isEmpty || authToken == null) return;

    productProvider.setSelectedCategory(categoryId);

    await productProvider.loadProducts(
      tenantSlug: tenantSlug,
      authToken: authToken,
      search: _searchController.text.trim(),
      categoryId: categoryId,
    );

    if (!mounted) return;

    setState(() {
      _syncExpandedState(productProvider.groups);
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<TenantStoreProvider>();
    final productProvider = context.watch<TenantProductProvider>();
    final tenantMode = context.watch<TenantModeProvider>();

    final store = storeProvider.store;
    final groups = productProvider.groups;

    if (storeProvider.loading && store == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TenantStoreStatusCard(
            store: store,
            saving: storeProvider.saving,
            canManageStoreStatus: tenantMode.canManageStoreStatus,
            error: storeProvider.error,
            onToggle: _toggleStore,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Availability by Category',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TenantStoreSummaryBar(
                    categoryCount: productProvider.categoryCount,
                    productCount: productProvider.productCount,
                    variantCount: productProvider.variantCount,
                    totalCount: productProvider.total,
                  ),
                  const SizedBox(height: 12),
                  TenantStoreFilters(
                    controller: _searchController,
                    categories: productProvider.categories,
                    selectedCategoryId: productProvider.selectedCategoryId,
                    hasGroups: groups.isNotEmpty,
                    onChanged: (value) {
                      setState(() {});
                      final tenantSlug = _activeSellerTenantSlug() ?? '';
                      final authToken = _activeSellerToken();
                      if (tenantSlug.isEmpty || authToken == null) return;

                      context.read<TenantProductProvider>().debounceSearch(
                        tenantSlug: tenantSlug,
                        authToken: authToken,
                        search: value,
                        categoryId: context
                            .read<TenantProductProvider>()
                            .selectedCategoryId,
                      );
                    },
                    onSubmitted: _searchProducts,
                    onClear: () async {
                      _searchController.clear();
                      await _searchProducts();
                      if (mounted) setState(() {});
                    },
                    onSelectCategory: _selectCategory,
                    onExpandAll: () => _expandAll(groups),
                    onCollapseAll: _collapseAll,
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
                  else if (groups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No products found'),
                    )
                  else ...[
                    Column(
                      children: groups.map((categoryGroup) {
                        return TenantCategoryGroupCard(
                          key: ValueKey(
                            'category-${categoryGroup.category.id}',
                          ),
                          group: categoryGroup,
                          isExpanded: _expandedCategoryIds.contains(
                            categoryGroup.category.id,
                          ),
                          expandedProductIds: _expandedProductIds,
                          onToggleCategoryExpanded: () =>
                              _toggleCategoryExpanded(
                                categoryGroup.category.id,
                              ),
                          onToggleProductExpanded: _toggleProductExpanded,
                          isUpdating: productProvider.isUpdating,
                          onToggle: _toggleVariant,
                          onBulkCategoryToggle: _bulkToggleCategory,
                          onBulkProductToggle: _bulkToggleProduct,
                          canManageAvailability:
                              tenantMode.canManageProductAvailability,
                          bulkUpdating: productProvider.bulkUpdating,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    if (productProvider.hasMore)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: productProvider.loadingMore
                              ? null
                              : _loadMore,
                          child: productProvider.loadingMore
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Load more (${productProvider.currentPage}/${productProvider.lastPage})',
                                ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
