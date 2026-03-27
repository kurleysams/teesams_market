import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/state/auth_provider.dart';
import '../models/tenant_order_details.dart';
import '../state/tenant_mode_provider.dart';
import '../state/tenant_order_action_provider.dart';
import '../state/tenant_order_details_provider.dart';
import '../state/tenant_orders_provider.dart';
import '../state/tenant_provider.dart';
import '../utils/tenant_order_ui.dart';
import '../state/tenant_dashboard_provider.dart';

class TenantOrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const TenantOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<TenantOrderDetailsScreen> createState() =>
      _TenantOrderDetailsScreenState();
}

class _TenantOrderDetailsScreenState extends State<TenantOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _load();
    });
  }

  Future<void> _load() async {
    final storefrontTenant = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();

    if (storefrontTenant.isEmpty || auth.token == null) {
      return;
    }

    await context.read<TenantOrderDetailsProvider>().loadOrder(
      tenantSlug: storefrontTenant,
      authToken: auth.token!,
      orderId: widget.orderId,
    );
  }

  Future<void> _handleAction(TenantOrderActionSummary action) async {
    final storefrontTenant = context.read<TenantProvider>().tenant?.slug ?? '';
    final auth = context.read<AuthProvider>();
    final detailsProvider = context.read<TenantOrderDetailsProvider>();
    final actionProvider = context.read<TenantOrderActionProvider>();
    final currentOrder = detailsProvider.order;

    if (storefrontTenant.isEmpty ||
        auth.token == null ||
        currentOrder == null) {
      return;
    }

    String? reasonCode;
    String? note;

    if (action.key == 'cancel_order') {
      final result = await _showCancelSheet();
      if (result == null) return;
      reasonCode = result.$1;
      note = result.$2;
    } else {
      final confirmed = await _showConfirmDialog(action.label);
      if (confirmed != true) return;
    }

    final response = await actionProvider.submitAction(
      tenantSlug: storefrontTenant,
      authToken: auth.token!,
      orderId: currentOrder.id,
      action: action.key,
      reasonCode: reasonCode,
      note: note,
    );

    if (!mounted) return;

    if (response == null) {
      final error = actionProvider.error;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }

    await _load();

    final tenantMode = context.read<TenantModeProvider>();
    final storeId = tenantMode.selectedStoreId;

    if (storeId != null) {
      await context.read<TenantOrdersProvider>().loadOrders(
        tenantSlug: storefrontTenant,
        storeId: storeId,
        authToken: auth.token!,
      );
    }

    if (context.mounted) {
      final dashboardProvider = context.read<TenantDashboardProvider>();
      await dashboardProvider.loadDashboard(
        tenantSlug: storefrontTenant,
        authToken: auth.token!,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(response.message)));
  }

  Future<bool?> _showConfirmDialog(String label) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: const Text('Are you sure you want to continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<(String, String?)?> _showCancelSheet() async {
    final reasonNotifier = ValueNotifier<String>('out_of_stock');
    final noteController = TextEditingController();

    final result = await showModalBottomSheet<(String, String?)>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: reasonNotifier.value,
                    items: const [
                      DropdownMenuItem(
                        value: 'out_of_stock',
                        child: Text('Out of stock'),
                      ),
                      DropdownMenuItem(
                        value: 'store_closed',
                        child: Text('Store closed'),
                      ),
                      DropdownMenuItem(
                        value: 'unable_to_fulfill',
                        child: Text('Unable to fulfill'),
                      ),
                      DropdownMenuItem(
                        value: 'customer_request',
                        child: Text('Customer request'),
                      ),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          reasonNotifier.value = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context, (
                          reasonNotifier.value,
                          noteController.text.trim().isEmpty
                              ? null
                              : noteController.text.trim(),
                        ));
                      },
                      child: const Text('Confirm Cancellation'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    noteController.dispose();
    reasonNotifier.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final detailsProvider = context.watch<TenantOrderDetailsProvider>();
    final actionProvider = context.watch<TenantOrderActionProvider>();
    final order = detailsProvider.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(order == null ? 'Order Details' : '#${order.orderNumber}'),
      ),
      body: Builder(
        builder: (context) {
          if (detailsProvider.loading && order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (detailsProvider.error != null &&
              detailsProvider.error!.isNotEmpty &&
              order == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 52),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(detailsProvider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _OrderHeaderCard(order: order),
                      const SizedBox(height: 12),
                      _CustomerCard(order: order),
                      const SizedBox(height: 12),
                      _ItemsCard(order: order),
                      const SizedBox(height: 12),
                      _PaymentCard(order: order),
                      const SizedBox(height: 12),
                      if (order.notes.customerNote.trim().isNotEmpty)
                        _NotesCard(order: order),
                      if (order.notes.customerNote.trim().isNotEmpty)
                        const SizedBox(height: 12),
                      _HistoryCard(order: order),
                    ],
                  ),
                ),
              ),
              _ActionBar(
                loading: actionProvider.loading,
                actions: order.allowedActions,
                onTap: _handleAction,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderHeaderCard extends StatelessWidget {
  final TenantOrderDetails order;

  const _OrderHeaderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${order.orderNumber}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(text: order.statusLabel),
                _Tag(text: order.orderType.toUpperCase()),
              ],
            ),
            const SizedBox(height: 12),
            Text('Created: ${order.timing.createdAt}'),
            if ((order.timing.scheduledFor ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Scheduled: ${order.timing.scheduledFor}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final TenantOrderDetails order;

  const _CustomerCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isDelivery = order.delivery.fulfilmentType == 'delivery';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(order.customer.name),
            if (order.customer.phone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(order.customer.phone),
              ),
            if (order.customer.email.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(order.customer.email),
              ),
            if (isDelivery && order.delivery.deliveryAddress.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Address: ${order.delivery.deliveryAddress}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final TenantOrderDetails order;

  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.quantity} × ${item.name}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('£${item.lineTotal.toStringAsFixed(2)}'),
                    if (item.notes.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Note: ${item.notes}'),
                      ),
                    if (item.modifiers.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: item.modifiers.map((modifier) {
                            return Text(
                              '- ${modifier.name} '
                              '(${modifier.quantity})',
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final TenantOrderDetails order;

  const _PaymentCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _RowLine(
              label: 'Status',
              value: order.payment.status.toUpperCase(),
            ),
            _RowLine(
              label: 'Method',
              value: order.payment.method.isEmpty ? '-' : order.payment.method,
            ),
            _RowLine(
              label: 'Subtotal',
              value:
                  '${order.totals.currency} ${order.totals.subtotal.toStringAsFixed(2)}',
            ),
            _RowLine(
              label: 'Delivery Fee',
              value:
                  '${order.totals.currency} ${order.totals.deliveryFee.toStringAsFixed(2)}',
            ),
            _RowLine(
              label: 'Discount',
              value:
                  '${order.totals.currency} ${order.totals.discountTotal.toStringAsFixed(2)}',
            ),
            const Divider(),
            _RowLine(
              label: 'Total',
              value:
                  '${order.totals.currency} ${order.totals.total.toStringAsFixed(2)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final TenantOrderDetails order;

  const _NotesCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Note',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(order.notes.customerNote),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TenantOrderDetails order;

  const _HistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Timeline', style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 10),
              Text('No history available yet'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...List.generate(order.history.length, (index) {
              final item = order.history[index];
              final isLast = index == order.history.length - 1;
              final statusLabel = TenantOrderUi.timelineStatusLabel(
                item.toStatus,
                order.orderType,
              );
              final subtitle = TenantOrderUi.historySubtitle(item);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 42,
                          color: const Color(0xFFE5E7EB),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusLabel,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if ((subtitle ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                subtitle!,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if ((item.changedByName ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'By ${item.changedByName}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              item.createdAt,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if ((item.note ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(item.note!),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool loading;
  final List<TenantOrderActionSummary> actions;
  final ValueChanged<TenantOrderActionSummary> onTap;

  const _ActionBar({
    required this.loading,
    required this.actions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x14000000),
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: actions.map((action) {
            final isDestructive = action.destructive;
            return ElevatedButton(
              onPressed: loading ? null : () => onTap(action),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive
                    ? Colors.red
                    : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(action.label),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RowLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _RowLine({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
