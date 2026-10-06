import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

const kOpenBreweryBaseUrl = 'https://api.openbrewerydb.org/v1';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: kOpenBreweryBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
}
