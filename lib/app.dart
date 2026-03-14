import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/cart/state/cart_provider.dart';
import 'features/catalog/screens/catalog_screen.dart';
import 'features/catalog/state/catalog_provider.dart';
import 'features/orders/state/order_provider.dart';
import 'features/payments/state/payment_provider.dart';
import 'features/tenant/screens/tenant_selector.dart';
import 'features/tenant/state/tenant_provider.dart';

class TeesamsMarketApp extends StatelessWidget {
  const TeesamsMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TenantProvider>(
          create: (_) => TenantProvider()..loadTenant(),
        ),
        ChangeNotifierProvider<CatalogProvider>(
          create: (_) => CatalogProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProxyProvider<TenantProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, tenant, provider) {
            final orderProvider = provider ?? OrderProvider();
            orderProvider.bindTenant(tenant);
            return orderProvider;
          },
        ),
        ChangeNotifierProxyProvider<TenantProvider, PaymentProvider>(
          create: (_) => PaymentProvider(),
          update: (_, tenant, provider) {
            final paymentProvider = provider ?? PaymentProvider();
            paymentProvider.bindTenant(tenant);
            return paymentProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Teesams Market',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AppEntry(),
        routes: {'/tenant-selector': (_) => const TenantSelector()},
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  String? _lastTenantSlug;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final tenantProvider = context.watch<TenantProvider>();
    final catalogProvider = context.read<CatalogProvider>();
    final tenant = tenantProvider.tenant;

    if (tenant != null && tenant.slug != _lastTenantSlug) {
      _lastTenantSlug = tenant.slug;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        catalogProvider.loadCatalogForTenant(tenant.slug);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();

    if (tenantProvider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (tenantProvider.error != null && tenantProvider.error!.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.store_mall_directory_outlined, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load store',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(tenantProvider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => tenantProvider.loadTenant(),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const CatalogScreen();
  }
}
