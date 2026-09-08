/// Typed exceptions for the service layer so screens can show precise,
/// user-friendly error messages instead of raw stack traces.
library;

/// Thrown for any failure while talking to a remote API.
class ApiException implements Exception {
  /// Short, user-facing message (already localized-friendly / plain English).
  final String message;

  /// HTTP status code when the failure was an HTTP error (null otherwise).
  final int? statusCode;

  /// True when the failure was a connection/read timeout.
  final bool isTimeout;

  /// True when there was no network connectivity / socket failure.
  final bool isNetwork;

  const ApiException(
    this.message, {
    this.statusCode,
    this.isTimeout = false,
    this.isNetwork = false,
  });

  /// Factory for a request that exceeded its deadline.
  factory ApiException.timeout() => const ApiException(
        'The request timed out. Please check your connection and try again.',
        isTimeout: true,
      );

  /// Factory for a total network/socket failure (offline, DNS, etc.).
  factory ApiException.network() => const ApiException(
        'No internet connection. Showing the latest available data.',
        isNetwork: true,
      );

  /// Factory for a non-2xx HTTP response.
  factory ApiException.http(int code) => ApiException(
        'Server responded with an error ($code). Please try again shortly.',
        statusCode: code,
      );

  @override
  String toString() => 'ApiException($message, status=$statusCode, '
      'timeout=$isTimeout, network=$isNetwork)';
}
