import 'product.dart';

class Category {
  final int id;
  final String name;
  final String slug;
  final int sortOrder;
  final List<Product> products;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.sortOrder,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      products: ((json['products'] as List?) ?? const [])
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
