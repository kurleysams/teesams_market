class TenantProductAvailability {
  final int id;
  final String name;
  final double price;
  final bool isAvailable;

  const TenantProductAvailability({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
  });

  factory TenantProductAvailability.fromJson(Map<String, dynamic> json) {
    return TenantProductAvailability(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isAvailable: json['is_available'] == true,
    );
  }

  TenantProductAvailability copyWith({bool? isAvailable}) {
    return TenantProductAvailability(
      id: id,
      name: name,
      price: price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
