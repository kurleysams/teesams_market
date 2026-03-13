class Tenant {
  final int id;
  final String name;
  final String slug;
  final String? tagline;
  final String? logoUrl;
  final String? bannerUrl;
  final String? primaryColor;
  final bool isActive;
  final int sortOrder;

  const Tenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.tagline,
    required this.logoUrl,
    required this.bannerUrl,
    required this.primaryColor,
    required this.isActive,
    required this.sortOrder,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      tagline: json['tagline']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      primaryColor: json['primary_color']?.toString(),
      isActive: _toBool(json['is_active']) ?? true,
      sortOrder: _toInt(json['sort_order']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final v = value.toLowerCase().trim();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return null;
  }
}
