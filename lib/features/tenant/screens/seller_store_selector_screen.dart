import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tenant_mode_provider.dart';

class SellerStoreSelectorScreen extends StatelessWidget {
  const SellerStoreSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TenantModeProvider>(
      builder: (context, tenantMode, _) {
        final memberships = tenantMode.bootstrap?.tenantMemberships ?? const [];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('Select store'),
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: memberships.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.store_mall_directory_outlined,
                            size: 42,
                            color: Color(0xFF6B7280),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No store access found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This seller account is not linked to any store yet.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: memberships.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final membership = memberships[index];

                    final rawRole = membership.role?.trim() ?? '';
                    final role = rawRole.isEmpty
                        ? 'Store access'
                        : rawRole
                              .replaceAll('_', ' ')
                              .split(' ')
                              .map(
                                (e) => e.isEmpty
                                    ? e
                                    : e[0].toUpperCase() +
                                          e.substring(1).toLowerCase(),
                              )
                              .join(' ');

                    final storeName =
                        membership.storeName?.trim().isNotEmpty == true
                        ? membership.storeName!.trim()
                        : membership.tenantName?.trim().isNotEmpty == true
                        ? membership.tenantName!.trim()
                        : 'Store';

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        await tenantMode.setSelectedMembership(membership);
                        await tenantMode.setSelectedMode('tenant');

                        if (!context.mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/seller/portal',
                          (_) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storeName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
