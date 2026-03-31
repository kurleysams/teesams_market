import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/seller_onboarding_provider.dart';

class SellerRejectedScreen extends StatelessWidget {
  const SellerRejectedScreen({super.key});

  String _prettyLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _openStep(BuildContext context, String key) {
    switch (key) {
      case 'business_details':
        Navigator.pushNamed(context, '/seller/onboarding/business');
        break;
      case 'store_profile':
        Navigator.pushNamed(context, '/seller/onboarding/store-profile');
        break;
      case 'operations':
        Navigator.pushNamed(context, '/seller/onboarding/operations');
        break;
      case 'documents':
        Navigator.pushNamed(context, '/seller/onboarding/documents');
        break;
      case 'catalog_setup':
        Navigator.pushNamed(context, '/seller/onboarding/catalog');
        break;
      case 'payout_setup':
        Navigator.pushNamed(context, '/seller/onboarding/payouts');
        break;
    }
  }

  List<String> _resolveIssues(dynamic status) {
    final reviewIssues = (status.reviewIssues as List<String>).toSet().toList();
    if (reviewIssues.isNotEmpty) return reviewIssues;
    return (status.missingRequirements as List<String>).toSet().toList();
  }

  String _friendlyDate(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(value).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year • $hour:$minute';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final status = provider.status;
        final issues = status == null
            ? const <String>[]
            : _resolveIssues(status);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Changes required'),
          ),
          body: status == null && provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.loadStatus,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (provider.error != null &&
                          provider.error!.trim().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.20),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Changes needed before approval',
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
                              'We reviewed your submission and found items that need to be updated before your store can be approved.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            if (status?.rejectedAt != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Rejected: ${_friendlyDate(status!.rejectedAt)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (status?.rejectionReason != null &&
                          status!.rejectionReason!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
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
                              const Text(
                                'Rejection reason',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                status.rejectionReason!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (status?.reviewNotes != null &&
                          status!.reviewNotes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
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
                              const Text(
                                'Review notes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                status.reviewNotes!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (issues.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Sections to update',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...issues.map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.edit_outlined,
                                color: Colors.orange,
                              ),
                              title: Text(
                                _prettyLabel(item),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              subtitle: const Text('Needs attention'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openStep(context, item),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/seller/onboarding',
                              (route) => false,
                            );
                          },
                          child: const Text('Back to onboarding'),
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
