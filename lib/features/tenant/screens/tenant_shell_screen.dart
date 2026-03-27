import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/screens/login_screen.dart';
import '../../auth/state/auth_provider.dart';
import '../state/tenant_mode_provider.dart';
import '../state/tenant_provider.dart';
import 'tenant_dashboard_screen.dart';
import 'tenant_orders_screen.dart';
import 'tenant_store_screen.dart';

class TenantShellController extends InheritedWidget {
  final void Function() goToOrders;

  const TenantShellController({
    super.key,
    required this.goToOrders,
    required super.child,
  });

  static TenantShellController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TenantShellController>();
  }

  @override
  bool updateShouldNotify(TenantShellController oldWidget) => false;
}

class TenantShellScreen extends StatefulWidget {
  const TenantShellScreen({super.key});

  @override
  State<TenantShellScreen> createState() => _TenantShellScreenState();
}

class _TenantShellScreenState extends State<TenantShellScreen> {
  int _currentIndex = 0;

  void _goToOrders() {
    final tenantMode = context.read<TenantModeProvider>();
    final items = _itemsFor(tenantMode);
    final index = items.indexWhere(
      (item) => item.key == const ValueKey('orders'),
    );
    if (index >= 0) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  List<_ShellItem> _itemsFor(TenantModeProvider tenantMode) {
    final items = <_ShellItem>[
      const _ShellItem(
        key: ValueKey('dashboard'),
        page: TenantDashboardScreen(),
        destination: NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      ),
    ];

    if (tenantMode.canReadOrders) {
      items.add(
        const _ShellItem(
          key: ValueKey('orders'),
          page: TenantOrdersScreen(),
          destination: NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ),
      );
    }

    if (tenantMode.canManageStoreStatus ||
        tenantMode.canManageProductAvailability) {
      items.add(
        const _ShellItem(
          key: ValueKey('store'),
          page: TenantStoreScreen(),
          destination: NavigationDestination(
            icon: Icon(Icons.store_mall_directory_outlined),
            selectedIcon: Icon(Icons.store_mall_directory),
            label: 'Store',
          ),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final tenantMode = context.watch<TenantModeProvider>();
    final items = _itemsFor(tenantMode);

    if (_currentIndex >= items.length) {
      _currentIndex = 0;
    }

    return TenantShellController(
      goToOrders: _goToOrders,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tenantMode.selectedStoreName ?? 'Tenant Mode'),
          actions: [
            IconButton(
              onPressed: () async {
                await tenantMode.setSelectedMode('customer');
                if (!mounted) return;
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/catalog-home', (route) => false);
              },
              icon: const Icon(Icons.storefront_outlined),
              tooltip: 'Switch to customer mode',
            ),
            IconButton(
              onPressed: () async {
                final storefrontTenant = context
                    .read<TenantProvider>()
                    .tenant
                    ?.slug;

                if (storefrontTenant != null && storefrontTenant.isNotEmpty) {
                  await auth.logout(tenantSlug: storefrontTenant);
                } else {
                  await auth.forceClearSession();
                }

                tenantMode.clear();

                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: items[_currentIndex].page,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          destinations: items.map((e) => e.destination).toList(),
        ),
      ),
    );
  }
}

class _ShellItem {
  final Key key;
  final Widget page;
  final NavigationDestination destination;

  const _ShellItem({
    required this.key,
    required this.page,
    required this.destination,
  });
}
