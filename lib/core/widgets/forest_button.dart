import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/forest_colors.dart';

enum ForestButtonVariant {
  /// Dark forest-green fill, white label.
  primary,

  /// White fill with an outline and a hard drop shadow.
  secondary,
}

/// Pill button in Forest's style: upper-case heavy italic label and a solid,
/// unblurred shadow that the button "presses into" on tap.
class ForestButton extends StatefulWidget {
  const ForestButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ForestButtonVariant.primary,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ForestButtonVariant variant;
  final bool compact;

  @override
  State<ForestButton> createState() => _ForestButtonState();
}

class _ForestButtonState extends State<ForestButton> {
  static const _shadowDepth = 4.0;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == ForestButtonVariant.primary;
    final enabled = widget.onPressed != null;
    final foreground = isPrimary
        ? ForestColors.white
        : ForestColors.forestGreen;
    final depth = isPrimary || _pressed ? 0.0 : _shadowDepth;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            height: widget.compact ? 44 : 56,
            transform: Matrix4.translationValues(
              0,
              _pressed && !isPrimary ? _shadowDepth : 0,
              0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isPrimary ? ForestColors.forestGreen : ForestColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: ForestColors.forestGreen,
                width: AppTheme.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: ForestColors.forestGreen,
                  offset: Offset(0, depth),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: foreground, size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ForestText.display(
                      fontSize: widget.compact ? 14 : 16,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
