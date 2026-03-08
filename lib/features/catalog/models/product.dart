import 'variant.dart';

class Product {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int sortOrder;
  final List<Variant> variants;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.sortOrder,
    required this.variants,
  });

  bool get hasVariants => variants.isNotEmpty;

  double get minPrice {
    if (variants.isEmpty) return 0;
    return variants.map((v) => v.priceUsed).reduce((a, b) => a < b ? a : b);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      variants: ((json['variants'] as List?) ?? const [])
          .map((e) => Variant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
