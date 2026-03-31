import 'package:flutter/material.dart';

import 'mode_switcher_sheet.dart';

class ModeSwitcherButton extends StatelessWidget {
  const ModeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.swap_horiz),
      tooltip: 'Switch mode',
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ModeSwitcherSheet(),
        );
      },
    );
  }
}
