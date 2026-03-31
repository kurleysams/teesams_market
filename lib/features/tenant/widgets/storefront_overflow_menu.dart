import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/state/auth_provider.dart';
import '../../tenant/state/seller_auth_provider.dart';
import '../../tenant/state/tenant_provider.dart';

enum StorefrontMenuAction {
  myOrders,
  customerSignIn,
  customerRegister,
  myProfile,
  customerSignOut,
  sellOnTeesams,
  sellerContinueSetup,
  sellerDashboard,
  sellerSignOut,
  help,
}

class StorefrontOverflowMenu extends StatelessWidget {
  const StorefrontOverflowMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final customerAuth = context.watch<AuthProvider>();
    final sellerAuth = context.watch<SellerAuthProvider>();

    final isCustomerSignedIn = customerAuth.isAuthenticated;
    final isSellerSignedIn = sellerAuth.isAuthenticated;

    final sellerTenant = sellerAuth.tenant;
    final sellerStatus = sellerTenant?['status']?.toString();
    final sellerIsActive = sellerTenant?['is_active'] == true;

    final sellerInOnboarding =
        isSellerSignedIn &&
        !sellerIsActive &&
        sellerStatus != null &&
        sellerStatus != 'active';

    final sellerHasDashboard = isSellerSignedIn && sellerIsActive;

    return PopupMenuButton<StorefrontMenuAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<StorefrontMenuAction>>[];

        if (!isCustomerSignedIn && !isSellerSignedIn) {
          items.addAll([
            const PopupMenuItem(
              value: StorefrontMenuAction.myOrders,
              child: Text('My orders'),
            ),
            const PopupMenuItem(
              value: StorefrontMenuAction.customerSignIn,
              child: Text('Sign in'),
            ),
            const PopupMenuItem(
              value: StorefrontMenuAction.customerRegister,
              child: Text('Create account'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: StorefrontMenuAction.sellOnTeesams,
              child: Text('Sell on Teesams'),
            ),
            const PopupMenuItem(
              value: StorefrontMenuAction.help,
              child: Text('Help'),
            ),
          ]);
          return items;
        }

        if (isCustomerSignedIn) {
          items.addAll([
            const PopupMenuItem(
              value: StorefrontMenuAction.myOrders,
              child: Text('My orders'),
            ),
            const PopupMenuItem(
              value: StorefrontMenuAction.sellOnTeesams,
              child: Text('Sell on Teesams'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: StorefrontMenuAction.customerSignOut,
              child: Text('Sign out'),
            ),
            const PopupMenuItem(
              value: StorefrontMenuAction.help,
              child: Text('Help'),
            ),
          ]);
          return items;
        }

        if (sellerInOnboarding) {
          items.addAll([
            const PopupMenuItem(
              value: StorefrontMenuAction.sellerContinueSetup,
              child: Text('Continue store setup'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: StorefrontMenuAction.sellerSignOut,
              child: Text('Sign out'),
            ),
            const PopupMenuItem(
              value: StorefrontMenuAction.help,
              child: Text('Help'),
            ),
          ]);
          return items;
        }

        if (sellerHasDashboard) {
          items.addAll([
            const PopupMenuItem(
              value: StorefrontMenuAction.sellerDashboard,
              child: Text('Store dashboard'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: StorefrontMenuAction.sellerSignOut,
              child: Text('Sign out'),
            ),
            const PopupMenuItem(
              value: StorefrontMenuAction.help,
              child: Text('Help'),
            ),
          ]);
          return items;
        }

        items.addAll([
          const PopupMenuItem(
            value: StorefrontMenuAction.sellOnTeesams,
            child: Text('Sell on Teesams'),
          ),
          const PopupMenuItem(
            value: StorefrontMenuAction.help,
            child: Text('Help'),
          ),
        ]);

        return items;
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    StorefrontMenuAction action,
  ) async {
    switch (action) {
      case StorefrontMenuAction.myOrders:
        Navigator.pushNamed(context, '/my-orders');
        break;

      case StorefrontMenuAction.customerSignIn:
        Navigator.pushNamed(context, '/customer/login');
        break;

      case StorefrontMenuAction.customerRegister:
        Navigator.pushNamed(context, '/customer/register');
        break;

      case StorefrontMenuAction.myProfile:
        // add when ready
        break;

      case StorefrontMenuAction.customerSignOut:
        final tenantSlug = context.read<TenantProvider>().tenant?.slug ?? '';

        if (tenantSlug.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Store information is missing')),
          );
          return;
        }

        await context.read<AuthProvider>().logout(tenantSlug: tenantSlug);

        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signed out')));
        break;

      case StorefrontMenuAction.sellOnTeesams:
        Navigator.pushNamed(context, '/seller/welcome');
        break;

      case StorefrontMenuAction.sellerContinueSetup:
        Navigator.pushNamed(context, '/seller/onboarding');
        break;

      case StorefrontMenuAction.sellerDashboard:
        Navigator.pushNamed(context, '/tenant-shell');
        break;

      case StorefrontMenuAction.sellerSignOut:
        await context.read<SellerAuthProvider>().logout();
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Seller signed out')));
        break;

      case StorefrontMenuAction.help:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Help screen coming soon')),
        );
        break;
    }
  }
}
