// lib/features/tenant/screens/tenant_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_order_summary.dart';
import '../state/seller_auth_provider.dart';
import '../state/tenant_dashboard_provider.dart';
import '../state/tenant_mode_provider.dart';
import '../state/tenant_order_action_provider.dart';
import '../state/tenant_order_details_provider.dart';
import '../state/tenant_orders_provider.dart';
import '../state/tenant_provider.dart';
import '../utils/tenant_order_ui.dart';
import 'tenant_order_details_screen.dart';
import 'tenant_shell_screen.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  DateTime? _lastLoadedAt;
  String? _lastTenantSlug;
  String? _lastSellerToken;
  bool _loadingTriggered = false;

  String? _activeSellerTenantSlug() {
    final sellerAuth = context.read<SellerAuthProvider>();
    final sellerSlug = sellerAuth.tenant?['slug']?.toString().trim();
    if (sellerSlug != null && sellerSlug.isNotEmpty) {
      return sellerSlug;
    }

    final storefrontSlug = context.read<TenantProvider>().tenant?.slug?.trim();
    if (storefrontSlug != null && storefrontSlug.isNotEmpty) {
      return storefrontSlug;
    }

    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final tenantSlug = _activeSellerTenantSlug() ?? '';
    final sellerToken = context.watch<SellerAuthProvider>().token ?? '';

    final tenantChanged = tenantSlug != _lastTenantSlug;
    final tokenChanged = sellerToken != _lastSellerToken;
    final shouldAttemptLoad =
        tenantSlug.isNotEmpty &&
        sellerToken.isNotEmpty &&
        (!_loadingTriggered || tenantChanged || tokenChanged);

    if (!shouldAttemptLoad) return;

    _lastTenantSlug = tenantSlug;
    _lastSellerToken = sellerToken;
    _loadingTriggered = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    final storefrontTenant = _activeSellerTenantSlug() ?? '';
    final sellerAuth = context.read<SellerAuthProvider>();
    final sellerToken = sellerAuth.token;

    if (storefrontTenant.isEmpty ||
        sellerToken == null ||
        sellerToken.isEmpty) {
      return;
    }

    debugPrint(
      'DASHBOARD LOAD START -> tenant=$storefrontTenant tokenPresent=${sellerToken.isNotEmpty}',
    );

    await context.read<TenantDashboardProvider>().loadDashboard(
      tenantSlug: storefrontTenant,
      authToken: sellerToken,
    );

    if (!mounted) return;

    setState(() {
      _lastLoadedAt = DateTime.now();
    });
  }

  Future<void> _openOrdersTabWithFilter({
    required String lifecycle,
    String? status,
  }) async {
    final tenantMode = context.read<TenantModeProvider>();
    if (!tenantMode.canReadOrders) return;

    final sellerAuth = context.read<SellerAuthProvider>();
    final storefrontTenant = _activeSellerTenantSlug() ?? '';
    final storeId = tenantMode.selectedStoreId;
    final token = sellerAuth.token;

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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const TenantShellScreen(initialIndex: 1),
      ),
    );
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
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
        ),
      );
    }

    if (dashboard == null) {
      return RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 80),
            Center(child: Text('No dashboard data')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DashboardHeader(
            lastLoadedAt: _lastLoadedAt,
            canReadOrders: tenantMode.canReadOrders,
            onRefresh: _loadDashboard,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.05,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _KpiCard(
                title: 'Pending',
                value: dashboard.counts.pending.toString(),
                icon: Icons.hourglass_top_rounded,
                accent: const Color(0xFFF59E0B),
                onTap: () => _openOrdersTabWithFilter(
                  lifecycle: 'active',
                  status: 'pending',
                ),
              ),
              _KpiCard(
                title: 'Preparing',
                value: dashboard.counts.preparing.toString(),
                icon: Icons.restaurant_rounded,
                accent: const Color(0xFF7C3AED),
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
                icon: Icons.local_shipping_outlined,
                accent: const Color(0xFF0F766E),
                onTap: () =>
                    _openOrdersTabWithFilter(lifecycle: 'active', status: null),
              ),
              _KpiCard(
                title: 'Completed Today',
                value: dashboard.counts.completedToday.toString(),
                icon: Icons.check_circle_outline,
                accent: const Color(0xFF16A34A),
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
            actionLabel: tenantMode.canReadOrders ? 'View all' : null,
            onActionTap: tenantMode.canReadOrders
                ? () => _openOrdersTabWithFilter(
                    lifecycle: 'active',
                    status: null,
                  )
                : null,
            child: dashboard.urgentOrders.isEmpty
                ? const _SectionEmptyState(message: 'No urgent orders')
                : Column(
                    children: dashboard.urgentOrders
                        .take(5)
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
            actionLabel: tenantMode.canReadOrders ? 'View all' : null,
            onActionTap: tenantMode.canReadOrders
                ? () => _openOrdersTabWithFilter(
                    lifecycle: 'active',
                    status: null,
                  )
                : null,
            child: dashboard.recentActiveOrders.isEmpty
                ? const _SectionEmptyState(message: 'No recent active orders')
                : Column(
                    children: dashboard.recentActiveOrders
                        .take(8)
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

class _DashboardHeader extends StatelessWidget {
  final DateTime? lastLoadedAt;
  final bool canReadOrders;
  final VoidCallback onRefresh;

  const _DashboardHeader({
    required this.lastLoadedAt,
    required this.canReadOrders,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = lastLoadedAt == null
        ? 'Pull to refresh'
        : 'Updated ${_formatTime(lastLoadedAt!)}';

    return Row(
      children: [
        Expanded(
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  static String _formatTime(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 18),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (actionLabel != null && onActionTap != null)
                  TextButton(onPressed: onActionTap, child: Text(actionLabel!)),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionEmptyState extends StatelessWidget {
  final String message;

  const _SectionEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
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
    final statusColor = TenantOrderUi.statusColor(order.status);

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          title: Text(
            '#${order.orderNumber} • ${order.customerName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InlineStatusPill(label: order.statusLabel, color: statusColor),
                Text(order.orderType.toUpperCase()),
                Text('£${order.total.toStringAsFixed(2)}'),
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _InlineStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InlineStatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
