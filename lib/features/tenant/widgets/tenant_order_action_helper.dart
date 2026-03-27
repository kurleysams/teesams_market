import 'package:flutter/material.dart';

import '../models/tenant_order_summary.dart';
import '../utils/tenant_order_ui.dart';

class TenantOrderActionInput {
  final String action;
  final String? reasonCode;
  final String? note;

  const TenantOrderActionInput({
    required this.action,
    this.reasonCode,
    this.note,
  });
}

class TenantOrderActionHelper {
  static Future<TenantOrderActionInput?> collectActionInput({
    required BuildContext context,
    required TenantOrderActionSummary action,
  }) async {
    if (action.key == 'cancel_order') {
      return _showCancelSheet(context, action.key);
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(TenantOrderUi.actionLabel(action.key)),
          content: const Text('Are you sure you want to continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return null;

    return TenantOrderActionInput(action: action.key);
  }

  static Future<TenantOrderActionInput?> _showCancelSheet(
    BuildContext context,
    String action,
  ) async {
    final noteController = TextEditingController();
    String selectedReason = 'out_of_stock';

    final result = await showModalBottomSheet<TenantOrderActionInput>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'out_of_stock',
                        child: Text('Out of stock'),
                      ),
                      DropdownMenuItem(
                        value: 'store_closed',
                        child: Text('Store closed'),
                      ),
                      DropdownMenuItem(
                        value: 'unable_to_fulfill',
                        child: Text('Unable to fulfill'),
                      ),
                      DropdownMenuItem(
                        value: 'customer_request',
                        child: Text('Customer request'),
                      ),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedReason = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          TenantOrderActionInput(
                            action: action,
                            reasonCode: selectedReason,
                            note: noteController.text.trim().isEmpty
                                ? null
                                : noteController.text.trim(),
                          ),
                        );
                      },
                      child: const Text('Confirm Cancellation'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    noteController.dispose();
    return result;
  }
}
