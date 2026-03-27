import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../catalog/screens/catalog_screen.dart';
import '../../tenant/screens/tenant_shell_screen.dart';
import '../../tenant/state/tenant_mode_provider.dart';

class ModePickerScreen extends StatelessWidget {
  const ModePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantMode = context.watch<TenantModeProvider>();
    final bootstrap = tenantMode.bootstrap;

    if (bootstrap == null) {
      return const Scaffold(
        body: Center(child: Text('No mode data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Mode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (bootstrap.hasCustomerMode)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await tenantMode.setSelectedMode('customer');
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const CatalogScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Continue as Customer'),
                ),
              ),
            const SizedBox(height: 12),
            if (bootstrap.hasTenantMode)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await tenantMode.setSelectedMode('tenant');
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const TenantShellScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Continue as Store Staff'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
