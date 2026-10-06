import '../entities/brewery.dart';

/// Contract for reading breweries.
///
/// Implementations must only throw subclasses of `BreweryException`.
abstract interface class BreweryRepository {
  Future<List<Brewery>> getBreweries({required int page, required int perPage});

  Future<List<Brewery>> searchBreweries({
    required String query,
    required int page,
    required int perPage,
  });

  Future<Brewery> getBrewery(String id);
}
