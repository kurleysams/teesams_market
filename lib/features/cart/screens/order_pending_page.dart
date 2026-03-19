import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/checkout_api.dart';
import '../../cart/state/cart_provider.dart';
import '../../orders/screens/checkout_screen.dart';
//import 'checkout_screen.dart';

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
  Timer? _pollTimer;
  Timer? _timeoutTimer;

  String _paymentStatus = 'pending';
  String _orderStatus = 'pending';
  bool _loading = true;
  bool _timedOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _load());

    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (!mounted) return;
      setState(() {
        _timedOut = true;
      });
    });
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
        _pollTimer?.cancel();
        _timeoutTimer?.cancel();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(orderNumber: widget.orderNumber),
          ),
        );
        return;
      }

      if (paymentStatus == 'failed' || orderStatus == 'canceled') {
        _pollTimer?.cancel();
        _timeoutTimer?.cancel();
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
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFailed = _paymentStatus == 'failed' || _orderStatus == 'canceled';

    final title = switch (_paymentStatus) {
      'paid' => 'Payment confirmed',
      'failed' => 'Payment failed',
      _ => 'Processing order',
    };

    final message = switch (_paymentStatus) {
      'paid' => 'Your payment has been confirmed.',
      'failed' => 'We could not confirm your payment.',
      _ => 'We’re confirming your payment. This usually takes a few seconds.',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isFailed)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: CircularProgressIndicator(),
                  ),
                Text(
                  'Order ${widget.orderNumber}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('Order status: $_orderStatus'),
                Text('Payment status: $_paymentStatus'),
                if (_timedOut && !isFailed) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'This is taking longer than usual. Your payment may still complete shortly.',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                if (isFailed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      child: const Text('Try again'),
                    ),
                  )
                else if (_timedOut)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _load,
                      child: const Text('Refresh status'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentSuccessPage extends StatefulWidget {
  final String orderNumber;

  const PaymentSuccessPage({super.key, required this.orderNumber});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _cleared = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_cleared) {
      _cleared = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // context.read<CartProvider>().clear();
        Provider.of<CartProvider>(context, listen: false).clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Success')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F0FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 44,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment confirmed',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your order number is ${widget.orderNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Continue shopping'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
