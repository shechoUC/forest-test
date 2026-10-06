import '../../domain/exceptions/brewery_exception.dart';

/// Maps a domain failure to text the user can act on.
String userMessageFor(BreweryException exception) => switch (exception) {
  NetworkException() =>
    'Could not reach the server. Check your connection and try again.',
  BreweryNotFoundException() => 'This brewery no longer exists.',
  ServerException(:final statusCode) =>
    'The server had a problem (${statusCode ?? 'unknown'}). Try again later.',
  DataParsingException() =>
    'We received data we could not read. Try again later.',
};
