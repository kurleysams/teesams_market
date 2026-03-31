import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/state/auth_provider.dart';
import '../state/seller_auth_provider.dart';
import 'mode_switcher_button.dart';

class ModeSwitcherVisibility extends StatelessWidget {
  const ModeSwitcherVisibility({super.key});

  @override
  Widget build(BuildContext context) {
    final customerAuth = context.watch<AuthProvider>();
    final sellerAuth = context.watch<SellerAuthProvider>();

    final show = customerAuth.isAuthenticated || sellerAuth.isAuthenticated;

    if (!show) return const SizedBox.shrink();

    return const ModeSwitcherButton();
  }
}
