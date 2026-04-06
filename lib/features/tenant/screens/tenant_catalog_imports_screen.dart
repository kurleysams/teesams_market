import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/catalog_import_models.dart';
import '../state/tenant_catalog_imports_provider.dart';
import '../state/tenant_mode_provider.dart';

class TenantCatalogImportsScreen extends StatefulWidget {
  const TenantCatalogImportsScreen({super.key});

  @override
  State<TenantCatalogImportsScreen> createState() =>
      _TenantCatalogImportsScreenState();
}

class _TenantCatalogImportsScreenState
    extends State<TenantCatalogImportsScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  Future<File?> _pickCatalogFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx', 'xls'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      return null;
    }

    return File(path);
  }

  Future<String?> _pickSavePath({
    required String dialogTitle,
    required String fileName,
  }) async {
    return FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '—';

    try {
      final parsed = DateTime.parse(value).toLocal();
      return _dateFormat.format(parsed);
    } catch (_) {
      return value;
    }
  }

  Future<void> _showValidationSheet(
    BuildContext context, {
    required CatalogImportValidationResult result,
    required Future<void> Function() onConfirm,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.78,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.mode == 'bulk-update'
                        ? 'Bulk update validation'
                        : 'Catalog import validation',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.originalFilename ?? 'Uploaded file',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SummaryCard(summary: result.summary),
                  const SizedBox(height: 14),
                  if (result.warnings.isNotEmpty) ...[
                    const Text(
                      'Warnings',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: result.warnings
                            .take(5)
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Row ${item['row'] ?? '-'}: ${item['message'] ?? 'Warning'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const Text(
                    'Errors',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: result.errors.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: const Text(
                              'No validation errors found. You can confirm this upload.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF166534),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: result.errors.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = result.errors[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Row ${item['row'] ?? '-'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF991B1B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['message']?.toString() ??
                                          'Validation error',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7F1D1D),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: result.canConfirm
                              ? () async {
                                  await onConfirm();
                                  if (!mounted) return;
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Import confirmed successfully.',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showHistoryDetailSheet(
    BuildContext context,
    CatalogImportHistoryDetail detail,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.originalFilename ?? 'Import details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HistoryChip(label: detail.type),
                      _HistoryChip(label: detail.mode),
                      _HistoryChip(
                        label: detail.status,
                        backgroundColor: _statusBackground(detail.status),
                        textColor: _statusText(detail.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Created: ${_formatDate(detail.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Validated: ${_formatDate(detail.validatedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Completed: ${_formatDate(detail.completedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SummaryCard(summary: detail.summary),
                  const SizedBox(height: 16),
                  if (detail.warnings.isNotEmpty) ...[
                    const Text(
                      'Warnings',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...detail.warnings
                        .take(5)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Row ${item['row'] ?? '-'}: ${item['message'] ?? 'Warning'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 12),
                  ],
                  const Text(
                    'Errors',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: detail.errors.isEmpty
                        ? const Center(
                            child: Text(
                              'No errors recorded for this import.',
                              style: TextStyle(color: Color(0xFF6B7280)),
                            ),
                          )
                        : ListView.separated(
                            itemCount: detail.errors.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = detail.errors[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Text(
                                  'Row ${item['row'] ?? '-'}: ${item['message'] ?? 'Error'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF7F1D1D),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final path = await _pickSavePath(
                            dialogTitle: 'Save issues CSV',
                            fileName: 'catalog-import-${detail.id}-issues.csv',
                          );

                          if (path == null || !mounted) return;

                          await context
                              .read<TenantCatalogImportsProvider>()
                              .downloadIssuesCsv(
                                importId: detail.id,
                                savePath: path,
                              );

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Issues CSV saved to $path'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Issues CSV'),
                      ),
                      FilledButton.icon(
                        onPressed: detail.canCancel
                            ? () async {
                                await context
                                    .read<TenantCatalogImportsProvider>()
                                    .cancelImport(detail.id);

                                if (!mounted) return;
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Import cancelled'),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            (detail.status == 'failed' ||
                                detail.status == 'cancelled')
                            ? () async {
                                final file = await _pickCatalogFile();
                                if (file == null || !mounted) return;

                                await context
                                    .read<TenantCatalogImportsProvider>()
                                    .revalidateImport(
                                      file: file,
                                      replacesImportId: detail.id,
                                      type: detail.type,
                                      mode: detail.mode,
                                    );

                                if (!mounted) return;

                                final result = context
                                    .read<TenantCatalogImportsProvider>()
                                    .lastValidation;

                                Navigator.of(context).pop();

                                if (result != null) {
                                  await _showValidationSheet(
                                    context,
                                    result: result,
                                    onConfirm: result.mode == 'bulk-update'
                                        ? context
                                              .read<
                                                TenantCatalogImportsProvider
                                              >()
                                              .confirmBulkUpdate
                                        : context
                                              .read<
                                                TenantCatalogImportsProvider
                                              >()
                                              .confirmFullImport,
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.refresh_outlined),
                        label: const Text('Revalidate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFullImportUpload(BuildContext context) async {
    final file = await _pickCatalogFile();
    if (file == null || !mounted) return;

    final provider = context.read<TenantCatalogImportsProvider>();
    await provider.validateFullImport(file);

    if (!mounted) return;

    final result = provider.lastValidation;
    if (result == null) return;

    await _showValidationSheet(
      context,
      result: result,
      onConfirm: provider.confirmFullImport,
    );
  }

  Future<void> _handleBulkUpdateUpload(BuildContext context) async {
    final file = await _pickCatalogFile();
    if (file == null || !mounted) return;

    final provider = context.read<TenantCatalogImportsProvider>();
    await provider.validateBulkUpdate(file);

    if (!mounted) return;

    final result = provider.lastValidation;
    if (result == null) return;

    await _showValidationSheet(
      context,
      result: result,
      onConfirm: provider.confirmBulkUpdate,
    );
  }

  Future<void> _handleDownloadTemplate(BuildContext context) async {
    final path = await _pickSavePath(
      dialogTitle: 'Save full import template',
      fileName: 'catalog-import-template.csv',
    );

    if (path == null || !mounted) return;

    await context.read<TenantCatalogImportsProvider>().downloadTemplate(
      mode: 'full',
      savePath: path,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Template saved to $path')));
  }

  Future<void> _handleExportCurrentCatalog(BuildContext context) async {
    final path = await _pickSavePath(
      dialogTitle: 'Save bulk update export',
      fileName: 'catalog-export-bulk-update.csv',
    );

    if (path == null || !mounted) return;

    await context.read<TenantCatalogImportsProvider>().downloadExport(
      mode: 'bulk-update',
      savePath: path,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Catalog export saved to $path')));
  }

  Future<void> _handleHistoryTap(
    BuildContext context,
    CatalogImportHistoryItem item,
  ) async {
    final provider = context.read<TenantCatalogImportsProvider>();
    await provider.loadHistoryDetail(item.id);

    if (!mounted) return;

    final detail = provider.selectedHistoryDetail;
    if (detail == null) return;

    await _showHistoryDetailSheet(context, detail);
    if (!mounted) return;
    provider.clearSelectedHistoryDetail();
  }

  @override
  Widget build(BuildContext context) {
    final tenantMode = context.watch<TenantModeProvider>();
    final importsProvider = context.watch<TenantCatalogImportsProvider>();

    final canManageAvailability = tenantMode.canManageProductAvailability;
    final isBusy = importsProvider.isLoading;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<TenantCatalogImportsProvider>().loadHistory(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _CatalogHeroCard(),
          const SizedBox(height: 16),
          if (importsProvider.errorMessage != null) ...[
            _InlineErrorCard(message: importsProvider.errorMessage!),
            const SizedBox(height: 16),
          ],
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
            primaryLabel: isBusy ? 'Please wait...' : 'Upload initial catalog',
            secondaryLabel: 'Download template',
            enabled: canManageAvailability && !isBusy,
            onPrimaryTap: () => _handleFullImportUpload(context),
            onSecondaryTap: () => _handleDownloadTemplate(context),
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
            primaryLabel: isBusy ? 'Please wait...' : 'Upload update file',
            secondaryLabel: 'Export current catalog',
            enabled: canManageAvailability && !isBusy,
            onPrimaryTap: () => _handleBulkUpdateUpload(context),
            onSecondaryTap: () => _handleExportCurrentCatalog(context),
          ),
          const SizedBox(height: 16),
          _HistoryFilters(
            selectedType: importsProvider.selectedType,
            selectedStatus: importsProvider.selectedStatus,
            onSelectType: (value) {
              context.read<TenantCatalogImportsProvider>().setTypeFilter(value);
            },
            onSelectStatus: (value) {
              context.read<TenantCatalogImportsProvider>().setStatusFilter(
                value,
              );
            },
            onClear: () {
              context.read<TenantCatalogImportsProvider>().clearFilters();
            },
          ),
          const SizedBox(height: 16),
          const _BestPracticeCard(),
          const SizedBox(height: 16),
          _ImportHistoryCard(
            history: importsProvider.history,
            isLoading: isBusy,
            onTapItem: (item) => _handleHistoryTap(context, item),
            formatDate: _formatDate,
          ),
        ],
      ),
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

class _HistoryFilters extends StatelessWidget {
  final String? selectedType;
  final String? selectedStatus;
  final ValueChanged<String?> onSelectType;
  final ValueChanged<String?> onSelectStatus;
  final VoidCallback onClear;

  const _HistoryFilters({
    required this.selectedType,
    required this.selectedStatus,
    required this.onSelectType,
    required this.onSelectStatus,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: selectedType == null && selectedStatus == null,
          onSelected: (_) => onClear(),
        ),
        FilterChip(
          label: const Text('Full imports'),
          selected: selectedType == 'catalog_import',
          onSelected: (_) => onSelectType(
            selectedType == 'catalog_import' ? null : 'catalog_import',
          ),
        ),
        FilterChip(
          label: const Text('Bulk updates'),
          selected: selectedType == 'bulk_update',
          onSelected: (_) => onSelectType(
            selectedType == 'bulk_update' ? null : 'bulk_update',
          ),
        ),
        FilterChip(
          label: const Text('Validated'),
          selected: selectedStatus == 'validated',
          onSelected: (_) => onSelectStatus(
            selectedStatus == 'validated' ? null : 'validated',
          ),
        ),
        FilterChip(
          label: const Text('Completed'),
          selected: selectedStatus == 'completed',
          onSelected: (_) => onSelectStatus(
            selectedStatus == 'completed' ? null : 'completed',
          ),
        ),
        FilterChip(
          label: const Text('Failed'),
          selected: selectedStatus == 'failed',
          onSelected: (_) =>
              onSelectStatus(selectedStatus == 'failed' ? null : 'failed'),
        ),
      ],
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

class _SummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final rows = summary.entries.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  final String message;

  const _InlineErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFEF2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFECACA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF991B1B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ImportHistoryCard extends StatelessWidget {
  final List<CatalogImportHistoryItem> history;
  final bool isLoading;
  final ValueChanged<CatalogImportHistoryItem> onTapItem;
  final String Function(String?) formatDate;

  const _ImportHistoryCard({
    required this.history,
    required this.isLoading,
    required this.onTapItem,
    required this.formatDate,
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
            if (isLoading && history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (history.isEmpty)
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
              )
            else
              ...history.map(
                (item) => InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onTapItem(item),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.originalFilename ?? 'Catalog import',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _HistoryChip(label: item.type),
                            _HistoryChip(label: item.mode),
                            _HistoryChip(
                              label: item.status,
                              backgroundColor: _statusBackground(item.status),
                              textColor: _statusText(item.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Created: ${formatDate(item.createdAt)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Processed: ${item.summary['valid_rows'] ?? item.summary['variants_updated'] ?? item.summary['total_rows'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const _HistoryChip({
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor ?? const Color(0xFF374151),
        ),
      ),
    );
  }
}

Color _statusBackground(String status) {
  switch (status) {
    case 'completed':
      return const Color(0xFFDCFCE7);
    case 'validated':
      return const Color(0xFFDBEAFE);
    case 'failed':
      return const Color(0xFFFEE2E2);
    case 'cancelled':
      return const Color(0xFFE5E7EB);
    case 'processing':
      return const Color(0xFFFEF3C7);
    default:
      return const Color(0xFFF3F4F6);
  }
}

Color _statusText(String status) {
  switch (status) {
    case 'completed':
      return const Color(0xFF166534);
    case 'validated':
      return const Color(0xFF1D4ED8);
    case 'failed':
      return const Color(0xFFB91C1C);
    case 'cancelled':
      return const Color(0xFF4B5563);
    case 'processing':
      return const Color(0xFF92400E);
    default:
      return const Color(0xFF374151);
  }
}
