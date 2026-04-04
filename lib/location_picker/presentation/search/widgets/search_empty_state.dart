import 'package:flutter/material.dart';

/// Widget for displaying an empty search state.
///
/// Shows different messages depending on whether the user has entered
/// a valid query (3+ characters) or not.
class SearchEmptyState extends StatelessWidget {
  /// Creates a [SearchEmptyState] instance.
  ///
  /// [hasQuery] - Whether the user has entered a query with 3+ characters.
  const SearchEmptyState({super.key, required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasQuery ? Icons.search_off_rounded : Icons.search_rounded,
                size: 72,
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasQuery ? 'نتیجه‌ای یافت نشد' : 'حداقل 3 حرف وارد کنید',
              textDirection: TextDirection.rtl,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasQuery
                  ? 'عبارت دیگری را امتحان کنید یا املا را بررسی نمایید'
                  : 'برای جستجو مکان، خیابان یا منطقه مورد نظر را وارد کنید',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
