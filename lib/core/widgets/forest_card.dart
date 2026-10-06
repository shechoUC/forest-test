import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/forest_colors.dart';

/// White card with Forest's outline and hard bottom shadow.
class ForestCard extends StatelessWidget {
  const ForestCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color = ForestColors.white,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      side: const BorderSide(
        color: ForestColors.forestGreen,
        width: AppTheme.borderWidth,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: const [
          BoxShadow(color: ForestColors.forestGreen, offset: Offset(0, 3)),
        ],
      ),
      child: Material(
        color: color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
