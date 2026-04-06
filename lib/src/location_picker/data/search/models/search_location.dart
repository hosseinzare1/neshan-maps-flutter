/// Location coordinates for a search result.
///
/// This model represents the geographic coordinates (latitude/longitude)
/// of a location returned by the Neshan Search API.
///
/// Based on Neshan API documentation: https://platform.neshan.org/docs/api/search/
class SearchLocation {
  /// Creates a [SearchLocation] instance.
  const SearchLocation({required this.x, required this.y});

  /// Longitude (x coordinate).
  final double x;

  /// Latitude (y coordinate).
  final double y;

  /// Creates a [SearchLocation] from JSON data.
  factory SearchLocation.fromJson(Map<String, dynamic> json) {
    return SearchLocation(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  /// Converts this instance to JSON data.
  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }

  @override
  String toString() => 'SearchLocation(lat: $y, lng: $x)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchLocation && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
