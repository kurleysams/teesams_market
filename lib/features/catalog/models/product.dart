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
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      sortOrder: _toInt(json['sort_order']) ?? 0,
      variants: ((json['variants'] as List?) ?? const [])
          .map((e) => Variant.fromJson(Map<String, dynamic>.from(e as Map)))
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
