// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:forest_test/core/network/network_module.dart' as _i407;
import 'package:forest_test/features/breweries/data/datasources/brewery_remote_data_source.dart'
    as _i971;
import 'package:forest_test/features/breweries/data/repositories/brewery_repository_impl.dart'
    as _i10;
import 'package:forest_test/features/breweries/domain/repositories/brewery_repository.dart'
    as _i797;
import 'package:forest_test/features/breweries/presentation/bloc/brewery_detail/brewery_detail_cubit.dart'
    as _i1056;
import 'package:forest_test/features/breweries/presentation/bloc/brewery_list/brewery_list_bloc.dart'
    as _i752;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i971.BreweryRemoteDataSource>(
      () => _i971.BreweryRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i797.BreweryRepository>(
      () => _i10.BreweryRepositoryImpl(gh<_i971.BreweryRemoteDataSource>()),
    );
    gh.factory<_i1056.BreweryDetailCubit>(
      () => _i1056.BreweryDetailCubit(gh<_i797.BreweryRepository>()),
    );
    gh.factory<_i752.BreweryListBloc>(
      () => _i752.BreweryListBloc(gh<_i797.BreweryRepository>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i407.NetworkModule {}
