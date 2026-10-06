import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_test/features/breweries/data/datasources/brewery_remote_data_source.dart';
import 'package:forest_test/features/breweries/data/models/brewery_dto.dart';
import 'package:forest_test/features/breweries/data/repositories/brewery_repository_impl.dart';
import 'package:forest_test/features/breweries/domain/entities/brewery.dart';
import 'package:forest_test/features/breweries/domain/exceptions/brewery_exception.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockRemoteDataSource extends Mock implements BreweryRemoteDataSource {}

void main() {
  late MockRemoteDataSource remote;
  late BreweryRepositoryImpl repository;

  setUp(() {
    remote = MockRemoteDataSource();
    repository = BreweryRepositoryImpl(remote);
  });

  DioException dioError(DioExceptionType type, {int? statusCode}) {
    final options = RequestOptions(path: '/breweries');
    return DioException(
      requestOptions: options,
      type: type,
      response: statusCode == null
          ? null
          : Response(requestOptions: options, statusCode: statusCode),
    );
  }

  test('maps DTOs to entities', () async {
    when(() => remote.fetchBreweries(page: 1, perPage: 20))
        .thenAnswer((_) async => [BreweryDto.fromJson(breweryJson())]);

    final result = await repository.getBreweries(page: 1, perPage: 20);

    expect(result.single.name, 'Dog Days Brewing');
    expect(result.single.type, BreweryType.brewpub);
    expect(result.single.city, 'Bremerton');
  });

  test('throws NetworkException on connection errors', () {
    when(() => remote.fetchBreweries(page: 1, perPage: 20))
        .thenThrow(dioError(DioExceptionType.connectionError));

    expect(
      repository.getBreweries(page: 1, perPage: 20),
      throwsA(isA<NetworkException>()),
    );
  });

  test('throws BreweryNotFoundException on 404 for a single brewery', () {
    when(() => remote.fetchBrewery('missing'))
        .thenThrow(dioError(DioExceptionType.badResponse, statusCode: 404));

    expect(
      repository.getBrewery('missing'),
      throwsA(
        isA<BreweryNotFoundException>().having((e) => e.id, 'id', 'missing'),
      ),
    );
  });

  test('throws ServerException with the status code on other errors', () {
    when(() => remote.fetchBreweries(page: 1, perPage: 20))
        .thenThrow(dioError(DioExceptionType.badResponse, statusCode: 503));

    expect(
      repository.getBreweries(page: 1, perPage: 20),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'status', 503),
      ),
    );
  });

  test('throws DataParsingException on malformed payloads', () {
    when(() => remote.fetchBreweries(page: 1, perPage: 20))
        .thenThrow(const FormatException('bad'));

    expect(
      repository.getBreweries(page: 1, perPage: 20),
      throwsA(isA<DataParsingException>()),
    );
  });
}
