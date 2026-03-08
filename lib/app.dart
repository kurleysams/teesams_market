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
        ChangeNotifierProvider(create: (_) => TenantProvider()..load()),
        ChangeNotifierProxyProvider<TenantProvider, CatalogProvider>(
          create: (_) => CatalogProvider(),
          update: (_, tenant, provider) => provider!..bindTenant(tenant),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProxyProvider<TenantProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (_, tenant, provider) => provider!..bindTenant(tenant),
        ),
        ChangeNotifierProxyProvider<TenantProvider, PaymentProvider>(
          create: (_) => PaymentProvider(),
          update: (_, tenant, provider) => provider!..bindTenant(tenant),
        ),
      ],
      child: MaterialApp(
        title: 'Teesams Market',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const CatalogScreen(),
      ),
    );
  }
}
