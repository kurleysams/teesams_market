class TenantMembership {
  final int membershipId;
  final int tenantId;
  final String tenantName;
  final int? storeId;
  final String? storeName;
  final String role;
  final List<String> permissions;

  const TenantMembership({
    required this.membershipId,
    required this.tenantId,
    required this.tenantName,
    required this.storeId,
    required this.storeName,
    required this.role,
    required this.permissions,
  });

  factory TenantMembership.fromJson(Map<String, dynamic> json) {
    return TenantMembership(
      membershipId: json['membership_id'] as int,
      tenantId: json['tenant_id'] as int,
      tenantName: json['tenant_name'] as String? ?? '',
      storeId: json['store_id'] as int?,
      storeName: json['store_name'] as String?,
      role: json['role'] as String? ?? 'fulfilment',
      permissions: (json['permissions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  bool hasPermission(String permission) => permissions.contains(permission);

  bool get canReadOrders => hasPermission('orders.read');
  bool get canUpdateOrderStatus => hasPermission('orders.update_status');
  bool get canCancelOrders => hasPermission('orders.cancel');
  bool get canManageStoreStatus => hasPermission('store_status.manage');
  bool get canManageProductAvailability =>
      hasPermission('product_availability.manage');
  bool get canManageStaff => hasPermission('staff.manage');
}
