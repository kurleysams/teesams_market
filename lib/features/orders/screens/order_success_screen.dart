import 'package:flutter/material.dart';

import '../../catalog/screens/catalog_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final bool paid;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order placed')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 72),
              const SizedBox(height: 10),
              const Text(
                'Success!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text('Order Number: $orderNumber'),
              const SizedBox(height: 6),
              Text(
                paid ? 'Payment completed' : 'Awaiting payment / fulfilment',
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogScreen()),
                  (_) => false,
                ),
                child: const Text('Back to store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
