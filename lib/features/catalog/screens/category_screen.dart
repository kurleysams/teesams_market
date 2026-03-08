import 'package:flutter/material.dart';

import '../../../shared/widgets/product_tile.dart';
import '../models/category.dart';
import 'product_details_screen.dart';

class CategoryScreen extends StatelessWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: category.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final product = category.products[index];
          return ProductTile(
            product: product,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            ),
          );
        },
      ),
    );
  }
}
