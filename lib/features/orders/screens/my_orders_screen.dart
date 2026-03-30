import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../auth/state/auth_provider.dart';
import '../../tenant/state/tenant_provider.dart';
import '../models/customer_order_summary.dart';
import '../state/order_provider.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final String tenantSlug;

  const MyOrdersScreen({super.key, required this.tenantSlug});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  Future<List<CustomerOrderSummary>>? _future;
  bool _didInit = false;

  String _resolvedTenantSlug(BuildContext context) {
    if (widget.tenantSlug.trim().isNotEmpty) return widget.tenantSlug.trim();
    return context.read<TenantProvider>().tenant?.slug ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInit) return;
    _didInit = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeLoadOrders();
    });
  }

  Future<void> _maybeLoadOrders() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isAuthenticated) {
      setState(() {
        _future = null;
      });
      return;
    }

    final tenantSlug = _resolvedTenantSlug(context);
    if (tenantSlug.isEmpty) return;

    setState(() {
      _future = context.read<OrderProvider>().fetchMyOrders(
        tenantSlug: tenantSlug,
      );
    });
  }

  Future<void> _reload() async {
    final auth = context.read<AuthProvider>();

    if (!auth.isAuthenticated) {
      setState(() {
        _future = null;
      });
      return;
    }

    final tenantSlug = _resolvedTenantSlug(context);
    if (tenantSlug.isEmpty) return;

    final future = context.read<OrderProvider>().fetchMyOrders(
      tenantSlug: tenantSlug,
    );

    setState(() {
      _future = future;
    });

    await future;
  }

  Future<void> _openLogin() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));

    if (!mounted) return;
    await _maybeLoadOrders();
  }

  Future<void> _openRegister() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));

    if (!mounted) return;
    await _maybeLoadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final future = _future;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('My Orders')),
      body: !auth.isAuthenticated
          ? RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 72),
                  _OrdersMessageCard(
                    icon: Icons.lock_outline,
                    title: 'Sign in to view saved orders',
                    message:
                        'Orders placed while signed in appear here. If you checked out as a guest, sign in or create an account with the same email used at checkout to claim your order.',
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _openLogin,
                            child: const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _openRegister,
                            child: const Text('Create account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : future == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<CustomerOrderSummary>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _OrdersLoadingState();
                }

                if (snapshot.hasError) {
                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 120),
                        _OrdersMessageCard(
                          icon: Icons.error_outline,
                          title: 'Unable to load orders',
                          message: snapshot.error.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data ?? [];

                if (orders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 120),
                        _OrdersMessageCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'No saved orders yet',
                          message:
                              'Orders placed while signed in will appear here.',
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final tenantSlug = _resolvedTenantSlug(context);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OrderCard(
                          order: order,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsScreen(
                                  tenantSlug: tenantSlug,
                                  orderId: order.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CustomerOrderSummary order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final orderStatusLabel = _statusLabel(order.status);
    final paymentStatusRaw = order.paymentStatus?.trim();
    final paymentStatusLabel =
        (paymentStatusRaw == null || paymentStatusRaw.isEmpty)
        ? null
        : _statusLabel(paymentStatusRaw);

    final showPaymentBadge =
        paymentStatusLabel != null &&
        paymentStatusLabel.toLowerCase() != orderStatusLabel.toLowerCase();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusBadge(
                    label: orderStatusLabel,
                    kind: _orderStatusKind(order.status),
                  ),
                  if (showPaymentBadge)
                    _StatusBadge(
                      label: paymentStatusLabel!,
                      kind: _paymentStatusKind(paymentStatusRaw!),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _friendlyDate(order.placedAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  if (order.total != null)
                    Text(
                      _formatAmount(order.total!),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final _BadgeKind kind;

  const _StatusBadge({required this.label, required this.kind});

  @override
  Widget build(BuildContext context) {
    final colors = switch (kind) {
      _BadgeKind.success => (
        bg: const Color(0xFFEAF7EE),
        border: const Color(0xFFB7E4C7),
        text: const Color(0xFF166534),
      ),
      _BadgeKind.warning => (
        bg: const Color(0xFFFFF7E6),
        border: const Color(0xFFF7D9A8),
        text: const Color(0xFF92400E),
      ),
      _BadgeKind.info => (
        bg: const Color(0xFFEFF6FF),
        border: const Color(0xFFBFDBFE),
        text: const Color(0xFF1D4ED8),
      ),
      _BadgeKind.neutral => (
        bg: const Color(0xFFF3F4F6),
        border: const Color(0xFFE5E7EB),
        text: const Color(0xFF374151),
      ),
      _BadgeKind.danger => (
        bg: const Color(0xFFFEECEC),
        border: const Color(0xFFF5B5B5),
        text: const Color(0xFFB91C1C),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.text,
        ),
      ),
    );
  }
}

class _OrdersMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? child;

  const _OrdersMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF6B7280)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _OrdersLoadingState extends StatelessWidget {
  const _OrdersLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

enum _BadgeKind { success, warning, info, neutral, danger }

_BadgeKind _orderStatusKind(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'delivered':
    case 'confirmed':
    case 'paid':
      return _BadgeKind.success;
    case 'pending':
    case 'processing':
    case 'preparing':
      return _BadgeKind.warning;
    case 'shipped':
    case 'out_for_delivery':
    case 'ready_for_pickup':
      return _BadgeKind.info;
    case 'cancelled':
    case 'failed':
      return _BadgeKind.danger;
    default:
      return _BadgeKind.neutral;
  }
}

_BadgeKind _paymentStatusKind(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'succeeded':
      return _BadgeKind.success;
    case 'pending':
      return _BadgeKind.warning;
    case 'failed':
    case 'cancelled':
      return _BadgeKind.danger;
    default:
      return _BadgeKind.neutral;
  }
}

String _statusLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.trim().isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

String _friendlyDate(String? value) {
  if (value == null || value.trim().isEmpty) return 'Unknown date';

  try {
    final dt = DateTime.parse(value).toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  } catch (_) {
    return value;
  }
}

String _formatAmount(double value) {
  return value.toStringAsFixed(2);
}
