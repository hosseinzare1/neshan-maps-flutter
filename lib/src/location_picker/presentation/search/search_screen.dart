import 'package:flutter/material.dart';
import '../../data/error/neshan_api_error.dart';
import 'manager/search_controller.dart' as search;
import 'widgets/search_app_bar.dart';
import 'widgets/search_body.dart';

/// A full-screen search interface for finding locations.
///
/// This widget provides a search experience for querying locations, streets,
/// and points of interest using the Neshan Search API. It includes:
/// - Auto-complete search with configurable debouncing
/// - Minimum character requirement (3 characters)
/// - Result list sorted by distance from reference point
/// - Error handling and loading states
///
/// The widget uses ValueNotifier-based state management for efficient
/// updates and clean separation of concerns.
///
/// Example usage (imports omitted; [SearchItem] is defined in this library’s
/// search models):
/// ```dart
/// final result = await Navigator.push<SearchItem>(
///   context,
///   MaterialPageRoute(
///     builder: (context) => SearchScreen(
///       apiKey: 'your-api-key',
///       currentLat: 35.6892,
///       currentLng: 51.3890,
///       initialAddress: 'تهران',
///       searchDebounce: Duration(milliseconds: 400),
///     ),
///   ),
/// );
/// if (result != null) {
///   print('Selected: ${result.title}');
/// }
/// ```
class SearchScreen extends StatefulWidget {
  /// Creates a [SearchScreen] instance.
  ///
  /// [apiKey] - The Neshan API key for search service.
  /// [currentLat] - Current map center latitude (used as reference point).
  /// [currentLng] - Current map center longitude (used as reference point).
  /// [initialAddress] - Optional initial text for the search field.
  /// [searchDebounce] - Debounce duration for search input (default: 300ms).
  /// [enableDebug] - Whether to enable debug logging.
  /// [onApiError] - Optional callback for handling API errors.
  const SearchScreen({
    super.key,
    required this.apiKey,
    required this.currentLat,
    required this.currentLng,
    this.initialAddress,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.enableDebug = false,
    this.onApiError,
  });

  final String apiKey;
  final double currentLat;
  final double currentLng;
  final String? initialAddress;
  final Duration searchDebounce;
  final bool enableDebug;
  final void Function(NeshanApiError error)? onApiError;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  late final search.SearchController _controller;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialAddress);
    _controller = search.SearchController(
      apiKey: widget.apiKey,
      enableDebug: widget.enableDebug,
      debounceDelay: widget.searchDebounce,
      onApiError: widget.onApiError,
    );

    // If there's initial text with >= 3 characters, trigger search
    if (widget.initialAddress != null && widget.initialAddress!.length >= 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.performSearch(
          widget.initialAddress!,
          widget.currentLat,
          widget.currentLng,
          setLoadingImmediately: true,
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Handles text field changes.
  void _onSearchChanged(String query) {
    _controller.onSearchChanged(query, widget.currentLat, widget.currentLng);
  }

  /// Handles clearing the search field.
  void _onClearSearch() {
    _searchController.clear();
    _controller.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade50,
      appBar: SearchAppBar(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onClear: _onClearSearch,
      ),
      body: ValueListenableBuilder(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          return SearchBody(
            state: state,
            currentQuery: _searchController.text,
            onRetry: () => _controller.performSearch(
              _searchController.text,
              widget.currentLat,
              widget.currentLng,
            ),
            onItemSelected: (item) => Navigator.pop(context, item),
          );
        },
      ),
    );
  }
}
