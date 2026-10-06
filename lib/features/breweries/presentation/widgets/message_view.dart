import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/forest_colors.dart';
import '../../../../core/widgets/forest_button.dart';

/// Centered illustration-style icon, title and message, with an optional
/// action. Used for the error and empty states on every screen.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: ForestColors.mistGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ForestColors.forestGreen,
                  width: AppTheme.borderWidth,
                ),
              ),
              child: Icon(icon, size: 44, color: ForestColors.pineGreen),
            ),
            const SizedBox(height: 24),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: ForestText.display(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: ForestColors.darkGray,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ForestButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: ForestButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
