/// Base sealed class for all Neshan API errors.
///
/// This sealed class hierarchy provides type-safe error handling for all
/// Neshan APIs (reverse geocoding, search, etc.). Each error type corresponds
/// to specific HTTP error codes returned by the APIs.
///
/// Based on Neshan API error codes:
/// - Reverse Geocoding: https://platform.neshan.org/docs/api/reverse-geocoding/
/// - Search: https://platform.neshan.org/docs/api/search-category/search/
sealed class NeshanApiError {
  /// Creates a [NeshanApiError] with a message and optional details.
  const NeshanApiError(this.message, {this.details});

  /// The error message.
  final String message;

  /// Optional additional details about the error.
  final String? details;

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Network-related error (connection failed, timeout, etc.).
class NetworkError extends NeshanApiError {
  /// Creates a [NetworkError] instance.
  const NetworkError(super.message, {super.details});
}

/// Invalid or missing API key error (HTTP 480).
///
/// Occurs when:
/// - The API key is invalid
/// - The API key is not provided in the request header
class InvalidApiKeyError extends NeshanApiError {
  /// Creates an [InvalidApiKeyError] instance.
  const InvalidApiKeyError(super.message, {super.details});
}

/// Invalid coordinate parameters error (HTTP 470).
///
/// Occurs when the latitude or longitude values are invalid.
class CoordinateParseError extends NeshanApiError {
  /// Creates a [CoordinateParseError] instance.
  const CoordinateParseError(super.message, {super.details});
}

/// Rate limit exceeded error (HTTP 481, 482).
///
/// Occurs when:
/// - HTTP 481: Total API call limit exceeded
/// - HTTP 482: Requests per minute limit exceeded
class RateLimitExceededError extends NeshanApiError {
  /// Creates a [RateLimitExceededError] instance.
  const RateLimitExceededError(super.message, {super.details});
}

/// API service configuration error (HTTP 483, 484, 485).
///
/// Occurs when:
/// - HTTP 483: API key type doesn't match the service
/// - HTTP 484: API key not whitelisted for this scope
/// - HTTP 485: Service not enabled for this API key
class ApiServiceError extends NeshanApiError {
  /// Creates an [ApiServiceError] instance.
  const ApiServiceError(super.message, {super.details});
}

/// Location not found error (HTTP 404).
///
/// Occurs when no address/results are found for the given coordinates or search term.
class NotFoundError extends NeshanApiError {
  /// Creates a [NotFoundError] instance.
  const NotFoundError(super.message, {super.details});
}

/// Invalid request parameters error (HTTP 400).
///
/// Occurs when the request parameters are malformed or invalid.
class InvalidArgumentError extends NeshanApiError {
  /// Creates an [InvalidArgumentError] instance.
  const InvalidArgumentError(super.message, {super.details});
}

/// Response parsing error.
///
/// Occurs when the API response cannot be parsed as expected.
class ParseError extends NeshanApiError {
  /// Creates a [ParseError] instance.
  const ParseError(super.message, {super.details});
}

/// Unknown or unexpected error (HTTP 500 or unhandled status codes).
///
/// Occurs when an unexpected error happens that doesn't fit other categories.
class UnknownError extends NeshanApiError {
  /// Creates an [UnknownError] instance.
  const UnknownError(super.message, {super.details});
}
