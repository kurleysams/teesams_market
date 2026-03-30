import 'package:flutter/material.dart';

import '../models/tenant_store_status.dart';

class TenantStoreStatusCard extends StatelessWidget {
  final TenantStoreStatus? store;
  final bool saving;
  final bool canManageStoreStatus;
  final String? error;
  final ValueChanged<bool> onToggle;

  const TenantStoreStatusCard({
    super.key,
    required this.store,
    required this.saving,
    required this.canManageStoreStatus,
    required this.error,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Store Status',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (store == null)
              const Text('No store data available')
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      store!.isOpen ? 'Store is Open' : 'Store is Closed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Switch(
                    value: store!.isOpen,
                    onChanged: (!canManageStoreStatus || saving)
                        ? null
                        : onToggle,
                  ),
                ],
              ),
              if (!canManageStoreStatus)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'You do not have permission to change store status.',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Timezone: ${store!.timezone}'),
              Text('Currency: ${store!.currency}'),
            ],
            if ((error ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
