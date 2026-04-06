import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/neshan_map_logger.dart';
import '../error/neshan_api_error.dart';

/// Abstract base class for all Neshan API services.
///
/// This class provides common HTTP client logic, error handling, and logging
/// functionality that is shared across all Neshan API services (reverse geocoding,
/// search, etc.).
///
/// Subclasses should implement the specific API endpoint logic and response parsing.
abstract class NeshanApiService {
  /// Creates a [NeshanApiService] instance.
  ///
  /// [apiKey] - The Neshan API key.
  /// [client] - Optional HTTP client for making requests. If not provided,
  ///            a default client will be created.
  /// [timeout] - Optional timeout duration for API requests. Defaults to 10 seconds.
  /// [logger] - Optional logger for debug output.
  NeshanApiService({
    required this.apiKey,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
    NeshanMapLogger? logger,
  }) : _client = client ?? http.Client(),
       _logger = logger ?? NeshanMapLogger.disabled;

  /// The Neshan API key.
  final String apiKey;

  /// HTTP client for making requests.
  final http.Client _client;

  /// Timeout duration for API requests.
  final Duration timeout;

  /// Logger for debug output.
  final NeshanMapLogger _logger;

  /// Makes an HTTP GET request and handles common error scenarios.
  ///
  /// [uri] - The URI to request.
  /// [parser] - Function to parse the JSON response into the desired type.
  /// [requestDescription] - Description of the request for logging purposes.
  ///
  /// Returns the parsed response of type [T].
  ///
  /// Throws [NeshanApiError] if the request fails.
  Future<T> makeRequest<T>({
    required Uri uri,
    required T Function(Map<String, dynamic>) parser,
    required String requestDescription,
  }) async {
    _logger.log('$requestDescription: $uri');

    try {
      // Make the HTTP request
      _logger.log('Sending HTTP request to: $uri');
      final response = await _client
          .get(uri, headers: {'Api-Key': apiKey})
          .timeout(timeout);

      _logger.log('Received response with status: ${response.statusCode}');

      // Handle the response based on status code
      return _handleResponse(response, parser);
    } on NeshanApiError {
      // Re-throw NeshanApiError as-is (already logged by _handleErrorResponse)
      rethrow;
    } on TimeoutException catch (e) {
      _logger.error('Request timeout after ${timeout.inSeconds}s', e);
      throw NetworkError(
        'Request timeout',
        details:
            'The request took longer than ${timeout.inSeconds} seconds: $e',
      );
    } on http.ClientException catch (e) {
      _logger.error('Network error', e);
      throw NetworkError(
        'Network error',
        details: 'Failed to connect to the server: $e',
      );
    } catch (e) {
      _logger.error('Unexpected error during request', e);
      throw NetworkError(
        'Network error',
        details: 'An unexpected network error occurred: $e',
      );
    }
  }

  /// Handles the HTTP response and converts it to the desired type
  /// or throws appropriate error.
  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    // Success case
    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = parser(json);
        _logger.log('Successfully parsed response');
        return result;
      } catch (e) {
        _logger.error('Failed to parse response', e);
        throw ParseError(
          'Failed to parse response',
          details: 'Could not parse API response: $e',
        );
      }
    }

    // Error cases - map HTTP status codes to specific errors
    _handleErrorResponse(response);
  }

  /// Handles error responses by throwing appropriate [NeshanApiError] subclasses.
  ///
  /// This method maps HTTP status codes to specific error types based on
  /// Neshan API documentation.
  Never _handleErrorResponse(http.Response response) {
    final errorMessage = _extractErrorMessage(response);
    _logger.error('API error (${response.statusCode}): $errorMessage', null);

    switch (response.statusCode) {
      case 400:
        throw InvalidArgumentError(
          'Invalid request parameters',
          details: errorMessage,
        );

      case 404:
        throw NotFoundError('Resource not found', details: errorMessage);

      case 470:
        throw CoordinateParseError(
          'Invalid coordinates',
          details: errorMessage,
        );

      case 480:
        throw InvalidApiKeyError(
          'Invalid or missing API key',
          details: errorMessage,
        );

      case 481:
      case 482:
        throw RateLimitExceededError(
          'Rate limit exceeded',
          details: errorMessage,
        );

      case 483:
      case 484:
      case 485:
        throw ApiServiceError('API service error', details: errorMessage);

      case 500:
        throw UnknownError('Server error', details: errorMessage);

      default:
        throw UnknownError(
          'Unexpected error (HTTP ${response.statusCode})',
          details: errorMessage,
        );
    }
  }

  /// Extracts error message from the response body if available.
  ///
  /// Tries to parse the response body as JSON and extract error information
  /// from common fields. Falls back to returning the raw body or status code.
  String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      // Try to extract message from various possible fields
      return json['message'] as String? ??
          json['error'] as String? ??
          json['description'] as String? ??
          json['Status'] as String? ??
          'HTTP ${response.statusCode}';
    } catch (_) {
      // If parsing fails, return the raw body or status code
      return response.body.isNotEmpty
          ? response.body
          : 'HTTP ${response.statusCode}';
    }
  }

  /// Disposes the HTTP client.
  ///
  /// Call this when you're done using the service to free up resources.
  /// After calling dispose, this service instance should not be used anymore.
  void dispose() {
    _client.close();
  }
}
