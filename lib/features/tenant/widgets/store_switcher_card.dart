import 'package:flutter/material.dart';

class StoreSwitcherCard extends StatelessWidget {
  final String name;
  final bool isCurrent;
  final VoidCallback onTap;

  const StoreSwitcherCard({
    super.key,
    required this.name,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 128,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrent ? Colors.blue : Colors.grey.shade300,
            width: isCurrent ? 2 : 1,
          ),
          color: isCurrent ? Colors.blue.withOpacity(0.08) : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              isCurrent ? 'Current' : 'Switch Store',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isCurrent ? Colors.blue : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
