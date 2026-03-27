class TenantStoreStatus {
  final int id;
  final String name;
  final String slug;
  final bool isOpen;
  final String timezone;
  final String currency;
  final Map<String, dynamic> settings;

  const TenantStoreStatus({
    required this.id,
    required this.name,
    required this.slug,
    required this.isOpen,
    required this.timezone,
    required this.currency,
    required this.settings,
  });

  factory TenantStoreStatus.fromJson(Map<String, dynamic> json) {
    return TenantStoreStatus(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      isOpen: json['is_open'] == true,
      timezone: json['timezone']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'GBP',
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }
}
