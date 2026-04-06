import 'package:flutter/material.dart';
import '../../location_picker/widgets/default_widgets.dart';

/// Shimmer loading widget for search items.
///
/// Displays a skeleton placeholder while search results are loading.
/// Uses the SkeletonLoader widget from default_widgets.dart.
class SearchItemShimmer extends StatelessWidget {
  /// Creates a [SearchItemShimmer] instance.
  const SearchItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SkeletonLoader(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 8,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(width: 200, height: 14, borderRadius: 8),
                const SizedBox(height: 6),
                SkeletonLoader(width: 120, height: 12, borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
