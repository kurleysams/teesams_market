import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tenant_mode_provider.dart';

class TenantCatalogImportsScreen extends StatelessWidget {
  const TenantCatalogImportsScreen({super.key});

  Future<void> _showComingSoon(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantMode = context.watch<TenantModeProvider>();
    final canManageAvailability = tenantMode.canManageProductAvailability;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _CatalogHeroCard(),
        const SizedBox(height: 16),
        _CatalogActionCard(
          icon: Icons.cloud_upload_outlined,
          accent: const Color(0xFF1D4ED8),
          title: 'Import catalog',
          subtitle:
              'Best for first-time setup. Upload products, variants, pricing, stock, and availability in bulk.',
          bullets: const [
            'Use when onboarding a new seller',
            'Create categories, products, and variants in one flow',
            'Preview rows before applying changes',
            'Ideal for Excel or supplier spreadsheets',
          ],
          primaryLabel: 'Upload initial catalog',
          secondaryLabel: 'Download template',
          enabled: canManageAvailability,
          onPrimaryTap: () => _showComingSoon(
            context,
            title: 'Import catalog',
            message:
                'This should open the first-time catalog import flow with template download, file validation, preview, and confirm import.',
          ),
          onSecondaryTap: () => _showComingSoon(
            context,
            title: 'Template download',
            message:
                'This should download the full catalog import template for new sellers.',
          ),
        ),
        const SizedBox(height: 16),
        _CatalogActionCard(
          icon: Icons.price_change_outlined,
          accent: const Color(0xFF0F766E),
          title: 'Bulk update prices & stock',
          subtitle:
              'Best for live stores. Update existing items by SKU without recreating products.',
          bullets: const [
            'Use for price changes, stock updates, and availability changes',
            'Match existing rows by SKU',
            'Safer than full import for live stores',
            'Good for weekly or daily operational updates',
          ],
          primaryLabel: 'Upload update file',
          secondaryLabel: 'Export current catalog',
          enabled: canManageAvailability,
          onPrimaryTap: () => _showComingSoon(
            context,
            title: 'Bulk update',
            message:
                'This should open a lighter bulk update flow for price, stock, sale price, and availability updates.',
          ),
          onSecondaryTap: () => _showComingSoon(
            context,
            title: 'Export current catalog',
            message:
                'This should export the current catalog so sellers can edit it and re-upload updates.',
          ),
        ),
        const SizedBox(height: 16),
        const _BestPracticeCard(),
        const SizedBox(height: 16),
        const _ImportHistoryCard(),
      ],
    );
  }
}

class _CatalogHeroCard extends StatelessWidget {
  const _CatalogHeroCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catalog uploads',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Manage large product changes safely. Use full import for first-time setup and bulk update for live catalog changes.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogActionCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final String primaryLabel;
  final String secondaryLabel;
  final bool enabled;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _CatalogActionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.enabled,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 14),
            ...bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(
                        Icons.circle,
                        size: 7,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: enabled ? onPrimaryTap : null,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(primaryLabel),
                ),
                OutlinedButton.icon(
                  onPressed: enabled ? onSecondaryTap : null,
                  icon: const Icon(Icons.download_outlined),
                  label: Text(secondaryLabel),
                ),
              ],
            ),
            if (!enabled) ...[
              const SizedBox(height: 12),
              const Text(
                'You do not currently have permission to manage catalog availability.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BestPracticeCard extends StatelessWidget {
  const _BestPracticeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended process',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 12),
            _ProcessRow(
              number: '1',
              title: 'Download template or export current catalog',
              subtitle: 'Start from a known file structure.',
            ),
            _ProcessRow(
              number: '2',
              title: 'Upload file',
              subtitle: 'CSV or XLSX should be accepted.',
            ),
            _ProcessRow(
              number: '3',
              title: 'Validate and preview',
              subtitle: 'Show errors before saving anything.',
            ),
            _ProcessRow(
              number: '4',
              title: 'Confirm import',
              subtitle: 'Apply only after seller reviews the changes.',
            ),
            _ProcessRow(
              number: '5',
              title: 'Save import report',
              subtitle: 'Show updated, skipped, and failed rows.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessRow extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _ProcessRow({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportHistoryCard extends StatelessWidget {
  const _ImportHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import history',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Keep a history of catalog imports and bulk updates so sellers can review what changed and when.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                'No imports yet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
