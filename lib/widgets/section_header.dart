import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Title (+ optional subtitle and "See all" button) above a section.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.subtitle, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              if (subtitle != null)
                Text(subtitle!,
                    style: TextStyle(color: AppTheme.mutedText(context))),
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}
