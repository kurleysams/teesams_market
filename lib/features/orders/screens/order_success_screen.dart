import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/screens/login_screen.dart';
import '../../auth/state/auth_provider.dart';
import '../../tenant/state/tenant_provider.dart';
import 'my_orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final orderNumber = args?['orderNumber']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 64, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Payment confirmed',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(
                  orderNumber.isNotEmpty
                      ? 'Your order number is\n$orderNumber'
                      : 'Your order has been placed successfully',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final auth = context.read<AuthProvider>();

                      if (!auth.isAuthenticated) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );

                        if (!context.mounted) return;
                      }

                      final authAfter = context.read<AuthProvider>();
                      if (!authAfter.isAuthenticated) return;

                      final tenantSlug =
                          context.read<TenantProvider>().tenant?.slug ?? '';

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MyOrdersScreen(tenantSlug: tenantSlug),
                        ),
                      );
                    },
                    child: const Text('View My Orders'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/catalog-home', (_) => false);
                    },
                    child: const Text('Continue shopping'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
