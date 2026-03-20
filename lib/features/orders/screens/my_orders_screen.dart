import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  late Future<List<CustomerOrderSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<OrderProvider>().fetchMyOrders(
      tenantSlug: widget.tenantSlug,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _future = context.read<OrderProvider>().fetchMyOrders(
        tenantSlug: widget.tenantSlug,
      );
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: FutureBuilder<List<CustomerOrderSummary>>(
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

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                children: const [
                  SizedBox(height: 140),
                  Center(child: Text('No orders found')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text('Order #${order.orderNumber}'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${_statusLabel(order.status)}'
                        '${order.placedAt != null ? ' • ${order.placedAt}' : ''}',
                      ),
                    ),
                    trailing: order.total != null
                        ? Text(order.total!.toStringAsFixed(2))
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsScreen(
                            tenantSlug: widget.tenantSlug,
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

  String _statusLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
