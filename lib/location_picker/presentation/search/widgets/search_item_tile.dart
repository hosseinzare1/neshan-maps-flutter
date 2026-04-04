import 'package:flutter/material.dart';
import '../../../data/search/models/search_models.dart';

/// Widget for displaying a single search result item.
///
/// This is a stateless widget that shows a search result with:
/// - Category-based colored icon
/// - Title, address, and region information
/// - Material design with InkWell for tap interaction
/// - Responsive dark mode support
class SearchItemTile extends StatelessWidget {
  /// Creates a [SearchItemTile] instance.
  ///
  /// [item] - The search item to display.
  /// [onTap] - Callback when the item is tapped.
  const SearchItemTile({super.key, required this.item, required this.onTap});

  final SearchItem item;
  final VoidCallback onTap;

  /// Returns the appropriate icon for the search item category.
  IconData _getIcon() {
    return switch (item.category) {
      SearchItemCategory.place => Icons.place,
      SearchItemCategory.municipal => Icons.route,
      SearchItemCategory.region => Icons.location_city,
    };
  }

  /// Returns the color for the search item category.
  Color _getCategoryColor() {
    return switch (item.category) {
      SearchItemCategory.place => Colors.blue,
      SearchItemCategory.municipal => Colors.orange,
      SearchItemCategory.region => Colors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();
    final icon = _getIcon();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon with circular background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: categoryColor, size: 26),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Address
                      Text(
                        item.address,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Region with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              item.region,
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.location_city_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Trailing arrow
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
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
