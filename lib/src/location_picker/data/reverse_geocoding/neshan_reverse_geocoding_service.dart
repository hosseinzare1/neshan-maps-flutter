import '../base/neshan_api_service.dart';
import 'models/reverse_geocoding_response.dart';

/// Service for interacting with Neshan's reverse-geocoding API.
///
/// This service provides methods to convert geographic coordinates (latitude/longitude)
/// to human-readable addresses using the Neshan API.
///
/// The service is independent of Flutter framework and can be used in any Dart project.
///
/// Example usage:
/// ```dart
/// final service = NeshanReverseGeocodingService(apiKey: 'your-api-key');
/// try {
///   final response = await service.reverseGeocode(35.6892, 51.3890);
///   print('Address: ${response.formattedAddress}');
/// } on NeshanApiError catch (e) {
///   print('Error: ${e.message}');
/// } finally {
///   service.dispose();
/// }
/// ```
class NeshanReverseGeocodingService extends NeshanApiService {
  /// Creates a [NeshanReverseGeocodingService] instance.
  ///
  /// [apiKey] - The Neshan API key for reverse geocoding service.
  /// [client] - Optional HTTP client for making requests. If not provided,
  ///            a default client will be created.
  /// [timeout] - Optional timeout duration for API requests. Defaults to 10 seconds.
  /// [logger] - Optional logger for debug output.
  NeshanReverseGeocodingService({
    required super.apiKey,
    super.client,
    super.timeout,
    super.logger,
  });

  /// Base URL for Neshan reverse-geocoding API.
  static const String _baseUrl = 'https://api.neshan.org/v5/reverse';

  /// Converts geographic coordinates to a human-readable address.
  ///
  /// [lat] - Latitude of the location.
  /// [lng] - Longitude of the location.
  ///
  /// Returns a [ReverseGeocodingResponse] containing the address details.
  ///
  /// Throws [NeshanApiError] if the request fails. The specific error type
  /// depends on the failure reason:
  /// - [NetworkError] - Network connection failed or timeout
  /// - [InvalidApiKeyError] - API key is invalid or missing
  /// - [CoordinateParseError] - Coordinates are invalid
  /// - [RateLimitExceededError] - Rate limit exceeded
  /// - [ApiServiceError] - API service configuration error
  /// - [NotFoundError] - No address found for the coordinates
  /// - [InvalidArgumentError] - Invalid request parameters
  /// - [ParseError] - Response parsing failed
  /// - [UnknownError] - Unknown or unexpected error
  Future<ReverseGeocodingResponse> reverseGeocode(
    double lat,
    double lng,
  ) async {
    // Construct the URL with query parameters
    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'lat': lat.toString(), 'lng': lng.toString()});

    return makeRequest(
      uri: uri,
      parser: (json) => ReverseGeocodingResponse.fromJson(json),
      requestDescription: 'Reverse geocoding request for: ($lat, $lng)',
    );
  }
}
