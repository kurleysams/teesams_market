import 'package:flutter/material.dart';

import '../models/tenant_product_availability.dart';
import 'tenant_product_group_card.dart';

class TenantCategoryGroupCard extends StatelessWidget {
  final TenantProductCategoryGroup group;
  final bool isExpanded;
  final Set<int> expandedProductIds;
  final VoidCallback onToggleCategoryExpanded;
  final ValueChanged<int> onToggleProductExpanded;
  final bool Function(int variantId) isUpdating;
  final Future<void> Function(int variantId, bool value) onToggle;
  final Future<void> Function(TenantProductCategory category, bool value)
  onBulkCategoryToggle;
  final Future<void> Function(
    TenantProductAvailabilityGroup product,
    bool value,
  )
  onBulkProductToggle;
  final bool canManageAvailability;
  final bool bulkUpdating;

  const TenantCategoryGroupCard({
    super.key,
    required this.group,
    required this.isExpanded,
    required this.expandedProductIds,
    required this.onToggleCategoryExpanded,
    required this.onToggleProductExpanded,
    required this.isUpdating,
    required this.onToggle,
    required this.onBulkCategoryToggle,
    required this.onBulkProductToggle,
    required this.canManageAvailability,
    required this.bulkUpdating,
  });

  @override
  Widget build(BuildContext context) {
    final productCount = group.products.length;
    final variantCount = group.products.fold(
      0,
      (sum, product) => sum + product.variants.length,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: onToggleCategoryExpanded,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$productCount products • $variantCount variants',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<bool>(
                    enabled: canManageAvailability && !bulkUpdating,
                    onSelected: (value) =>
                        onBulkCategoryToggle(group.category, value),
                    itemBuilder: (context) => const [
                      PopupMenuItem<bool>(
                        value: true,
                        child: Text('Enable all in category'),
                      ),
                      PopupMenuItem<bool>(
                        value: false,
                        child: Text('Disable all in category'),
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
                children: group.products.map((product) {
                  return TenantProductGroupCard(
                    key: ValueKey('product-${product.id}'),
                    group: product,
                    isExpanded: expandedProductIds.contains(product.id),
                    onToggleExpanded: () => onToggleProductExpanded(product.id),
                    isUpdating: isUpdating,
                    onToggle: onToggle,
                    onBulkProductToggle: (value) =>
                        onBulkProductToggle(product, value),
                    canManageAvailability: canManageAvailability,
                    bulkUpdating: bulkUpdating,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
