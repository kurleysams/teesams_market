import 'package:flutter/material.dart';

import '../models/tenant_product_availability.dart';
import 'tenant_variant_switch_tile.dart';

class TenantProductGroupCard extends StatelessWidget {
  final TenantProductAvailabilityGroup group;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final bool Function(int variantId) isUpdating;
  final Future<void> Function(int variantId, bool value) onToggle;
  final Future<void> Function(bool value) onBulkProductToggle;
  final bool canManageAvailability;
  final bool bulkUpdating;

  const TenantProductGroupCard({
    super.key,
    required this.group,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.isUpdating,
    required this.onToggle,
    required this.onBulkProductToggle,
    required this.canManageAvailability,
    required this.bulkUpdating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group.isActive
                              ? 'Product active • ${group.variants.length} variants'
                              : 'Product inactive • ${group.variants.length} variants',
                          style: TextStyle(
                            color: group.isActive ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<bool>(
                    enabled: canManageAvailability && !bulkUpdating,
                    onSelected: onBulkProductToggle,
                    itemBuilder: (context) => const [
                      PopupMenuItem<bool>(
                        value: true,
                        child: Text('Enable all variants'),
                      ),
                      PopupMenuItem<bool>(
                        value: false,
                        child: Text('Disable all variants'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: group.variants.map((variant) {
                  final isSaving = isUpdating(variant.id);

                  return TenantVariantSwitchTile(
                    variant: variant,
                    isSaving: isSaving,
                    canManageAvailability: canManageAvailability,
                    bulkUpdating: bulkUpdating,
                    onChanged: (value) => onToggle(variant.id, value),
                  );
                }).toList(),
              ),
            ),
          if (!canManageAvailability)
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'You do not have permission to change availability.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
