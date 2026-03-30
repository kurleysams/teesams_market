import 'package:flutter/material.dart';

class TenantStoreSummaryBar extends StatelessWidget {
  final int categoryCount;
  final int productCount;
  final int variantCount;
  final int totalCount;

  const TenantStoreSummaryBar({
    super.key,
    required this.categoryCount,
    required this.productCount,
    required this.variantCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      '$categoryCount categories',
      '$productCount products',
      '$variantCount variants',
      '$totalCount total records',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
