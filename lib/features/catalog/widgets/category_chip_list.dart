import 'package:flutter/material.dart';
import '../../catalog/models/category.dart';

class CategoryChipList extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final Function(Category category)? onSelected;

  const CategoryChipList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = category.id == selectedCategoryId;

        return ChoiceChip(
          label: Text(category.name),
          selected: isSelected,
          onSelected: (_) {
            if (onSelected != null) onSelected!(category);
          },
        );
      }).toList(),
    );
  }
}
