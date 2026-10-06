import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/brewery.dart';
import '../../domain/exceptions/brewery_exception.dart';
import '../../domain/repositories/brewery_repository.dart';
import '../datasources/brewery_remote_data_source.dart';

@LazySingleton(as: BreweryRepository)
class BreweryRepositoryImpl implements BreweryRepository {
  BreweryRepositoryImpl(this._remote);

  final BreweryRemoteDataSource _remote;

  @override
  Future<List<Brewery>> getBreweries({
    required int page,
    required int perPage,
  }) => _guard(() async {
    final dtos = await _remote.fetchBreweries(page: page, perPage: perPage);
    return dtos.map((dto) => dto.toEntity()).toList();
  });

  @override
  Future<List<Brewery>> searchBreweries({
    required String query,
    required int page,
    required int perPage,
  }) => _guard(() async {
    final dtos = await _remote.searchBreweries(
      query: query,
      page: page,
      perPage: perPage,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  });

  @override
  Future<Brewery> getBrewery(String id) => _guard(
    () async => (await _remote.fetchBrewery(id)).toEntity(),
    notFoundId: id,
  );

  /// Single place where transport and parsing errors become domain errors.
  Future<T> _guard<T>(Future<T> Function() call, {String? notFoundId}) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapDioException(e, notFoundId);
    } on FormatException catch (e) {
      throw DataParsingException(e.message);
    }
  }

  BreweryException _mapDioException(DioException e, String? notFoundId) {
    return switch (e.type) {
      DioExceptionType.badResponse
          when e.response?.statusCode == 404 && notFoundId != null =>
        BreweryNotFoundException(notFoundId),
      DioExceptionType.badResponse => ServerException(e.response?.statusCode),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate ||
      DioExceptionType.cancel ||
      DioExceptionType.unknown => NetworkException(e.message),
    };
  }
}
