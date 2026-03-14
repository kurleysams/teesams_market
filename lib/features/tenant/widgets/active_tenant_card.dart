import 'package:flutter/material.dart';
import '../../../../features/tenant/models/tenant.dart';

class ActiveTenantCard extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback? onSwitchPressed;

  const ActiveTenantCard({
    super.key,
    required this.tenant,
    this.onSwitchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: tenant.logoUrl != null
                ? NetworkImage(tenant.logoUrl!)
                : null,
            child: tenant.logoUrl == null ? const Icon(Icons.storefront) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tenant.tagline ?? "Browse • Search • Cart • Checkout",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onSwitchPressed,
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text("Store"),
          ),
        ],
      ),
    );
  }
}
