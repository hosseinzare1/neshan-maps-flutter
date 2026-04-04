import 'search_item.dart';

/// Response model for Neshan Search API.
///
/// This model represents the complete response returned by the Neshan Search API
/// when searching for locations, streets, or points of interest.
///
/// Based on Neshan API documentation: https://platform.neshan.org/docs/api/search/
class SearchResponse {
  /// Creates a [SearchResponse] instance.
  const SearchResponse({required this.count, required this.items});

  /// Total number of results found.
  final int count;

  /// List of search result items.
  ///
  /// The API returns up to 30 results per request, sorted by distance
  /// from the reference point (map center).
  final List<SearchItem> items;

  /// Creates a [SearchResponse] from JSON data.
  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>;
    return SearchResponse(
      count: json['count'] as int,
      items: itemsList
          .map((item) => SearchItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this instance to JSON data.
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'SearchResponse(count: $count, items: ${items.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResponse &&
        other.count == count &&
        other.items.length == items.length;
  }

  @override
  int get hashCode => count.hashCode ^ items.hashCode;
}
