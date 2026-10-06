import 'package:flutter/material.dart';

import '../../../../core/theme/forest_colors.dart';
import '../../../../core/widgets/forest_card.dart';
import '../../../../core/widgets/forest_pill.dart';
import '../../domain/entities/brewery.dart';
import 'brewery_formatting.dart';

class BreweryTile extends StatelessWidget {
  const BreweryTile({super.key, required this.brewery, required this.onTap});

  final Brewery brewery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ForestCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: ForestColors.mistGreenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_bar, color: ForestColors.leafGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brewery.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: ForestColors.darkGray,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        brewery.location ?? 'Unknown city',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: ForestColors.darkGray,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ForestPill(label: brewery.type.label),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: ForestColors.forestGreen),
        ],
      ),
    );
  }
}
