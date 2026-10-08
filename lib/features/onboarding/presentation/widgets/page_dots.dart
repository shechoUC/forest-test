import 'package:flutter/material.dart';

import '../../../../core/theme/forest_colors.dart';

/// Row of dots marking the tips. Seen tips are filled, the current one is a
/// pill that fills up with [progress], and the rest stay gray.
class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.current,
    required this.progress,
  });

  final int count;
  final int current;

  /// How much of the current tip's time has passed, from 0 to 1.
  final Animation<double> progress;

  static const _size = 10.0;
  static const _activeWidth = 28.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tip ${current + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == current ? _activeWidth : _size,
              height: _size,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: i < current
                    ? ForestColors.pineGreen
                    : ForestColors.midGray,
                borderRadius: BorderRadius.circular(100),
              ),
              child: i == current
                  ? AnimatedBuilder(
                      animation: progress,
                      builder: (_, _) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.value,
                        child: const ColoredBox(color: ForestColors.pineGreen),
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}
