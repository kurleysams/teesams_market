import 'tenant_membership.dart';

class AppBootstrap {
  final Map<String, dynamic> user;
  final List<String> availableModes;
  final List<TenantMembership> tenantMemberships;
  final String defaultMode;
  final int? defaultStoreId;

  const AppBootstrap({
    required this.user,
    required this.availableModes,
    required this.tenantMemberships,
    required this.defaultMode,
    required this.defaultStoreId,
  });

  bool get hasTenantMode => availableModes.contains('tenant');
  bool get hasCustomerMode => availableModes.contains('customer');
  bool get hasMultipleModes => availableModes.length > 1;
  bool get hasMultipleStores =>
      tenantMemberships.where((m) => m.storeId != null).length > 1;

  factory AppBootstrap.fromJson(Map<String, dynamic> json) {
    return AppBootstrap(
      user: Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      availableModes: (json['available_modes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      tenantMemberships: (json['tenant_memberships'] as List<dynamic>? ?? [])
          .map((e) => TenantMembership.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      defaultMode: json['default_mode'] as String? ?? 'customer',
      defaultStoreId: json['default_store_id'] as int?,
    );
  }
}
