import '../../../data/search/models/search_models.dart';

/// Immutable state class for search functionality.
///
/// This class represents all possible states of the search screen,
/// including loading, results, errors, and empty states.
class SearchState {
  /// The list of search results. Null indicates no search has been performed yet.
  final List<SearchItem>? searchResults;

  /// Whether a search operation is currently in progress.
  final bool isLoading;

  /// Error message to display to the user. Null if no error.
  final String? errorMessage;

  /// The current search query text.
  final String currentQuery;

  /// Creates a [SearchState] instance.
  const SearchState({
    this.searchResults,
    this.isLoading = false,
    this.errorMessage,
    this.currentQuery = '',
  });

  /// Creates an initial empty state.
  const SearchState.initial()
    : searchResults = null,
      isLoading = false,
      errorMessage = null,
      currentQuery = '';

  /// Creates a loading state with the current query.
  SearchState loading(String query) {
    return SearchState(
      searchResults: null,
      isLoading: true,
      errorMessage: null,
      currentQuery: query,
    );
  }

  /// Creates a success state with search results.
  SearchState success(List<SearchItem> results, String query) {
    return SearchState(
      searchResults: results,
      isLoading: false,
      errorMessage: null,
      currentQuery: query,
    );
  }

  /// Creates an error state with an error message.
  SearchState error(String message, String query) {
    return SearchState(
      searchResults: null,
      isLoading: false,
      errorMessage: message,
      currentQuery: query,
    );
  }

  /// Creates a copy of this state with the given fields replaced with new values.
  SearchState copyWith({
    List<SearchItem>? searchResults,
    bool? isLoading,
    String? errorMessage,
    String? currentQuery,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }

  /// Whether the state represents an empty result (no results after search).
  bool get isEmpty => searchResults != null && searchResults!.isEmpty;

  /// Whether the state has results to display.
  bool get hasResults => searchResults != null && searchResults!.isNotEmpty;

  /// Whether the state has an error.
  bool get hasError => errorMessage != null;
}
