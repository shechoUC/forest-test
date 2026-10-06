import 'package:flutter/material.dart';

import '../theme/forest_colors.dart';

/// Small rounded label, e.g. the brewery type.
class ForestPill extends StatelessWidget {
  const ForestPill({
    super.key,
    required this.label,
    this.background = ForestColors.mistGreen,
    this.foreground = ForestColors.pineGreen,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
