/// Response model for Neshan reverse-geocoding API.
///
/// This model represents the data returned by the Neshan reverse-geocoding API
/// when converting geographic coordinates (latitude/longitude) to a human-readable address.
///
/// Based on Neshan API documentation: https://platform.neshan.org/docs/api/reverse-geocoding/
class ReverseGeocodingResponse {
  /// Creates a [ReverseGeocodingResponse] instance.
  const ReverseGeocodingResponse({
    required this.status,
    required this.formattedAddress,
    required this.city,
    required this.state,
    required this.inTrafficZone,
    required this.inOddEvenZone,
    this.routeName,
    this.routeType,
    this.neighbourhood,
    this.place,
    this.municipalityZone,
    this.village,
    this.county,
    this.district,
  });

  /// Status of the API request. "OK" means successful.
  final String status;

  /// Complete formatted address including state, city, neighborhood, and street.
  final String formattedAddress;

  /// Name of the last street in the address.
  final String? routeName;

  /// Type of the last street in the address (e.g., "secondary").
  final String? routeType;

  /// Name of the neighborhood (if available).
  final String? neighbourhood;

  /// Name of the city.
  final String city;

  /// Name of the state/province.
  final String state;

  /// Name of a public place where the point is located (if available).
  final String? place;

  /// Municipality zone number (if available).
  final String? municipalityZone;

  /// Whether the point is in traffic restriction zone.
  final bool inTrafficZone;

  /// Whether the point is in odd-even traffic restriction zone.
  final bool inOddEvenZone;

  /// Name of the village (if in rural area).
  final String? village;

  /// Name of the county.
  final String? county;

  /// Name of the district.
  final String? district;

  /// Creates a [ReverseGeocodingResponse] from JSON data.
  factory ReverseGeocodingResponse.fromJson(Map<String, dynamic> json) {
    return ReverseGeocodingResponse(
      status: json['status'] as String,
      formattedAddress: json['formatted_address'] as String,
      routeName: json['route_name'] as String?,
      routeType: json['route_type'] as String?,
      neighbourhood: json['neighbourhood'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      place: json['place'] as String?,
      municipalityZone: json['municipality_zone'] as String?,
      inTrafficZone: json['in_traffic_zone'] as bool,
      inOddEvenZone: json['in_odd_even_zone'] as bool,
      village: json['village'] as String?,
      county: json['county'] as String?,
      district: json['district'] as String?,
    );
  }

  /// Converts this instance to JSON data.
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'formatted_address': formattedAddress,
      'route_name': routeName,
      'route_type': routeType,
      'neighbourhood': neighbourhood,
      'city': city,
      'state': state,
      'place': place,
      'municipality_zone': municipalityZone,
      'in_traffic_zone': inTrafficZone,
      'in_odd_even_zone': inOddEvenZone,
      'village': village,
      'county': county,
      'district': district,
    };
  }

  @override
  String toString() {
    return 'ReverseGeocodingResponse(status: $status, formattedAddress: $formattedAddress, city: $city)';
  }
}
