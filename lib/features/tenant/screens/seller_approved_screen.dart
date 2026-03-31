import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/seller_onboarding_provider.dart';

class SellerApprovedScreen extends StatelessWidget {
  const SellerApprovedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final status = provider.status;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Store approved'),
          ),
          body: status == null && provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.loadStatus,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your store is approved',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Your store has been approved. You can now start managing your operations.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            if (status != null &&
                                status.store.name?.trim().isNotEmpty ==
                                    true) ...[
                              const SizedBox(height: 12),
                              Text(
                                status.store.name!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/tenant-shell',
                                    (route) => false,
                                  );
                                },
                                child: const Text('Open store dashboard'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
