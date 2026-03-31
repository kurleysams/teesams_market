import 'package:flutter/material.dart';

class AppModeEntryScreen extends StatelessWidget {
  const AppModeEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.storefront_outlined,
                    size: 64,
                    color: Color(0xFF1D4ED8),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to Teesams',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose how you want to use the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 28),

                  _ModeCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shop on Teesams',
                    subtitle:
                        'Browse stores, place orders, and track purchases.',
                    primaryLabel: 'Continue as customer',
                    onTap: () {
                      Navigator.pushNamed(context, '/customer/login');
                    },
                  ),

                  const SizedBox(height: 16),

                  _ModeCard(
                    icon: Icons.store_mall_directory_outlined,
                    title: 'Sell on Teesams',
                    subtitle:
                        'Create your seller account and start onboarding your store.',
                    primaryLabel: 'Open your store',
                    onTap: () {
                      Navigator.pushNamed(context, '/seller/register');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 34, color: const Color(0xFF1D4ED8)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(onPressed: onTap, child: Text(primaryLabel)),
          ),
        ],
      ),
    );
  }
}
