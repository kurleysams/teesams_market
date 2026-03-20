import 'package:flutter/material.dart';

import 'my_orders_screen.dart';

class TrackOrderScreen extends StatelessWidget {
  final String tenantSlug;
  final String? initialOrderNumber;

  const TrackOrderScreen({
    super.key,
    required this.tenantSlug,
    this.initialOrderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return MyOrdersScreen(tenantSlug: tenantSlug);
  }
}
