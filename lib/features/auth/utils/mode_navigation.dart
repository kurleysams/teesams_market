import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../catalog/screens/catalog_screen.dart';
import '../../tenant/screens/tenant_shell_screen.dart';
import '../../tenant/state/tenant_mode_provider.dart';

class ModeNavigation {
  static Future<void> goToTenant(BuildContext context) async {
    final tenantMode = context.read<TenantModeProvider>();
    await tenantMode.setSelectedMode('tenant');

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TenantShellScreen()),
      (route) => false,
    );
  }

  static Future<void> goToCustomer(BuildContext context) async {
    final tenantMode = context.read<TenantModeProvider>();
    await tenantMode.setSelectedMode('customer');

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CatalogScreen()),
      (route) => false,
    );
  }
}
