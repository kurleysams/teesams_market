import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/widgets/cart_icon_button.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/profile_screen.dart';
import '../../auth/state/auth_provider.dart';
import '../../orders/screens/my_orders_screen.dart';
import '../../tenant/screens/tenant_shell_screen.dart';
import '../../tenant/state/tenant_mode_provider.dart';
import '../../tenant/state/tenant_provider.dart';
import '../state/catalog_provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openStoreSelector() {
    Navigator.pushNamed(context, '/tenant-selector');
  }

  Future<void> _openMyOrders() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isAuthenticated) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));

      if (!mounted) return;
    }

    final authAfter = context.read<AuthProvider>();
    if (!authAfter.isAuthenticated) return;

    final tenantSlug = context.read<TenantProvider>().tenant?.slug ?? '';

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyOrdersScreen(tenantSlug: tenantSlug)),
    );
  }

  Future<void> _openProfile() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isAuthenticated) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));

      if (!mounted) return;
    }

    final authAfter = context.read<AuthProvider>();
    if (!authAfter.isAuthenticated) return;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  Future<void> _openStaffDashboard() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isAuthenticated) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));

      if (!mounted) return;
    }

    final authAfter = context.read<AuthProvider>();
    if (!authAfter.isAuthenticated) return;

    final tenantMode = context.read<TenantModeProvider>();
    await tenantMode.setSelectedMode('tenant');

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TenantShellScreen()),
      (route) => false,
    );
  }

  Future<void> _handleAccountAction(String value) async {
    final auth = context.read<AuthProvider>();
    final tenantSlug = context.read<TenantProvider>().tenant?.slug ?? '';

    switch (value) {
      case 'switch_store':
        _openStoreSelector();
        break;
      case 'profile':
        await _openProfile();
        break;
      case 'orders':
        await _openMyOrders();
        break;
      case 'staff_dashboard':
        await _openStaffDashboard();
        break;
      case 'login':
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
        break;
      case 'logout':
        await auth.logout(tenantSlug: tenantSlug);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signed out')));
        break;
    }
  }

  String? _normalizeUrl(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final origin = AppConfig.baseUrl.replaceFirst('/api', '');
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }

    return '$origin/$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final tenantProvider = context.watch<TenantProvider>();
    final auth = context.watch<AuthProvider>();
    final tenantMode = context.watch<TenantModeProvider>();

    final tenant = tenantProvider.tenant;
    final storeName = tenant?.name?.trim().isNotEmpty == true
        ? tenant!.name.trim()
        : 'Store';

    final selectedName = catalog.selectedCategory?.name ?? 'All';
    final productCount = catalog.filteredProducts.length;
    final bannerUrl = _normalizeUrl(tenant?.bannerUrl);

    final canAccessStaffDashboard =
        auth.isAuthenticated &&
        tenantMode.bootstrap != null &&
        tenantMode.bootstrap!.hasTenantMode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        toolbarHeight: 58,
        title: const Text(
          'Teesams Market',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleAccountAction,
            itemBuilder: (context) {
              if (auth.isAuthenticated) {
                return [
                  const PopupMenuItem(
                    value: 'switch_store',
                    child: Text('Switch store'),
                  ),
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('My Profile'),
                  ),
                  const PopupMenuItem(
                    value: 'orders',
                    child: Text('My Orders'),
                  ),
                  if (canAccessStaffDashboard)
                    const PopupMenuItem(
                      value: 'staff_dashboard',
                      child: Text('Staff dashboard'),
                    ),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ];
              }

              return const [
                PopupMenuItem(
                  value: 'switch_store',
                  child: Text('Switch store'),
                ),
                PopupMenuItem(value: 'login', child: Text('Sign in')),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
          CartIconButton(onTap: () => Navigator.pushNamed(context, '/cart')),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: catalog.loading
            ? const Center(child: CircularProgressIndicator())
            : catalog.error != null && catalog.error!.trim().isNotEmpty
            ? _CatalogErrorState(
                message: catalog.error!,
                onRetry: () {
                  final slug = tenantProvider.tenant?.slug;
                  if (slug != null && slug.isNotEmpty) {
                    context.read<CatalogProvider>().loadCatalogForTenant(slug);
                  }
                },
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _StoreBanner(
                          bannerUrl: bannerUrl,
                          storeName: storeName,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                          child: _StoreInfoCard(
                            isAuthenticated: auth.isAuthenticated,
                            userEmail: auth.user?.email,
                            onSwitchStore: _openStoreSelector,
                            onOrders: _openMyOrders,
                            onSignIn: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyHeaderDelegate(
                      height: 66,
                      child: _StickyContainer(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                          child: _SearchBar(
                            controller: _searchCtrl,
                            onChanged: (value) {
                              setState(() {});
                              catalog.setSearchQuery(value);
                            },
                            onClear: () {
                              _searchCtrl.clear();
                              setState(() {});
                              catalog.clearSearch();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyHeaderDelegate(
                      height: 50,
                      child: _StickyContainer(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: 32,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              children: [
                                _CategoryChip(
                                  label: 'All',
                                  isSelected: catalog.selectedCategory == null,
                                  onTap: () => catalog.selectCategory(null),
                                ),
                                const SizedBox(width: 8),
                                ...catalog.categories.map((category) {
                                  final isSelected =
                                      catalog.selectedCategoryId == category.id;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _CategoryChip(
                                      label: category.name,
                                      isSelected: isSelected,
                                      onTap: () =>
                                          catalog.selectCategory(category),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$selectedName products',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          Text(
                            '$productCount',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (catalog.filteredProducts.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: _EmptyCatalogState(),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = catalog.filteredProducts[index];
                        final productImageUrl = _normalizeUrl(product.imageUrl);

                        final subtitle = product.hasVariants
                            ? 'Browse options'
                            : (product.description?.trim().isNotEmpty == true
                                  ? product.description!.trim()
                                  : 'Ready to order');

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/product-details',
                                arguments: product,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x08000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _ProductThumb(imageUrl: productImageUrl),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          subtitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '£${product.minPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 24,
                                        color: Color(0xFF111827),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }, childCount: catalog.filteredProducts.length),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
      ),
      floatingActionButton: canAccessStaffDashboard
          ? FloatingActionButton.extended(
              onPressed: _openStaffDashboard,
              backgroundColor: const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.storefront_outlined),
              label: const Text(
                'Staff',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }
}

class _StoreInfoCard extends StatelessWidget {
  final bool isAuthenticated;
  final String? userEmail;
  final VoidCallback onSwitchStore;
  final VoidCallback onOrders;
  final VoidCallback onSignIn;

  const _StoreInfoCard({
    required this.isAuthenticated,
    required this.userEmail,
    required this.onSwitchStore,
    required this.onOrders,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = isAuthenticated && (userEmail ?? '').trim().isNotEmpty
        ? userEmail!.trim()
        : 'Browse this store and switch anytime';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shopping this store',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: onSwitchStore,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }
}

class _StoreBanner extends StatelessWidget {
  final String? bannerUrl;
  final String storeName;

  const _StoreBanner({required this.bannerUrl, required this.storeName});

  @override
  Widget build(BuildContext context) {
    final hasBanner = bannerUrl != null && bannerUrl!.trim().isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;

    double bannerHeight = 132;
    if (screenWidth < 390) {
      bannerHeight = 112;
    } else if (screenWidth < 430) {
      bannerHeight = 120;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      height: bannerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        color: const Color(0xFFEFF6FF),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasBanner)
            Image.network(
              bannerUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackBanner(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _fallbackBanner();
              },
            )
          else
            _fallbackBanner(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x66000000), Color(0x14000000)],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Text(
              storeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Color(0x66000000),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDCEBFF), Color(0xFFEFF6FF)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 38,
          color: Color(0xFF325A88),
        ),
      ),
    );
  }
}

class _StickyContainer extends StatelessWidget {
  final Widget child;

  const _StickyContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFF8FAFC), child: child);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
            size: 22,
            color: Color(0xFF4B5563),
          ),
          hintText: 'Search products...',
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF6B7280),
                    size: 18,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F1FF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE5E7EB),
            width: 1.1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? const Color(0xFF1D4ED8)
                  : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String? imageUrl;

  const _ProductThumb({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder();
          },
        ),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Icon(
        Icons.fastfood_outlined,
        color: Color(0xFF6B7280),
        size: 22,
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}

class _EmptyCatalogState extends StatelessWidget {
  const _EmptyCatalogState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF6B7280)),
          SizedBox(height: 10),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try a different search or category.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _CatalogErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CatalogErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load catalog',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
