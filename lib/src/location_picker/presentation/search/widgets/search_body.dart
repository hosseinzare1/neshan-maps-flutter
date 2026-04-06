import 'package:flutter/material.dart';
import '../../../data/search/models/search_models.dart';
import '../manager/search_state.dart';
import 'error_message_helper.dart';
import 'search_empty_state.dart';
import 'search_error_state.dart';
import 'search_item_shimmer.dart';
import 'search_item_tile.dart';

/// The main body widget for the search screen.
///
/// This widget conditionally renders different UI based on the search state:
/// - Loading shimmer when searching
/// - Error state when an error occurs
/// - Empty state when no results
/// - Results list when results are available
class SearchBody extends StatelessWidget {
  /// Creates a [SearchBody] instance.
  ///
  /// [state] - The current search state.
  /// [currentQuery] - The current search query text.
  /// [onRetry] - Callback for retrying a failed search.
  /// [onItemSelected] - Callback when a search item is selected.
  const SearchBody({
    super.key,
    required this.state,
    required this.currentQuery,
    required this.onRetry,
    required this.onItemSelected,
  });

  final SearchState state;
  final String currentQuery;
  final VoidCallback onRetry;
  final void Function(SearchItem) onItemSelected;

  @override
  Widget build(BuildContext context) {
    // Loading state with shimmer
    if (state.isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) => const SearchItemShimmer(),
      );
    }

    // Error state
    if (state.hasError) {
      return SearchErrorState(
        errorMessage: getUserFriendlyErrorMessage(state.errorMessage!),
        onRetry: onRetry,
      );
    }

    // Empty state
    if (state.searchResults == null || state.isEmpty) {
      return SearchEmptyState(hasQuery: currentQuery.length >= 3);
    }

    // Results list
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.searchResults!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = state.searchResults![index];
        return SearchItemTile(item: item, onTap: () => onItemSelected(item));
      },
    );
  }
}
