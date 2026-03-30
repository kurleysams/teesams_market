import 'package:flutter/material.dart';

import '../models/tenant_product_availability.dart';

class TenantVariantSwitchTile extends StatelessWidget {
  final TenantVariantAvailability variant;
  final bool isSaving;
  final bool canManageAvailability;
  final bool bulkUpdating;
  final ValueChanged<bool> onChanged;

  const TenantVariantSwitchTile({
    super.key,
    required this.variant,
    required this.isSaving,
    required this.canManageAvailability,
    required this.bulkUpdating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];

    if (variant.variantName.isNotEmpty) {
      subtitleParts.add(variant.variantName);
    }
    if (variant.sku.isNotEmpty) {
      subtitleParts.add('SKU: ${variant.sku}');
    }
    if (variant.unitQty > 0 && variant.unitType.isNotEmpty) {
      subtitleParts.add('${variant.unitQty} ${variant.unitType}');
    }
    subtitleParts.add('£${variant.price.toStringAsFixed(2)}');

    if (variant.trackInventory) {
      subtitleParts.add('Stock: ${variant.stockQty}');
    }

    if (!variant.canBeOrdered) {
      subtitleParts.add('Not orderable');
    }

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(
            child: Text(
              variant.variantName.isNotEmpty
                  ? variant.variantName
                  : 'Default Variant',
            ),
          ),
          if (isSaving) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 6),
            const Text(
              'Saving...',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitleParts.join(' • ')),
      value: variant.isAvailable,
      onChanged: (!canManageAvailability || bulkUpdating || isSaving)
          ? null
          : onChanged,
    );
  }
}
