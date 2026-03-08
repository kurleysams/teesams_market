import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/tenant_config.dart';
import '../models/tenant.dart';
import '../state/tenant_provider.dart';

class TenantSelectorSheet extends StatelessWidget {
  const TenantSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantProvider>();

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: supportedTenants.map((t) {
          final selected = provider.slug == t.slug;
          return ListTile(
            title: Text(t.displayName),
            subtitle: Text(t.slug),
            trailing: selected ? const Icon(Icons.check_circle) : null,
            onTap: () async {
              await provider.select(
                Tenant(slug: t.slug, displayName: t.displayName),
              );
              if (context.mounted) Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
