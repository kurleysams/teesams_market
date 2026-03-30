import 'package:flutter/material.dart';

import '../models/tenant_product_availability.dart';

class TenantStoreFilters extends StatelessWidget {
  final TextEditingController controller;
  final List<TenantProductFilterCategory> categories;
  final int? selectedCategoryId;
  final bool hasGroups;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
  final ValueChanged<int?> onSelectCategory;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;

  const TenantStoreFilters({
    super.key,
    required this.controller,
    required this.categories,
    required this.selectedCategoryId,
    required this.hasGroups,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onSelectCategory,
    required this.onExpandAll,
    required this.onCollapseAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: hasGroups ? onExpandAll : null,
              icon: const Icon(Icons.unfold_more),
              label: const Text('Expand all'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: hasGroups ? onCollapseAll : null,
              icon: const Icon(Icons.unfold_less),
              label: const Text('Collapse all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search products or variants',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(onPressed: onClear, icon: const Icon(Icons.close)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted(),
        ),
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: selectedCategoryId == null,
                    onSelected: (_) => onSelectCategory(null),
                  ),
                ),
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: selectedCategoryId == category.id,
                      onSelected: (_) => onSelectCategory(category.id),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
