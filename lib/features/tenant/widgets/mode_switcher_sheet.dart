import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/state/auth_provider.dart';
import '../state/seller_auth_provider.dart';

class ModeSwitcherSheet extends StatelessWidget {
  const ModeSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final customerAuth = context.watch<AuthProvider>();
    final sellerAuth = context.watch<SellerAuthProvider>();

    final isCustomer = customerAuth.isAuthenticated;
    final isSeller = sellerAuth.isAuthenticated;

    final sellerTenant = sellerAuth.tenant;
    final sellerStatus = sellerTenant?['status']?.toString();
    final sellerIsActive = sellerTenant?['is_active'] == true;

    final sellerInOnboarding =
        isSeller &&
        !sellerIsActive &&
        sellerStatus != null &&
        sellerStatus != 'active';

    final sellerHasDashboard =
        isSeller &&
        (sellerIsActive ||
            sellerStatus == 'approved' ||
            sellerStatus == 'active');

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(width: 42, child: Divider(thickness: 4)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose mode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Switch between shopping and managing your store.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 18),

            _ModeTile(
              icon: Icons.storefront_outlined,
              title: 'Shop as customer',
              subtitle: isCustomer
                  ? 'Continue browsing, checkout, and orders.'
                  : 'Browse stores and place orders.',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/catalog-home',
                  (route) => false,
                );
              },
            ),

            if (sellerInOnboarding) ...[
              const SizedBox(height: 12),
              _ModeTile(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Continue store setup',
                subtitle: 'Resume your seller onboarding steps.',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/seller/onboarding',
                    (route) => false,
                  );
                },
              ),
            ],

            if (sellerHasDashboard) ...[
              const SizedBox(height: 12),
              _ModeTile(
                icon: Icons.dashboard_outlined,
                title: 'Store dashboard',
                subtitle: 'Manage orders, products, and store operations.',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/tenant-shell',
                    (route) => false,
                  );
                },
              ),
            ],

            if (!isCustomer && !isSeller) ...[
              const SizedBox(height: 12),
              _ModeTile(
                icon: Icons.login_outlined,
                title: 'Seller sign in',
                subtitle: 'Access onboarding or your store dashboard.',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/seller/login');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1D4ED8)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
            ],
          ),
        ),
      ),
    );
  }
}
