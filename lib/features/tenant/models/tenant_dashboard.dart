import 'tenant_order_summary.dart';

class TenantDashboard {
  final TenantDashboardStore store;
  final TenantDashboardCounts counts;
  final List<TenantOrderSummary> urgentOrders;
  final List<TenantOrderSummary> recentActiveOrders;

  const TenantDashboard({
    required this.store,
    required this.counts,
    required this.urgentOrders,
    required this.recentActiveOrders,
  });

  factory TenantDashboard.fromJson(Map<String, dynamic> json) {
    return TenantDashboard(
      store: TenantDashboardStore.fromJson(
        Map<String, dynamic>.from(json['store'] as Map? ?? {}),
      ),
      counts: TenantDashboardCounts.fromJson(
        Map<String, dynamic>.from(json['counts'] as Map? ?? {}),
      ),
      urgentOrders: (json['urgent_orders'] as List<dynamic>? ?? [])
          .map((e) => TenantOrderSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      recentActiveOrders: (json['recent_active_orders'] as List<dynamic>? ?? [])
          .map((e) => TenantOrderSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class TenantDashboardStore {
  final int id;
  final String name;

  const TenantDashboardStore({required this.id, required this.name});

  factory TenantDashboardStore.fromJson(Map<String, dynamic> json) {
    return TenantDashboardStore(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class TenantDashboardCounts {
  final int pending;
  final int confirmed;
  final int preparing;
  final int readyForPickup;
  final int outForDelivery;
  final int completedToday;

  const TenantDashboardCounts({
    required this.pending,
    required this.confirmed,
    required this.preparing,
    required this.readyForPickup,
    required this.outForDelivery,
    required this.completedToday,
  });

  factory TenantDashboardCounts.fromJson(Map<String, dynamic> json) {
    return TenantDashboardCounts(
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      confirmed: (json['confirmed'] as num?)?.toInt() ?? 0,
      preparing: (json['preparing'] as num?)?.toInt() ?? 0,
      readyForPickup: (json['ready_for_pickup'] as num?)?.toInt() ?? 0,
      outForDelivery: (json['out_for_delivery'] as num?)?.toInt() ?? 0,
      completedToday: (json['completed_today'] as num?)?.toInt() ?? 0,
    );
  }
}
