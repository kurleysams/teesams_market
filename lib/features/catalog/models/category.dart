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
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      sortOrder: _toInt(json['sort_order']) ?? 0,
      products: ((json['products'] as List?) ?? const [])
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
