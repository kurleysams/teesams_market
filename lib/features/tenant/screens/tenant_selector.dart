import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tenant_provider.dart';

class TenantSelector extends StatelessWidget {
  const TenantSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Store')),
      body: ListView.builder(
        itemCount: tenantProvider.tenants.length,
        itemBuilder: (context, index) {
          final tenant = tenantProvider.tenants[index];

          return ListTile(
            title: Text(tenant.name),
            subtitle: Text(tenant.slug),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected ${tenant.name}')),
              );
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
