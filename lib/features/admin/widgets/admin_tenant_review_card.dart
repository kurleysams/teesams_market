import 'package:flutter/material.dart';

class AdminTenantReviewCard extends StatefulWidget {
  final int tenantId;
  final String status;
  final Future<void> Function()? onApprove;
  final Future<void> Function({
    required String reason,
    required List<String> issues,
    String? reviewNotes,
  })?
  onReject;

  const AdminTenantReviewCard({
    super.key,
    required this.tenantId,
    required this.status,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<AdminTenantReviewCard> createState() => _AdminTenantReviewCardState();
}

class _AdminTenantReviewCardState extends State<AdminTenantReviewCard> {
  final _reasonCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final Set<String> _selectedIssues = <String>{};

  bool _submittingApprove = false;
  bool _submittingReject = false;

  static const Map<String, String> _issueOptions = {
    'business_details': 'Business details',
    'store_profile': 'Store profile',
    'operations': 'Store operations',
    'documents': 'Verification documents',
    'catalog_setup': 'Catalog setup',
    'payout_setup': 'Payout setup',
  };

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canReview => widget.status == 'pending_review';

  Future<void> _approve() async {
    if (!_canReview || widget.onApprove == null) return;

    setState(() {
      _submittingApprove = true;
    });

    try {
      await widget.onApprove!();
    } finally {
      if (mounted) {
        setState(() {
          _submittingApprove = false;
        });
      }
    }
  }

  Future<void> _reject() async {
    if (!_canReview || widget.onReject == null) return;

    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a rejection reason')));
      return;
    }

    setState(() {
      _submittingReject = true;
    });

    try {
      await widget.onReject!(
        reason: reason,
        issues: _selectedIssues.toList(),
        reviewNotes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submittingReject = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _submittingApprove || _submittingReject;
    final approveEnabled = !busy && _canReview && widget.onApprove != null;
    final rejectEnabled = !busy && _canReview && widget.onReject != null;

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
            'Review decision',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _canReview
                ? 'Approve this store or reject it with a reason.'
                : 'This store is not currently pending review.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Flagged sections',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          ..._issueOptions.entries.map(
            (entry) => CheckboxListTile(
              value: _selectedIssues.contains(entry.key),
              onChanged: rejectEnabled
                  ? (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedIssues.add(entry.key);
                        } else {
                          _selectedIssues.remove(entry.key);
                        }
                      });
                    }
                  : null,
              title: Text(entry.value),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            enabled: rejectEnabled,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Rejection reason',
              hintText: 'Explain what needs to be changed before approval.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            enabled: rejectEnabled,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Internal / review notes (optional)',
              hintText: 'Add extra reviewer notes.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: rejectEnabled ? _reject : null,
                  child: _submittingReject
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: approveEnabled ? _approve : null,
                  child: _submittingApprove
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
