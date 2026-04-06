import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../utils/neshan_map_logger.dart';
import '../../../data/error/neshan_api_error.dart';
import '../../../data/search/neshan_search_service.dart';
import 'search_state.dart';

/// Controller for managing search functionality with ValueNotifier-based state management.
///
/// This controller encapsulates all business logic for the search screen,
/// including debouncing, API calls, error handling, and state management.
///
/// Example usage:
/// ```dart
/// final controller = SearchController(
///   apiKey: 'your-api-key',
///   enableDebug: true,
/// );
///
/// // Listen to state changes
/// controller.state.addListener(() {
///   print('State changed: ${controller.state.value}');
/// });
///
/// // Perform search
/// controller.onSearchChanged('تهران', 35.6892, 51.3890);
///
/// // Clean up
/// controller.dispose();
/// ```
class SearchController {
  /// Creates a [SearchController] instance.
  ///
  /// [apiKey] - The Neshan API key for search service.
  /// [enableDebug] - Whether to enable debug logging.
  /// [debounceDelay] - Debounce duration for search input (default: 300ms).
  /// [onApiError] - Optional callback for handling API errors.
  SearchController({
    required String apiKey,
    bool enableDebug = false,
    Duration debounceDelay = const Duration(milliseconds: 300),
    void Function(NeshanApiError error)? onApiError,
  })  : _onApiError = onApiError,
        _debounceDelay = debounceDelay,
        _logger = NeshanMapLogger(
          enabled: enableDebug,
          prefix: 'SearchController',
        ) {
    _searchService = NeshanSearchService(
      apiKey: apiKey,
      logger: _logger.withPrefix('Search'),
    );
  }

  /// The reactive state holder.
  final ValueNotifier<SearchState> state = ValueNotifier(
    const SearchState.initial(),
  );

  late final NeshanSearchService _searchService;
  final NeshanMapLogger _logger;
  final void Function(NeshanApiError error)? _onApiError;
  final Duration _debounceDelay;

  Timer? _debounceTimer;

  /// Handles search text changes with debouncing.
  ///
  /// This method cancels any pending search, clears errors,
  /// and schedules a new search after the configured delay if the query is valid.
  ///
  /// [query] - The search query text.
  /// [lat] - The reference latitude for sorting results.
  /// [lng] - The reference longitude for sorting results.
  void onSearchChanged(String query, double lat, double lng) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear error message when user types
    if (state.value.hasError) {
      state.value = state.value.copyWith(
        errorMessage: null,
        currentQuery: query,
      );
    }

    // If query is too short, clear results
    if (query.length < 3) {
      state.value = SearchState(
        searchResults: null,
        isLoading: false,
        errorMessage: null,
        currentQuery: query,
      );
      return;
    }

    // Set loading state immediately
    state.value = state.value.loading(query);

    // Start debounce timer
    _debounceTimer = Timer(_debounceDelay, () {
      performSearch(query, lat, lng);
    });
  }

  /// Performs the actual search API call.
  ///
  /// [query] - The search query text.
  /// [lat] - The reference latitude for sorting results.
  /// [lng] - The reference longitude for sorting results.
  /// [setLoadingImmediately] - If true, sets loading state before the call.
  Future<void> performSearch(
    String query,
    double lat,
    double lng, {
    bool setLoadingImmediately = false,
  }) async {
    if (setLoadingImmediately) {
      state.value = state.value.loading(query);
    }

    _logger.log('Performing search for: $query');

    try {
      final response = await _searchService.search(query, lat, lng);

      // Update state with results
      state.value = state.value.success(response.items, query);

      _logger.log('Search completed with ${response.items.length} results');
    } on NeshanApiError catch (e) {
      _logger.error('API error during search', e);

      // Notify parent about the error
      _onApiError?.call(e);

      // Update state with error (error type will be converted to message in UI layer)
      state.value = state.value.error(e.toString(), query);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error during search', e);

      // Update state with generic error
      state.value = state.value.error('خطای غیرمنتظره: $e', query);

      // Log the unexpected error for debugging
      debugPrint('SearchController: Unexpected error: $e\n$stackTrace');
    }
  }

  /// Clears the current search state and resets to initial state.
  void clearSearch() {
    _debounceTimer?.cancel();
    state.value = const SearchState.initial();
    _logger.log('Search cleared');
  }

  /// Clears only the error message from the current state.
  void clearError() {
    if (state.value.hasError) {
      state.value = state.value.copyWith(errorMessage: null);
    }
  }

  /// Disposes of resources used by this controller.
  ///
  /// This method should be called when the controller is no longer needed,
  /// typically in the widget's dispose method.
  void dispose() {
    _debounceTimer?.cancel();
    _searchService.dispose();
    state.dispose();
    _logger.log('SearchController disposed');
  }
}
