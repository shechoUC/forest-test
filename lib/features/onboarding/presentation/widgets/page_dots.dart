import 'package:flutter/material.dart';

import '../../../../core/theme/forest_colors.dart';

/// Row of dots marking the current page; the active one stretches into a pill.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

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
              width: i == current ? 24 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: i == current
                    ? ForestColors.pineGreen
                    : ForestColors.midGray,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
        ],
      ),
    );
  }
}
