import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_tracking_model.dart';
import '../state/order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String tenantSlug;
  final int orderId;

  const OrderDetailsScreen({
    super.key,
    required this.tenantSlug,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Future<OrderTrackingModel> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<OrderProvider>().fetchOrderDetails(
      tenantSlug: widget.tenantSlug,
      orderId: widget.orderId,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = context.read<OrderProvider>().fetchOrderDetails(
        tenantSlug: widget.tenantSlug,
        orderId: widget.orderId,
      );
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: FutureBuilder<OrderTrackingModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final order = snapshot.data!;

          final steps = _buildStatusSteps(order.status);

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(order: order),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Delivery Progress'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(steps.length, (index) {
                        final step = steps[index];
                        final isLast = index == steps.length - 1;

                        return _StatusStepTile(
                          title: step.label,
                          active: step.active,
                          completed: step.completed,
                          isLast: isLast,
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Items'),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(item.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((item.variant ?? '').isNotEmpty)
                            Text(item.variant!),
                          const SizedBox(height: 4),
                          Text('Qty: ${item.qty}'),
                        ],
                      ),
                      trailing: item.totalPrice != null
                          ? Text(item.totalPrice!.toStringAsFixed(2))
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Status History'),
                const SizedBox(height: 8),
                if (order.history.isEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: Text(_statusLabel(order.status)),
                      subtitle: Text(order.placedAt ?? 'No history yet'),
                    ),
                  )
                else
                  ...order.history.map(
                    (entry) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(_statusLabel(entry.status)),
                        subtitle: Text(
                          [
                            if ((entry.note ?? '').trim().isNotEmpty)
                              entry.note!.trim(),
                            if ((entry.createdAt ?? '').trim().isNotEmpty)
                              entry.createdAt!.trim(),
                          ].join('\n'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final OrderTrackingModel order;

  const _SummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(label: 'Order', value: order.orderNumber),
            _SummaryRow(label: 'Status', value: _statusLabel(order.status)),
            if (order.paymentStatus != null)
              _SummaryRow(
                label: 'Payment',
                value: _statusLabel(order.paymentStatus!),
              ),
            if (order.customerName != null)
              _SummaryRow(label: 'Customer', value: order.customerName!),
            if (order.customerPhone != null)
              _SummaryRow(label: 'Phone', value: order.customerPhone!),
            if (order.fulfilmentType != null)
              _SummaryRow(
                label: 'Fulfilment',
                value: _statusLabel(order.fulfilmentType!),
              ),
            if (order.deliveryAddress != null)
              _SummaryRow(label: 'Address', value: order.deliveryAddress!),
            if (order.currency != null && order.totalAmount != null)
              _SummaryRow(
                label: 'Total',
                value:
                    '${order.currency} ${order.totalAmount!.toStringAsFixed(2)}',
              )
            else if (order.totalAmount != null)
              _SummaryRow(
                label: 'Total',
                value: order.totalAmount!.toStringAsFixed(2),
              ),
            if (order.placedAt != null)
              _SummaryRow(label: 'Placed', value: order.placedAt!),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _StatusStepTile extends StatelessWidget {
  final String title;
  final bool active;
  final bool completed;
  final bool isLast;

  const _StatusStepTile({
    required this.title,
    required this.active,
    required this.completed,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed || active
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              completed
                  ? Icons.check_circle
                  : active
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: color,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: color.withOpacity(0.35),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusStep {
  final String label;
  final bool active;
  final bool completed;

  _StatusStep({
    required this.label,
    required this.active,
    required this.completed,
  });
}

List<_StatusStep> _buildStatusSteps(String currentStatus) {
  const all = ['pending', 'confirmed', 'processing', 'shipped', 'delivered'];

  final current = currentStatus.toLowerCase();

  if (current == 'cancelled') {
    return [
      _StatusStep(label: 'Pending', active: false, completed: true),
      _StatusStep(label: 'Confirmed', active: false, completed: false),
      _StatusStep(label: 'Processing', active: false, completed: false),
      _StatusStep(label: 'Cancelled', active: true, completed: false),
    ];
  }

  final currentIndex = all.indexOf(current);

  return List.generate(all.length, (index) {
    return _StatusStep(
      label: _statusLabel(all[index]),
      completed: currentIndex > index,
      active: currentIndex == index,
    );
  });
}

String _statusLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((e) => e.trim().isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
