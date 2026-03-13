import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/cart/state/cart_provider.dart';
import 'features/catalog/state/catalog_provider.dart';
import 'features/catalog/screens/catalog_screen.dart';
import 'features/orders/state/order_provider.dart';
import 'features/payments/state/payment_provider.dart';
import 'features/tenant/state/tenant_provider.dart';

class TeesamsMarketApp extends StatelessWidget {
  const TeesamsMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TenantProvider>(
          create: (_) => TenantProvider()..load(),
        ),
        ChangeNotifierProxyProvider<TenantProvider, CatalogProvider>(
          create: (_) => CatalogProvider(),
          update: (_, tenant, provider) {
            final catalogProvider = provider ?? CatalogProvider();
            catalogProvider.bindTenant(tenant);
            return catalogProvider;
          },
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
      ),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();

    if (tenantProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (tenantProvider.errorMessage != null &&
        tenantProvider.errorMessage!.isNotEmpty) {
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
                Text(tenantProvider.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => tenantProvider.load(),
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
