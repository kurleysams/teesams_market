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
import '../utils/tenant_order_ui.dart';
import '../widgets/tenant_order_action_helper.dart';
import 'tenant_order_details_screen.dart';

class TenantOrdersScreen extends StatefulWidget {
  const TenantOrdersScreen({super.key});

  @override
  State<TenantOrdersScreen> createState() => _TenantOrdersScreenState();
}

class _TenantOrdersScreenState extends State<TenantOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didLoad) return;
    _didLoad = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final storefrontTenant = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();
    final tenantMode = context.read<TenantModeProvider>();

    final storeId = tenantMode.selectedStoreId;
    final token = auth.token;

    if (storefrontTenant.isEmpty || storeId == null || token == null) {
      return;
    }

    await context.read<TenantOrdersProvider>().loadOrders(
      tenantSlug: storefrontTenant,
      storeId: storeId,
      authToken: token,
    );
  }

  Future<void> _handleQuickAction(
    TenantOrderSummary order,
    TenantOrderActionSummary action,
  ) async {
    final input = await TenantOrderActionHelper.collectActionInput(
      context: context,
      action: action,
    );

    if (input == null || !mounted) return;

    final storefrontTenant = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (storefrontTenant.isEmpty || token == null) return;

    final actionProvider = TenantOrderActionProvider();

    final result = await actionProvider.submitAction(
      tenantSlug: storefrontTenant,
      authToken: token,
      orderId: order.id,
      action: input.action,
      reasonCode: input.reasonCode,
      note: input.note,
    );

    if (!mounted) return;

    if (result == null) {
      if ((actionProvider.error ?? '').isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(actionProvider.error!)));
      }
      return;
    }

    await _loadOrders();

    if (!mounted) return;

    await context.read<TenantDashboardProvider>().loadDashboard(
      tenantSlug: storefrontTenant,
      authToken: token,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _openOrderDetails(TenantOrderSummary order) async {
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
    await _loadOrders();

    if (!mounted) return;

    final storefrontTenant = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();

    if (storefrontTenant.isNotEmpty && auth.token != null) {
      await context.read<TenantDashboardProvider>().loadDashboard(
        tenantSlug: storefrontTenant,
        authToken: auth.token!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantMode = context.watch<TenantModeProvider>();
    final ordersProvider = context.watch<TenantOrdersProvider>();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tenantMode.selectedStoreName ?? 'Store Orders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search order number or customer',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () async {
                            _searchController.clear();
                            context.read<TenantOrdersProvider>().setSearch('');
                            await _loadOrders();
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) {
                  setState(() {});
                },
                onSubmitted: (value) async {
                  context.read<TenantOrdersProvider>().setSearch(value);
                  await _loadOrders();
                },
              ),
              const SizedBox(height: 12),
              _LifecycleTabs(
                current: ordersProvider.filter.lifecycle,
                onChanged: (value) async {
                  context.read<TenantOrdersProvider>().setLifecycle(value);
                  await _loadOrders();
                },
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChipButton(
                      label: 'All',
                      selected: ordersProvider.filter.status == null,
                      onTap: () async {
                        context.read<TenantOrdersProvider>().setStatus(null);
                        await _loadOrders();
                      },
                    ),
                    _FilterChipButton(
                      label: 'Pending',
                      selected: ordersProvider.filter.status == 'pending',
                      onTap: () async {
                        context.read<TenantOrdersProvider>().setStatus(
                          'pending',
                        );
                        await _loadOrders();
                      },
                    ),
                    _FilterChipButton(
                      label: 'Confirmed',
                      selected: ordersProvider.filter.status == 'confirmed',
                      onTap: () async {
                        context.read<TenantOrdersProvider>().setStatus(
                          'confirmed',
                        );
                        await _loadOrders();
                      },
                    ),
                    _FilterChipButton(
                      label: 'Preparing',
                      selected: ordersProvider.filter.status == 'preparing',
                      onTap: () async {
                        context.read<TenantOrdersProvider>().setStatus(
                          'preparing',
                        );
                        await _loadOrders();
                      },
                    ),
                    _FilterChipButton(
                      label: 'Pickup',
                      selected: ordersProvider.filter.orderType == 'pickup',
                      onTap: () async {
                        final provider = context.read<TenantOrdersProvider>();
                        provider.setOrderType(
                          provider.filter.orderType == 'pickup'
                              ? null
                              : 'pickup',
                        );
                        await _loadOrders();
                      },
                    ),
                    _FilterChipButton(
                      label: 'Delivery',
                      selected: ordersProvider.filter.orderType == 'delivery',
                      onTap: () async {
                        final provider = context.read<TenantOrdersProvider>();
                        provider.setOrderType(
                          provider.filter.orderType == 'delivery'
                              ? null
                              : 'delivery',
                        );
                        await _loadOrders();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrders,
            child: Builder(
              builder: (context) {
                if (ordersProvider.loading && ordersProvider.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ordersProvider.error != null &&
                    ordersProvider.error!.trim().isNotEmpty &&
                    ordersProvider.orders.isEmpty) {
                  return ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 52,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Unable to load orders',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ordersProvider.error!,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: _loadOrders,
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (ordersProvider.orders.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No orders found')),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordersProvider.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = ordersProvider.orders[index];
                    return _TenantOrderCard(
                      order: order,
                      onTap: () => _openOrderDetails(order),
                      onQuickAction: (action) =>
                          _handleQuickAction(order, action),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LifecycleTabs extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _LifecycleTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('active', 'Active'),
      ('completed', 'Completed'),
      ('cancelled', 'Cancelled'),
    ];

    return Row(
      children: items.map((item) {
        final selected = current == item.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: SizedBox(
                width: double.infinity,
                child: Text(item.$2, textAlign: TextAlign.center),
              ),
              selected: selected,
              onSelected: (_) => onChanged(item.$1),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _TenantOrderCard extends StatelessWidget {
  final TenantOrderSummary order;
  final VoidCallback onTap;
  final ValueChanged<TenantOrderActionSummary> onQuickAction;

  const _TenantOrderCard({
    required this.order,
    required this.onTap,
    required this.onQuickAction,
  });

  Color _statusColor(BuildContext context) {
    switch (order.status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.deepPurple;
      case 'ready_for_pickup':
      case 'out_for_delivery':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);
    final quickActions = order.allowedActions.take(2).toList();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      TenantOrderUi.summaryStatusLabel(order),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.customerName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetaPill(label: order.orderType.toUpperCase()),
                  _MetaPill(label: '${order.itemsCount} items'),
                  _MetaPill(label: '£${order.total.toStringAsFixed(2)}'),
                  _MetaPill(label: order.paymentStatus.toUpperCase()),
                  if (order.hasNote) const _MetaPill(label: 'NOTE'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Created: ${order.createdAt}',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              if (order.scheduledFor != null &&
                  order.scheduledFor!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Scheduled: ${order.scheduledFor}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ),
              if (quickActions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickActions.map((action) {
                    return OutlinedButton(
                      onPressed: () => onQuickAction(action),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: action.destructive ? Colors.red : null,
                      ),
                      child: Text(TenantOrderUi.actionLabel(action.key)),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;

  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
