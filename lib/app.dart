import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/mode_picker_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/state/auth_provider.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/cart/state/cart_provider.dart';
import 'features/catalog/models/product.dart';
import 'features/catalog/screens/catalog_screen.dart';
import 'features/catalog/screens/product_details_screen.dart';
import 'features/catalog/state/catalog_provider.dart';
import 'features/orders/screens/checkout_screen.dart';
import 'features/orders/screens/my_orders_screen.dart';
import 'features/orders/screens/order_success_screen.dart';
import 'features/orders/state/order_provider.dart';
import 'features/payments/state/payment_provider.dart';
import 'features/tenant/screens/tenant_selector.dart';
import 'features/tenant/screens/tenant_shell_screen.dart';
import 'features/tenant/state/tenant_dashboard_provider.dart';
import 'features/tenant/state/tenant_mode_provider.dart';
import 'features/tenant/state/tenant_orders_provider.dart';
import 'features/tenant/state/tenant_product_provider.dart';
import 'features/tenant/state/tenant_provider.dart';
import 'features/tenant/state/tenant_store_provider.dart';

class TeesamsMarketApp extends StatelessWidget {
  const TeesamsMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<TenantProvider>(
          create: (_) => TenantProvider()..loadTenant(),
        ),
        ChangeNotifierProvider<TenantModeProvider>(
          create: (_) => TenantModeProvider(),
        ),
        ChangeNotifierProvider<TenantOrdersProvider>(
          create: (_) => TenantOrdersProvider(),
        ),
        ChangeNotifierProvider<CatalogProvider>(
          create: (_) => CatalogProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider()..loadCart(),
        ),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
        ChangeNotifierProxyProvider<TenantProvider, PaymentProvider>(
          create: (_) => PaymentProvider(),
          update: (_, tenant, provider) {
            final paymentProvider = provider ?? PaymentProvider();
            paymentProvider.bindTenant(tenant);
            return paymentProvider;
          },
        ),
        ChangeNotifierProvider<TenantDashboardProvider>(
          create: (_) => TenantDashboardProvider(),
        ),
        ChangeNotifierProvider<TenantStoreProvider>(
          create: (_) => TenantStoreProvider(),
        ),
        ChangeNotifierProvider<TenantProductProvider>(
          create: (_) => TenantProductProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Teesams Market',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AppEntry(),
        routes: {
          '/catalog-home': (_) => const _AppEntry(),
          '/tenant-selector': (_) => const TenantSelector(),
          '/cart': (_) => const CartScreen(),
          '/checkout': (_) => const CheckoutScreen(),
          '/order-success': (_) => const OrderSuccessScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/mode-picker': (_) => const ModePickerScreen(),
          '/tenant-shell': (_) => const TenantShellScreen(),
          '/my-orders': (context) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final tenant = Provider.of<TenantProvider>(
              context,
              listen: false,
            ).tenant;

            if (!auth.isAuthenticated) {
              return const LoginScreen();
            }

            return MyOrdersScreen(tenantSlug: tenant?.slug ?? '');
          },
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-details') {
            final args = settings.arguments;
            if (args is Product) {
              return MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: args),
              );
            }
          }
          return null;
        },
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
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final tenantProvider = context.watch<TenantProvider>();
    final catalogProvider = context.read<CatalogProvider>();
    final authProvider = context.read<AuthProvider>();
    final tenantModeProvider = context.read<TenantModeProvider>();
    final tenant = tenantProvider.tenant;

    if (tenant != null && tenant.slug != _lastTenantSlug) {
      _lastTenantSlug = tenant.slug;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await catalogProvider.loadCatalogForTenant(tenant.slug);
        if (!mounted) return;

        await authProvider.loadSession(tenantSlug: tenant.slug);
        if (!mounted) return;

        if (authProvider.isAuthenticated && authProvider.token != null) {
          await tenantModeProvider.loadBootstrap(
            tenantSlug: tenant.slug,
            authToken: authProvider.token,
          );

          if (!mounted) return;

          await _resolveInitialMode(
            authProvider: authProvider,
            tenantModeProvider: tenantModeProvider,
          );
        } else {
          tenantModeProvider.clear();
        }

        if (mounted) {
          setState(() {
            _didInit = true;
          });
        }
      });
    }
  }

  Future<void> _resolveInitialMode({
    required AuthProvider authProvider,
    required TenantModeProvider tenantModeProvider,
  }) async {
    final bootstrap = tenantModeProvider.bootstrap;
    if (!authProvider.isAuthenticated || bootstrap == null) return;

    if (bootstrap.hasTenantMode) {
      if (tenantModeProvider.selectedMode != 'tenant') {
        await tenantModeProvider.setSelectedMode('tenant');
      }
      return;
    }

    if (bootstrap.hasCustomerMode) {
      if (tenantModeProvider.selectedMode != 'customer') {
        await tenantModeProvider.setSelectedMode('customer');
      }
      return;
    }

    if (tenantModeProvider.selectedMode.isNotEmpty) {
      await tenantModeProvider.setSelectedMode('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final authProvider = context.watch<AuthProvider>();
    final tenantModeProvider = context.watch<TenantModeProvider>();

    if (tenantProvider.loading ||
        authProvider.loading ||
        tenantModeProvider.loading ||
        !_didInit) {
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
                  onPressed: () {
                    setState(() {
                      _didInit = false;
                      _lastTenantSlug = null;
                    });
                    tenantProvider.loadTenant();
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated &&
        tenantModeProvider.bootstrap != null &&
        tenantModeProvider.isTenantMode) {
      return const TenantShellScreen();
    }

    return const CatalogScreen();
  }
}
