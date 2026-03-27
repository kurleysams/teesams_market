import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/state/auth_provider.dart';
import '../models/tenant_order_summary.dart';
import '../state/tenant_dashboard_provider.dart';
import '../state/tenant_mode_provider.dart';
import '../state/tenant_order_action_provider.dart';
import '../state/tenant_order_details_provider.dart';
import '../state/tenant_orders_provider.dart';
import '../state/tenant_provider.dart';
import 'tenant_order_details_screen.dart';
import 'tenant_shell_screen.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didLoad) return;
    _didLoad = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    final storefrontTenant = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();

    if (storefrontTenant.isEmpty || auth.token == null) {
      return;
    }

    await context.read<TenantDashboardProvider>().loadDashboard(
      tenantSlug: storefrontTenant,
      authToken: auth.token!,
    );
  }

  Future<void> _openOrdersTabWithFilter({
    required String lifecycle,
    String? status,
  }) async {
    final tenantMode = context.read<TenantModeProvider>();
    if (!tenantMode.canReadOrders) return;

    final auth = context.read<AuthProvider>();
    final storefrontTenant = context.read<TenantProvider>().tenant?.slug ?? '';
    final storeId = tenantMode.selectedStoreId;
    final token = auth.token;

    final ordersProvider = context.read<TenantOrdersProvider>();
    ordersProvider.setLifecycle(lifecycle);
    ordersProvider.setStatus(status);

    if (storefrontTenant.isNotEmpty && storeId != null && token != null) {
      await ordersProvider.loadOrders(
        tenantSlug: storefrontTenant,
        storeId: storeId,
        authToken: token,
      );
    }

    if (!mounted) return;

    final shellState = TenantShellController.of(context);
    shellState?.goToOrders();
  }

  Future<void> _openOrderDetails(TenantOrderSummary order) async {
    final tenantMode = context.read<TenantModeProvider>();
    if (!tenantMode.canReadOrders) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TenantOrderDetailsProvider()),
            ChangeNotifierProvider(create: (_) => TenantOrderActionProvider()),
          ],
          child: TenantOrderDetailsScreen(orderId: order.id),
        ),
      ),
    );

    if (!mounted) return;
    await _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final tenantMode = context.watch<TenantModeProvider>();
    final dashboardProvider = context.watch<TenantDashboardProvider>();
    final dashboard = dashboardProvider.dashboard;

    if (dashboardProvider.loading && dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboardProvider.error != null &&
        dashboardProvider.error!.isNotEmpty &&
        dashboard == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dashboard_outlined, size: 52),
              const SizedBox(height: 12),
              const Text(
                'Unable to load dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(dashboardProvider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadDashboard,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (dashboard == null) {
      return const Center(child: Text('No dashboard data'));
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 4),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _KpiCard(
                title: 'Pending',
                value: dashboard.counts.pending.toString(),
                onTap: () => _openOrdersTabWithFilter(
                  lifecycle: 'active',
                  status: 'pending',
                ),
              ),
              _KpiCard(
                title: 'Preparing',
                value: dashboard.counts.preparing.toString(),
                onTap: () => _openOrdersTabWithFilter(
                  lifecycle: 'active',
                  status: 'preparing',
                ),
              ),
              _KpiCard(
                title: 'Ready / Out',
                value:
                    (dashboard.counts.readyForPickup +
                            dashboard.counts.outForDelivery)
                        .toString(),
                onTap: () =>
                    _openOrdersTabWithFilter(lifecycle: 'active', status: null),
              ),
              _KpiCard(
                title: 'Completed Today',
                value: dashboard.counts.completedToday.toString(),
                onTap: () => _openOrdersTabWithFilter(
                  lifecycle: 'completed',
                  status: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Urgent Orders',
            child: dashboard.urgentOrders.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('No urgent orders'),
                  )
                : Column(
                    children: dashboard.urgentOrders
                        .map(
                          (order) => _MiniOrderTile(
                            order: order,
                            onTap: () => _openOrderDetails(order),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Recent Active Orders',
            child: dashboard.recentActiveOrders.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('No recent active orders'),
                  )
                : Column(
                    children: dashboard.recentActiveOrders
                        .map(
                          (order) => _MiniOrderTile(
                            order: order,
                            onTap: () => _openOrderDetails(order),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MiniOrderTile extends StatelessWidget {
  final TenantOrderSummary order;
  final VoidCallback onTap;

  const _MiniOrderTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        '#${order.orderNumber} • ${order.customerName}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${order.statusLabel} • ${order.orderType.toUpperCase()} • £${order.total.toStringAsFixed(2)}',
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
