import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// A small card with an icon, a number and a label (used on the Profile page).
class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const StatTile({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text('$value',
                  key: ValueKey(value),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            ),
            Text(label, style: TextStyle(color: AppTheme.mutedText(context))),
          ],
        ),
      ),
    );
  }
}
