import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/admin/screens/admin_tenant_review_screen.dart';
import 'features/auth/screens/customer_login_screen.dart';
import 'features/auth/screens/customer_register_screen.dart';
import 'features/auth/screens/mode_picker_screen.dart';
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
import 'features/tenant/screens/app_mode_entry_screen.dart';
import 'features/tenant/screens/seller_approved_screen.dart';
import 'features/tenant/screens/seller_business_details_screen.dart';
import 'features/tenant/screens/seller_catalog_setup_screen.dart';
import 'features/tenant/screens/seller_documents_screen.dart';
import 'features/tenant/screens/seller_login_screen.dart';
import 'features/tenant/screens/seller_onboarding_home_screen.dart';
import 'features/tenant/screens/seller_operations_screen.dart';
import 'features/tenant/screens/seller_payouts_screen.dart';
import 'features/tenant/screens/seller_pending_review_screen.dart';
import 'features/tenant/screens/seller_register_screen.dart';
import 'features/tenant/screens/seller_rejected_screen.dart';
import 'features/tenant/screens/seller_review_screen.dart';
import 'features/tenant/screens/seller_store_profile_screen.dart';
import 'features/tenant/screens/seller_welcome_screen.dart';
import 'features/tenant/screens/tenant_selector.dart';
import 'features/tenant/screens/tenant_shell_screen.dart';
import 'features/tenant/state/app_session_provider.dart';
import 'features/tenant/state/seller_auth_provider.dart';
import 'features/tenant/state/seller_onboarding_provider.dart';
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
        ChangeNotifierProvider<SellerAuthProvider>(
          create: (_) => SellerAuthProvider(),
        ),
        ChangeNotifierProxyProvider<
          SellerAuthProvider,
          SellerOnboardingProvider
        >(
          create: (context) =>
              SellerOnboardingProvider(context.read<SellerAuthProvider>()),
          update: (_, sellerAuthProvider, previous) =>
              previous ?? SellerOnboardingProvider(sellerAuthProvider),
        ),
        ChangeNotifierProvider<AppSessionProvider>(
          create: (_) => AppSessionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Teesams Market',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AppEntry(),
        routes: {
          '/catalog-home': (_) => const _AppEntry(),
          '/entry': (_) => const AppModeEntryScreen(),
          '/mode-picker': (_) => const ModePickerScreen(),
          '/tenant-selector': (_) => const TenantSelector(),
          '/tenant-shell': (_) => const TenantShellScreen(),
          '/cart': (_) => const CartScreen(),
          '/checkout': (_) => const CheckoutScreen(),
          '/order-success': (_) => const OrderSuccessScreen(),

          // Legacy aliases
          '/login': (_) => const CustomerLoginScreen(),
          '/register': (_) => const RegisterScreen(),

          // Explicit customer routes
          '/customer/login': (_) => const CustomerLoginScreen(),
          '/customer/register': (_) => const RegisterScreen(),

          '/my-orders': (context) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final tenant = Provider.of<TenantProvider>(
              context,
              listen: false,
            ).tenant;

            if (!auth.isAuthenticated) {
              return const CustomerLoginScreen();
            }

            return MyOrdersScreen(tenantSlug: tenant?.slug ?? '');
          },

          // Seller flow
          '/seller/welcome': (_) => const SellerWelcomeScreen(),
          '/seller/login': (_) => const SellerLoginScreen(),
          '/seller/register': (_) => const SellerRegisterScreen(),
          '/seller/onboarding': (_) => const SellerOnboardingHomeScreen(),
          '/seller/onboarding/business': (_) =>
              const SellerBusinessDetailsScreen(),
          '/seller/onboarding/store-profile': (_) =>
              const SellerStoreProfileScreen(),
          '/seller/onboarding/operations': (_) =>
              const SellerOperationsScreen(),
          '/seller/onboarding/documents': (_) => const SellerDocumentsScreen(),
          '/seller/onboarding/payouts': (_) => const SellerPayoutsScreen(),
          '/seller/onboarding/review': (_) => const SellerReviewScreen(),
          '/seller/onboarding/catalog': (_) => const SellerCatalogSetupScreen(),
          '/seller/pending-review': (_) => const SellerPendingReviewScreen(),
          '/seller/approved': (_) => const SellerApprovedScreen(),
          '/seller/rejected': (_) => const SellerRejectedScreen(),
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

          if (settings.name == '/admin/tenant-review') {
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              final tenantId = args['tenantId'];
              final tenantName = args['tenantName'];
              final status = args['status'];

              if (tenantId is int && tenantName is String && status is String) {
                return MaterialPageRoute(
                  builder: (_) => AdminTenantReviewScreen(
                    tenantId: tenantId,
                    tenantName: tenantName,
                    status: status,
                  ),
                );
              }
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
    final sellerAuthProvider = context.read<SellerAuthProvider>();
    final sellerOnboardingProvider = context.read<SellerOnboardingProvider>();
    final tenantModeProvider = context.read<TenantModeProvider>();
    final appSessionProvider = context.read<AppSessionProvider>();
    final tenant = tenantProvider.tenant;

    if (tenant != null && tenant.slug != _lastTenantSlug) {
      _lastTenantSlug = tenant.slug;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await catalogProvider.loadCatalogForTenant(tenant.slug);
        if (!mounted) return;

        await appSessionProvider.initialize(
          tenantSlug: tenant.slug,
          authProvider: authProvider,
          sellerAuthProvider: sellerAuthProvider,
          sellerOnboardingProvider: sellerOnboardingProvider,
          tenantModeProvider: tenantModeProvider,
        );

        if (!mounted) return;

        await _resolveInitialMode(
          authProvider: authProvider,
          tenantModeProvider: tenantModeProvider,
        );

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
    final appSessionProvider = context.watch<AppSessionProvider>();

    if (tenantProvider.loading ||
        authProvider.loading ||
        tenantModeProvider.loading ||
        appSessionProvider.loading ||
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
                    context.read<AppSessionProvider>().reset();
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
