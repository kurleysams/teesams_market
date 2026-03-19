import 'dart:async';
import 'package:flutter/material.dart';

import '../data/checkout_api.dart';

class OrderPendingPage extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final CheckoutApi api;

  const OrderPendingPage({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.api,
  });

  @override
  State<OrderPendingPage> createState() => _OrderPendingPageState();
}

class _OrderPendingPageState extends State<OrderPendingPage> {
  Timer? _timer;
  String _paymentStatus = 'pending';
  String _orderStatus = 'pending';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  Future<void> _load() async {
    try {
      final json = await widget.api.fetchOrder(widget.orderId);

      final order = Map<String, dynamic>.from(
        (json['order'] ?? json['data'] ?? json) as Map,
      );

      final paymentStatus = (order['payment_status'] ?? 'pending').toString();
      final orderStatus = (order['status'] ?? 'pending').toString();

      if (!mounted) return;

      setState(() {
        _paymentStatus = paymentStatus;
        _orderStatus = orderStatus;
        _loading = false;
        _error = null;
      });

      if (paymentStatus == 'paid') {
        _timer?.cancel();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(orderNumber: widget.orderNumber),
          ),
        );
      }

      if (paymentStatus == 'failed') {
        _timer?.cancel();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to refresh order status.';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = switch (_paymentStatus) {
      'paid' => 'Payment confirmed.',
      'failed' => 'Payment failed.',
      _ => 'We’re confirming your payment…',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Processing order')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Order ${widget.orderNumber}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Order status: $_orderStatus'),
              Text('Payment status: $_paymentStatus'),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  final String orderNumber;

  const PaymentSuccessPage({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Success')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Payment confirmed for order $orderNumber',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
