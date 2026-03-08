import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/currency.dart';
import '../../../shared/widgets/summary_row.dart';
import '../../cart/state/cart_provider.dart';
import '../../payments/state/payment_provider.dart';
import '../state/order_provider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  bool payInApp = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final payments = context.read<PaymentProvider>();

    final order = await orders.createOrder(
      customerName: nameCtrl.text.trim(),
      customerPhone: phoneCtrl.text.trim().isEmpty
          ? null
          : phoneCtrl.text.trim(),
      customerEmail: emailCtrl.text.trim().isEmpty
          ? null
          : emailCtrl.text.trim(),
      fulfilmentType: 'delivery',
      deliveryAddress: addressCtrl.text.trim(),
      customerNote: null,
      cartItems: cart.items,
    );

    if (order == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error ?? 'Failed to create order')),
      );
      return;
    }

    var paid = !payInApp;

    if (payInApp) {
      paid = await payments.payForOrder(order.id);
      if (!paid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(payments.error ?? 'Payment failed')),
        );
        return;
      }
    }

    cart.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OrderSuccessScreen(orderNumber: order.orderNumber, paid: paid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.subtotal;
    final delivery = 0.0;
    final total = subtotal + delivery;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton(
          onPressed: _placeOrder,
          child: Text('Place order • ${gbp(total)}'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Customer details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneCtrl,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: addressCtrl,
            decoration: const InputDecoration(labelText: 'Delivery address'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Pay in-app'),
            subtitle: Text(
              payInApp ? 'Apple Pay / Google Pay' : 'Pay on delivery',
            ),
            value: payInApp,
            onChanged: (v) => setState(() => payInApp = v),
          ),
          const SizedBox(height: 16),
          const Text(
            'Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SummaryRow(label: 'Subtotal', value: gbp(subtotal)),
          SummaryRow(label: 'Delivery', value: gbp(delivery)),
          const Divider(),
          SummaryRow(label: 'Total', value: gbp(total), bold: true),
        ],
      ),
    );
  }
}
