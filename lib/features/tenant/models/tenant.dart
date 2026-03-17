class Tenant {
  final int id;
  final String name;
  final String slug;
  final String currency;
  final String? tagline;
  final String? logoUrl;
  final String? bannerUrl;
  final String? primaryColor;

  const Tenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.currency,
    required this.tagline,
    required this.logoUrl,
    required this.bannerUrl,
    required this.primaryColor,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'GBP',
      tagline: json['tagline']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      primaryColor: json['primary_color']?.toString(),
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
