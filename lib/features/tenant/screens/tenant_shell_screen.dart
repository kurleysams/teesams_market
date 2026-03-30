import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/state/auth_provider.dart';
import '../../auth/utils/mode_navigation.dart';
import '../state/tenant_provider.dart';
import 'tenant_dashboard_screen.dart';
import 'tenant_orders_screen.dart';
import 'tenant_store_screen.dart';

class TenantShellScreen extends StatefulWidget {
  final int initialIndex;

  const TenantShellScreen({super.key, this.initialIndex = 0});

  @override
  State<TenantShellScreen> createState() => _TenantShellScreenState();
}

class _TenantShellScreenState extends State<TenantShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
  }

  Future<void> _handleMenu(String value) async {
    switch (value) {
      case 'customer_view':
        await ModeNavigation.goToCustomer(context);
        break;

      case 'logout':
        final tenantSlug = context.read<TenantProvider>().tenant?.slug ?? '';
        await context.read<AuthProvider>().logout(tenantSlug: tenantSlug);
        if (!mounted) return;
        await ModeNavigation.goToCustomer(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = context.watch<TenantProvider>().tenant;
    final tenantName = tenant?.name?.trim().isNotEmpty == true
        ? tenant!.name.trim()
        : 'Store';

    return Scaffold(
      appBar: AppBar(
        title: Text(tenantName),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'customer_view',
                child: Text('View customer storefront'),
              ),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TenantDashboardScreen(),
          TenantOrdersScreen(),
          TenantStoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (_currentIndex == index) return;
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}
