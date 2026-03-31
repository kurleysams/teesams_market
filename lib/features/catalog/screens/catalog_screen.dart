import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/widgets/cart_icon_button.dart';
import '../../auth/screens/customer_login_screen.dart';
import '../../auth/screens/profile_screen.dart';
import '../../auth/state/auth_provider.dart';
import '../../orders/screens/my_orders_screen.dart';
import '../../tenant/screens/tenant_shell_screen.dart';
import '../../tenant/state/seller_auth_provider.dart';
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
      ).push(MaterialPageRoute(builder: (_) => const CustomerLoginScreen()));

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
      ).push(MaterialPageRoute(builder: (_) => const CustomerLoginScreen()));

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
      ).push(MaterialPageRoute(builder: (_) => const CustomerLoginScreen()));

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

  Future<void> _openSellerWelcome() async {
    await Navigator.pushNamed(context, '/seller/welcome');
  }

  Future<void> _openSellerLogin() async {
    await Navigator.pushNamed(context, '/seller/login');
  }

  Future<void> _openSellerDashboardOrOnboarding() async {
    final sellerAuth = context.read<SellerAuthProvider>();

    if (!sellerAuth.isAuthenticated) {
      await _openSellerLogin();
      return;
    }

    final tenant = sellerAuth.tenant;
    final status = tenant?['status']?.toString();
    final isActive = tenant?['is_active'] == true;

    if (isActive || status == 'active' || status == 'approved') {
      if (!mounted) return;
      Navigator.pushNamed(context, '/tenant-shell');
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(context, '/seller/onboarding');
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
      case 'seller_welcome':
        await _openSellerWelcome();
        break;
      case 'seller_login':
        await _openSellerLogin();
        break;
      case 'seller_portal':
        await _openSellerDashboardOrOnboarding();
        break;
      case 'login':
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CustomerLoginScreen()));
        break;
      case 'logout':
        if (tenantSlug.isEmpty) return;
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
    final sellerAuth = context.watch<SellerAuthProvider>();
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

    final hasSellerSession = sellerAuth.isAuthenticated;
    final sellerTenant = sellerAuth.tenant;
    final sellerStatus = sellerTenant?['status']?.toString();
    final sellerIsActive = sellerTenant?['is_active'] == true;
    final showSellerPortal =
        hasSellerSession &&
        (sellerIsActive ||
            sellerStatus == 'approved' ||
            sellerStatus == 'active' ||
            sellerStatus == 'pending_review' ||
            sellerStatus == 'onboarding_in_progress');

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
              final items = <PopupMenuEntry<String>>[
                const PopupMenuItem(
                  value: 'switch_store',
                  child: Text('Switch store'),
                ),
              ];

              if (auth.isAuthenticated) {
                items.addAll([
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('My Profile'),
                  ),
                  const PopupMenuItem(
                    value: 'orders',
                    child: Text('My Orders'),
                  ),
                ]);

                if (canAccessStaffDashboard) {
                  items.add(
                    const PopupMenuItem(
                      value: 'staff_dashboard',
                      child: Text('Staff dashboard'),
                    ),
                  );
                }
              } else {
                items.add(
                  const PopupMenuItem(value: 'login', child: Text('Sign in')),
                );
              }

              items.add(const PopupMenuDivider());

              if (showSellerPortal) {
                items.add(
                  const PopupMenuItem(
                    value: 'seller_portal',
                    child: Text('Seller portal'),
                  ),
                );
              } else {
                items.addAll([
                  const PopupMenuItem(
                    value: 'seller_welcome',
                    child: Text('Sell on Teesams'),
                  ),
                  const PopupMenuItem(
                    value: 'seller_login',
                    child: Text('Seller sign in'),
                  ),
                ]);
              }

              if (auth.isAuthenticated) {
                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                );
              }

              return items;
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
                          child: _StoreContextCard(
                            isAuthenticated: auth.isAuthenticated,
                            userEmail: auth.user?.email,
                            canAccessStaffDashboard: canAccessStaffDashboard,
                            onSwitchStore: _openStoreSelector,
                            onProfile: _openProfile,
                            onOrders: _openMyOrders,
                            onStaff: _openStaffDashboard,
                            onSignIn: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CustomerLoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: _SellerEntryCard(
                            hasSellerSession: hasSellerSession,
                            sellerIsActive: sellerIsActive,
                            sellerStatus: sellerStatus,
                            onStartSelling: _openSellerWelcome,
                            onSellerSignIn: _openSellerLogin,
                            onSellerPortal: _openSellerDashboardOrOnboarding,
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

class _StoreContextCard extends StatelessWidget {
  final bool isAuthenticated;
  final String? userEmail;
  final bool canAccessStaffDashboard;
  final VoidCallback onSwitchStore;
  final VoidCallback onProfile;
  final VoidCallback onOrders;
  final VoidCallback onStaff;
  final VoidCallback onSignIn;

  const _StoreContextCard({
    required this.isAuthenticated,
    required this.userEmail,
    required this.canAccessStaffDashboard,
    required this.onSwitchStore,
    required this.onProfile,
    required this.onOrders,
    required this.onStaff,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final displayEmail = (userEmail ?? '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: isAuthenticated
          ? _SignedInStoreBar(
              email: displayEmail,
              canAccessStaffDashboard: canAccessStaffDashboard,
              onSwitchStore: onSwitchStore,
              onProfile: onProfile,
              onOrders: onOrders,
              onStaff: onStaff,
            )
          : _GuestStoreBar(onSwitchStore: onSwitchStore, onSignIn: onSignIn),
    );
  }
}

class _SellerEntryCard extends StatelessWidget {
  final bool hasSellerSession;
  final bool sellerIsActive;
  final String? sellerStatus;
  final VoidCallback onStartSelling;
  final VoidCallback onSellerSignIn;
  final VoidCallback onSellerPortal;

  const _SellerEntryCard({
    required this.hasSellerSession,
    required this.sellerIsActive,
    required this.sellerStatus,
    required this.onStartSelling,
    required this.onSellerSignIn,
    required this.onSellerPortal,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = _sellerStatusText(
      sellerIsActive: sellerIsActive,
      sellerStatus: sellerStatus,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront_outlined, color: Color(0xFF1D4ED8)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Own a food business?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasSellerSession
                ? statusText
                : 'Open your store on Teesams, complete onboarding in the app, and submit for review.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: hasSellerSession
                ? [
                    FilledButton(
                      onPressed: onSellerPortal,
                      child: Text(
                        sellerIsActive
                            ? 'Open seller portal'
                            : 'Continue setup',
                      ),
                    ),
                  ]
                : [
                    FilledButton(
                      onPressed: onStartSelling,
                      child: const Text('Start selling'),
                    ),
                    OutlinedButton(
                      onPressed: onSellerSignIn,
                      child: const Text('Seller sign in'),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  String _sellerStatusText({
    required bool sellerIsActive,
    required String? sellerStatus,
  }) {
    if (sellerIsActive ||
        sellerStatus == 'active' ||
        sellerStatus == 'approved') {
      return 'Your seller account is ready. Open your portal to manage store operations.';
    }

    if (sellerStatus == 'pending_review') {
      return 'Your seller account is under review. You can check status and continue from your seller portal.';
    }

    if (sellerStatus == 'rejected') {
      return 'Your seller setup needs changes. Open your seller portal to review and update the required steps.';
    }

    return 'Continue your seller onboarding and finish the steps needed to submit your store for review.';
  }
}

class _SignedInStoreBar extends StatelessWidget {
  final String email;
  final bool canAccessStaffDashboard;
  final VoidCallback onSwitchStore;
  final VoidCallback onProfile;
  final VoidCallback onOrders;
  final VoidCallback onStaff;

  const _SignedInStoreBar({
    required this.email,
    required this.canAccessStaffDashboard,
    required this.onSwitchStore,
    required this.onProfile,
    required this.onOrders,
    required this.onStaff,
  });

  @override
  Widget build(BuildContext context) {
    final actionStyle = TextButton.styleFrom(
      foregroundColor: const Color(0xFF325A88),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 165),
            child: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onSwitchStore,
            visualDensity: VisualDensity.compact,
            splashRadius: 20,
            tooltip: 'Switch store',
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: Color(0xFF325A88),
            ),
          ),
          TextButton(
            onPressed: onProfile,
            style: actionStyle,
            child: const Text('Profile'),
          ),
          TextButton(
            onPressed: onOrders,
            style: actionStyle,
            child: const Text('Orders'),
          ),
          if (canAccessStaffDashboard)
            TextButton(
              onPressed: onStaff,
              style: actionStyle,
              child: const Text('Staff'),
            ),
        ],
      ),
    );
  }
}

class _GuestStoreBar extends StatelessWidget {
  final VoidCallback onSwitchStore;
  final VoidCallback onSignIn;

  const _GuestStoreBar({required this.onSwitchStore, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Browse stores and sign in to track your orders.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onSignIn,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Sign in'),
        ),
      ],
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
