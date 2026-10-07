/// Typed failures the brewery repository can throw.
///
/// Sealed so the presentation layer can map every case to a user-facing
/// message with an exhaustive `switch`.
sealed class BreweryException implements Exception {
  const BreweryException();
}

/// No connection, timeout or the request never reached the server.
final class NetworkException extends BreweryException {
  const NetworkException([this.message]);

  final String? message;

  @override
  String toString() => 'NetworkException: $message';
}

/// The requested brewery does not exist (HTTP 404).
final class BreweryNotFoundException extends BreweryException {
  const BreweryNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'BreweryNotFoundException: $id';
}

/// The server answered with an unexpected status code.
final class ServerException extends BreweryException {
  const ServerException(this.statusCode);

  final int? statusCode;

  @override
  String toString() => 'ServerException: $statusCode';
}

/// The response did not have the shape we expect.
final class DataParsingException extends BreweryException {
  const DataParsingException(this.message);

  final String message;

  @override
  String toString() => 'DataParsingException: $message';
}

/// Anything else that went wrong, e.g. a bug in a mapper. Keeps the original
/// error so it can still be reported.
final class UnknownException extends BreweryException {
  const UnknownException(this.error);

  final Object error;

  @override
  String toString() => 'UnknownException: $error';
}
