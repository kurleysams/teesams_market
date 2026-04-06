import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_client.dart';
import '../data/admin_tenant_api.dart';
import '../widgets/admin_tenant_review_card.dart';

class AdminTenantReviewScreen extends StatefulWidget {
  final int tenantId;
  final String tenantName;
  final String status;

  const AdminTenantReviewScreen({
    super.key,
    required this.tenantId,
    required this.tenantName,
    required this.status,
  });

  @override
  State<AdminTenantReviewScreen> createState() =>
      _AdminTenantReviewScreenState();
}

class _AdminTenantReviewScreenState extends State<AdminTenantReviewScreen> {
  late final AdminTenantApi _api;

  AdminTenantReviewDetail? _detail;
  bool _loading = true;
  bool _decisionLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _api = AdminTenantApi(apiClient.dio);
    _reloadTenant();
  }

  Future<void> _reloadTenant() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final detail = await _api.fetchTenantReviewDetail(widget.tenantId);

      if (!mounted) return;

      setState(() {
        _detail = detail;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  String _prettyLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _friendlyDate(String? value) {
    if (value == null || value.trim().isEmpty) return '—';

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

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending_review':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _stripeStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'restricted':
        return Colors.red;
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _value(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '—' : text;
  }

  Map<String, dynamic>? get _stripe {
    final payouts = _detail?.payouts;
    if (payouts == null) return null;
    final stripe = payouts['stripe'];
    if (stripe is Map<String, dynamic>) return stripe;
    if (stripe is Map) return Map<String, dynamic>.from(stripe);
    return null;
  }

  bool get _stripeHasAccount => _stripe?['has_account'] == true;
  bool get _stripeDetailsSubmitted => _stripe?['details_submitted'] == true;
  bool get _stripeChargesEnabled => _stripe?['charges_enabled'] == true;
  bool get _stripePayoutsEnabled => _stripe?['payouts_enabled'] == true;
  bool get _stripeApproved => _detail?.payouts?['setup_complete'] == true;

  String get _stripeStatus {
    final value = _stripe?['onboarding_status']?.toString().trim() ?? '';
    return value.isEmpty ? 'unknown' : value;
  }

  List<String> get _stripeRequirementsCurrentlyDue {
    final raw = _stripe?['requirements_currently_due'];
    if (raw is List) {
      return raw
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return const [];
  }

  String? get _stripeDisabledReason {
    final value = _stripe?['requirements_disabled_reason']?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> _approve() async {
    setState(() {
      _decisionLoading = true;
    });

    try {
      await _api.approveTenant(widget.tenantId);
      await _reloadTenant();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Store approved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _decisionLoading = false;
      });
    }
  }

  Future<void> _reject({
    required String reason,
    required List<String> issues,
    String? reviewNotes,
  }) async {
    setState(() {
      _decisionLoading = true;
    });

    try {
      await _api.rejectTenant(
        tenantId: widget.tenantId,
        reason: reason,
        issues: issues,
        reviewNotes: reviewNotes,
      );
      await _reloadTenant();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Store rejected')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _decisionLoading = false;
      });
    }
  }

  Widget _buildSectionCard({
    required String title,
    required List<_DetailRow> rows,
  }) {
    final visibleRows = rows.where((row) {
      final text = row.value.trim();
      return text.isNotEmpty && text != '—';
    }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          if (visibleRows.isEmpty)
            const Text(
              'No data available.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            )
          else
            ...visibleRows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        '${row.label}:',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.value,
                        style: const TextStyle(color: Color(0xFF374151)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStripeApprovalCard() {
    final stripe = _stripe;
    final status = _stripeStatus;
    final statusColor = _stripeStatusColor(status);

    return Container(
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
            'Stripe approval',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.25)),
                ),
                child: Text(
                  _prettyLabel(status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (stripe == null)
            const Text(
              'No Stripe data available.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            )
          else ...[
            _buildFlagRow('Stripe account connected', _stripeHasAccount),
            _buildFlagRow('Details submitted', _stripeDetailsSubmitted),
            _buildFlagRow('Payments enabled', _stripeChargesEnabled),
            _buildFlagRow('Payouts enabled', _stripePayoutsEnabled),
            _buildFlagRow('Approved for marketplace', _stripeApproved),
            const SizedBox(height: 12),
            if ((_stripe?['account_id']?.toString().trim().isNotEmpty ?? false))
              Text(
                'Account ID: ${_stripe?['account_id']}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
              ),
            if ((_stripe?['account_type']?.toString().trim().isNotEmpty ??
                false))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Account type: ${_stripe?['account_type']}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            if ((_stripe?['onboarded_at']?.toString().trim().isNotEmpty ??
                false))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Approved at: ${_friendlyDate(_stripe?['onboarded_at']?.toString())}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            if (_stripeDisabledReason != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  _stripeDisabledReason!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
            if (_stripeRequirementsCurrentlyDue.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Stripe requirements still due',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              ..._stripeRequirementsCurrentlyDue.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 10),
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
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFlagRow(String label, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: done ? Colors.green : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewFeedbackCard(AdminTenantReviewDetail detail) {
    final issues = detail.reviewIssues;
    final hasContent =
        (detail.rejectionReason?.trim().isNotEmpty ?? false) ||
        (detail.reviewNotes?.trim().isNotEmpty ?? false) ||
        issues.isNotEmpty;

    if (!hasContent) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      title: 'Review feedback',
      rows: [
        _DetailRow('Rejection reason', _value(detail.rejectionReason)),
        _DetailRow('Review notes', _value(detail.reviewNotes)),
        _DetailRow(
          'Review issues',
          issues.isEmpty ? '—' : issues.map(_prettyLabel).join(', '),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final effectiveStatus = detail?.status ?? widget.status;
    final statusColor = _statusColor(effectiveStatus);
    final screenTitle = (detail?.name.trim().isNotEmpty ?? false)
        ? detail!.name
        : widget.tenantName;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(screenTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 42,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load tenant review',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _reloadTenant,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _reloadTenant,
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
                        const Text(
                          'Store review',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tenant ID: ${widget.tenantId}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Status: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                _prettyLabel(effectiveStatus),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (detail != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Submitted: ${_friendlyDate(detail.submittedForReviewAt)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          if (detail.approvedAt != null)
                            Text(
                              'Approved: ${_friendlyDate(detail.approvedAt)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          if (detail.rejectedAt != null)
                            Text(
                              'Rejected: ${_friendlyDate(detail.rejectedAt)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (detail != null) ...[
                    _buildSectionCard(
                      title: 'Business details',
                      rows: [
                        _DetailRow(
                          'Legal name',
                          _value(detail.business?['legal_name']),
                        ),
                        _DetailRow(
                          'Business email',
                          _value(detail.business?['business_email']),
                        ),
                        _DetailRow(
                          'Business phone',
                          _value(detail.business?['business_phone']),
                        ),
                        _DetailRow(
                          'Business type',
                          _value(detail.business?['business_type']),
                        ),
                        _DetailRow(
                          'Registration number',
                          _value(detail.business?['registration_number']),
                        ),
                        _DetailRow(
                          'Tax number',
                          _value(detail.business?['tax_number']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Store profile',
                      rows: [
                        _DetailRow('Store name', _value(detail.store?['name'])),
                        _DetailRow('Slug', _value(detail.store?['slug'])),
                        _DetailRow('Tagline', _value(detail.store?['tagline'])),
                        _DetailRow('City', _value(detail.store?['city'])),
                        _DetailRow('Country', _value(detail.store?['country'])),
                        _DetailRow(
                          'Address line 1',
                          _value(detail.store?['address_line_1']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Operations',
                      rows: [
                        _DetailRow(
                          'Supports delivery',
                          detail.operations?['supports_delivery'] == true
                              ? 'Yes'
                              : 'No',
                        ),
                        _DetailRow(
                          'Supports pickup',
                          detail.operations?['supports_pickup'] == true
                              ? 'Yes'
                              : 'No',
                        ),
                        _DetailRow(
                          'Pickup address',
                          _value(detail.operations?['pickup_address']),
                        ),
                        _DetailRow(
                          'Delivery notes',
                          _value(detail.operations?['delivery_notes']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Catalog',
                      rows: [
                        _DetailRow(
                          'Product count',
                          _value(detail.catalog?['product_count']),
                        ),
                        _DetailRow(
                          'Ready for review',
                          detail.catalog?['ready_for_review'] == true
                              ? 'Yes'
                              : 'No',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStripeApprovalCard(),
                    const SizedBox(height: 16),
                    _buildReviewFeedbackCard(detail),
                    if ((detail.rejectionReason?.trim().isNotEmpty ?? false) ||
                        (detail.reviewNotes?.trim().isNotEmpty ?? false) ||
                        detail.reviewIssues.isNotEmpty)
                      const SizedBox(height: 16),
                  ],
                  AdminTenantReviewCard(
                    tenantId: widget.tenantId,
                    status: effectiveStatus,
                    onApprove: _decisionLoading ? null : _approve,
                    onReject: _decisionLoading
                        ? null
                        : ({
                            required String reason,
                            required List<String> issues,
                            String? reviewNotes,
                          }) => _reject(
                            reason: reason,
                            issues: issues,
                            reviewNotes: reviewNotes,
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);
}
