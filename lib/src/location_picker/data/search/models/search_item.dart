import 'search_location.dart';

/// Category type for search results.
///
/// Represents the classification of a search result from Neshan API.
enum SearchItemCategory {
  /// Point of interest (مکان).
  place,

  /// Street or municipal feature (معبر شهری).
  municipal,

  /// City, village, or province (شهر، روستا، استان).
  region;

  /// Creates a [SearchItemCategory] from a string value.
  ///
  /// Defaults to [SearchItemCategory.place] if the value is not recognized.
  static SearchItemCategory fromString(String value) {
    return switch (value.toLowerCase()) {
      'place' => SearchItemCategory.place,
      'municipal' => SearchItemCategory.municipal,
      'region' => SearchItemCategory.region,
      _ => SearchItemCategory.place, // Default fallback
    };
  }

  /// Converts this category to a string for JSON serialization.
  String toJson() {
    return switch (this) {
      SearchItemCategory.place => 'place',
      SearchItemCategory.municipal => 'municipal',
      SearchItemCategory.region => 'region',
    };
  }
}

/// Individual search result item from Neshan Search API.
///
/// This model represents a single location result from a search query,
/// including its name, address, type, category, and coordinates.
///
/// Based on Neshan API documentation: https://platform.neshan.org/docs/api/search/
class SearchItem {
  /// Creates a [SearchItem] instance.
  const SearchItem({
    required this.title,
    required this.address,
    required this.region,
    required this.type,
    required this.category,
    required this.location,
    this.neighbourhood,
  });

  /// Title of the location (e.g., "میدان آزادی").
  final String title;

  /// Full address of the location.
  final String address;

  /// Name of the neighborhood (if available).
  final String? neighbourhood;

  /// Region (city + state).
  final String region;

  /// Type of location (e.g., "میدان", "خیابان", "مسجد").
  final String type;

  /// Category of the result.
  final SearchItemCategory category;

  /// Geographic coordinates of the location.
  final SearchLocation location;

  /// Creates a [SearchItem] from JSON data.
  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      title: json['title'] as String,
      address: json['address'] as String,
      neighbourhood: json['neighbourhood'] as String?,
      region: json['region'] as String,
      type: json['type'] as String,
      category: SearchItemCategory.fromString(json['category'] as String),
      location: SearchLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts this instance to JSON data.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'address': address,
      'neighbourhood': neighbourhood,
      'region': region,
      'type': type,
      'category': category.toJson(),
      'location': location.toJson(),
    };
  }

  @override
  String toString() {
    return 'SearchItem(title: $title, address: $address, type: $type, category: $category, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchItem &&
        other.title == title &&
        other.address == address &&
        other.neighbourhood == neighbourhood &&
        other.region == region &&
        other.type == type &&
        other.category == category &&
        other.location == location;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        address.hashCode ^
        neighbourhood.hashCode ^
        region.hashCode ^
        type.hashCode ^
        category.hashCode ^
        location.hashCode;
  }
}
