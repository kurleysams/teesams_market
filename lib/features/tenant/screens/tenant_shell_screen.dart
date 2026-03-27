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
  bool updateShouldNotify(TenantShellController oldWidget) {
    return false;
  }
}

class TenantShellScreen extends StatefulWidget {
  const TenantShellScreen({super.key});

  @override
  State<TenantShellScreen> createState() => _TenantShellScreenState();
}

class _TenantShellScreenState extends State<TenantShellScreen> {
  int _currentIndex = 0;

  void _goToOrders() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final tenantMode = context.watch<TenantModeProvider>();

    final pages = const [
      TenantDashboardScreen(),
      TenantOrdersScreen(),
      TenantStoreScreen(),
    ];

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
        body: pages[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (value) {
            setState(() {
              _currentIndex = value;
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
              icon: Icon(Icons.store_mall_directory_outlined),
              selectedIcon: Icon(Icons.store_mall_directory),
              label: 'Store',
            ),
          ],
        ),
      ),
    );
  }
}
