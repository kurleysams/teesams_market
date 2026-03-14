import 'package:flutter/material.dart';

import '../models/tenant.dart';
import 'store_switcher_card.dart';

class StoreSwitcherRow extends StatelessWidget {
  final List<Tenant> tenants;
  final int? activeTenantId;
  final Function(Tenant tenant) onSelected;

  const StoreSwitcherRow({
    super.key,
    required this.tenants,
    required this.activeTenantId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (tenants.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tenants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final tenant = tenants[index];

          return StoreSwitcherCard(
            name: tenant.name,
            isCurrent: tenant.id == activeTenantId,
            onTap: () => onSelected(tenant),
          );
        },
      ),
    );
  }
}
