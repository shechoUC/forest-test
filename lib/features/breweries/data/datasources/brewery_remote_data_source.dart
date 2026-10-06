import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/brewery_dto.dart';

/// Raw HTTP access to Open Brewery DB. Throws [DioException] on transport
/// errors and [FormatException] on unexpected payloads; the repository
/// translates both into domain exceptions.
@lazySingleton
class BreweryRemoteDataSource {
  BreweryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<BreweryDto>> fetchBreweries({
    required int page,
    required int perPage,
  }) async {
    final response = await _dio.get<dynamic>(
      '/breweries',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return _parseList(response.data);
  }

  Future<List<BreweryDto>> searchBreweries({
    required String query,
    required int page,
    required int perPage,
  }) async {
    final response = await _dio.get<dynamic>(
      '/breweries/search',
      queryParameters: {'query': query, 'page': page, 'per_page': perPage},
    );
    return _parseList(response.data);
  }

  Future<BreweryDto> fetchBrewery(String id) async {
    final response = await _dio.get<dynamic>('/breweries/$id');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw FormatException('Expected an object, got ${data.runtimeType}');
    }
    return BreweryDto.fromJson(data);
  }

  List<BreweryDto> _parseList(Object? data) {
    if (data is! List) {
      throw FormatException('Expected a list, got ${data.runtimeType}');
    }
    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw FormatException('Expected an object, got ${item.runtimeType}');
      }
      return BreweryDto.fromJson(item);
    }).toList();
  }
}
