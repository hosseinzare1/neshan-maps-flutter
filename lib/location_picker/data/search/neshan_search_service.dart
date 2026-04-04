import '../base/neshan_api_service.dart';
import 'models/search_models.dart';

/// Service for interacting with Neshan's Search API.
///
/// This service provides methods to search for locations, streets, and points
/// of interest using the Neshan API. Search results are sorted by distance
/// from a reference point (latitude/longitude).
///
/// The service is independent of Flutter framework and can be used in any Dart project.
///
/// Example usage:
/// ```dart
/// final service = NeshanSearchService(apiKey: 'your-api-key');
/// try {
///   final response = await service.search('میدان آزادی', 35.6892, 51.3890);
///   print('Found ${response.count} results');
///   for (var item in response.items) {
///     print('${item.title}: ${item.address}');
///   }
/// } on NeshanApiError catch (e) {
///   print('Error: ${e.message}');
/// } finally {
///   service.dispose();
/// }
/// ```
class NeshanSearchService extends NeshanApiService {
  /// Creates a [NeshanSearchService] instance.
  ///
  /// [apiKey] - The Neshan API key for search service.
  /// [client] - Optional HTTP client for making requests. If not provided,
  ///            a default client will be created.
  /// [timeout] - Optional timeout duration for API requests. Defaults to 10 seconds.
  /// [logger] - Optional logger for debug output.
  NeshanSearchService({
    required super.apiKey,
    super.client,
    super.timeout,
    super.logger,
  });

  /// Base URL for Neshan Search API.
  static const String _baseUrl = 'https://api.neshan.org/v1/search';

  /// Searches for locations based on a search term and reference point.
  ///
  /// [term] - The search query (e.g., "میدان آزادی", "خیابان ولیعصر").
  /// [lat] - Latitude of the reference point (usually current map center).
  /// [lng] - Longitude of the reference point (usually current map center).
  ///
  /// Returns a [SearchResponse] containing up to 30 results, sorted by distance
  /// from the reference point.
  ///
  /// Throws [NeshanApiError] if the request fails. The specific error type
  /// depends on the failure reason:
  /// - [NetworkError] - Network connection failed or timeout
  /// - [InvalidApiKeyError] - API key is invalid or missing
  /// - [CoordinateParseError] - Coordinates are invalid
  /// - [RateLimitExceededError] - Rate limit exceeded
  /// - [ApiServiceError] - API service configuration error
  /// - [NotFoundError] - No results found for the search term
  /// - [InvalidArgumentError] - Invalid request parameters
  /// - [ParseError] - Response parsing failed
  /// - [UnknownError] - Unknown or unexpected error
  Future<SearchResponse> search(String term, double lat, double lng) async {
    // Construct the URL with query parameters
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'term': term,
        'lat': lat.toString(),
        'lng': lng.toString(),
      },
    );

    return makeRequest(
      uri: uri,
      parser: (json) => SearchResponse.fromJson(json),
      requestDescription: 'Search request for: "$term" near ($lat, $lng)',
    );
  }
}
