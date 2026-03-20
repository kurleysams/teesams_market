import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
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
  Future<OrderTrackingModel>? _future;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _future = context.read<OrderProvider>().fetchOrderDetails(
          tenantSlug: widget.tenantSlug,
          orderId: widget.orderId,
        );
      });
    });
  }

  Future<void> _reload() async {
    final future = context.read<OrderProvider>().fetchOrderDetails(
      tenantSlug: widget.tenantSlug,
      orderId: widget.orderId,
    );

    setState(() {
      _future = future;
    });

    await future;
  }

  String? _normalizeUrl(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final origin = AppConfig.baseUrl.replaceFirst('/api', '');
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }

    return '$origin/$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;

    if (future == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Order Details')),
      body: FutureBuilder<OrderTrackingModel>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  _MessageCard(
                    icon: Icons.error_outline,
                    title: 'Unable to load order',
                    message: snapshot.error.toString().replaceFirst(
                      'Exception: ',
                      '',
                    ),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!;
          final steps = _buildStatusSteps(order.status);

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                _SummaryCard(order: order),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Delivery Progress'),
                const SizedBox(height: 8),
                _SectionCard(
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
                const SizedBox(height: 16),
                _SectionTitle(title: 'Items'),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ItemCard(
                      item: item,
                      imageUrl: _normalizeUrl(item.imageUrl),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _SectionTitle(title: 'Status History'),
                const SizedBox(height: 8),
                if (order.history.isEmpty)
                  const _MessageCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'No status history yet',
                    message:
                        'Updates will appear here as your order progresses.',
                  )
                else
                  ...order.history.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HistoryCard(entry: entry),
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
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${order.orderNumber}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusBadge(
                label: _statusLabel(order.status),
                kind: _orderStatusKind(order.status),
              ),
              if (order.paymentStatus != null)
                _StatusBadge(
                  label: _statusLabel(order.paymentStatus!),
                  kind: _paymentStatusKind(order.paymentStatus!),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(label: 'Customer', value: order.customerName),
          _SummaryRow(label: 'Phone', value: order.customerPhone),
          _SummaryRow(
            label: 'Fulfilment',
            value: order.fulfilmentType == null
                ? null
                : _statusLabel(order.fulfilmentType!),
          ),
          _SummaryRow(label: 'Address', value: order.deliveryAddress),
          _SummaryRow(
            label: 'Total',
            value: order.totalAmount == null
                ? null
                : order.currency != null && order.currency!.trim().isNotEmpty
                ? '${order.currency} ${order.totalAmount!.toStringAsFixed(2)}'
                : order.totalAmount!.toStringAsFixed(2),
          ),
          _SummaryRow(label: 'Placed', value: _friendlyDate(order.placedAt)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String? value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style: const TextStyle(color: Color(0xFF111827)),
            ),
          ),
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
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: const Color(0xFF111827),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ItemCard extends StatelessWidget {
  final dynamic item;
  final String? imageUrl;

  const _ItemCard({required this.item, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumb(imageUrl: imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                if ((item.variant ?? '').toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.variant!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Qty: ${item.qty}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (item.totalPrice != null)
            Text(
              item.totalPrice!.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String? imageUrl;

  const _ProductThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl!,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder();
          },
        ),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Icon(Icons.fastfood_outlined, color: Color(0xFF6B7280)),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final note = (entry.note ?? '').toString().trim();
    final createdAt = _friendlyDate(entry.createdAt);

    return _SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF1D4ED8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel(entry.status),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    createdAt,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
                height: 38,
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
                fontSize: 15,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
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
        ],
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

enum _BadgeKind { success, warning, info, neutral, danger }

_BadgeKind _orderStatusKind(String status) {
  switch (status.toLowerCase()) {
    case 'delivered':
    case 'confirmed':
      return _BadgeKind.success;
    case 'pending':
    case 'processing':
      return _BadgeKind.warning;
    case 'shipped':
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

String _friendlyDate(String? value) {
  if (value == null || value.trim().isEmpty) return '';

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
