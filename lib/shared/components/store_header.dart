import 'package:flutter/material.dart';

class StoreHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onChangeStore;

  const StoreHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onChangeStore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.12),
              child: Icon(
                Icons.storefront,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onChangeStore,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Store'),
            ),
          ],
        ),
      ),
    );
  }
}
