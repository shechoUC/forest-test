import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../features/breweries/domain/entities/brewery.dart';
import '../features/breweries/presentation/bloc/brewery_detail/brewery_detail_cubit.dart';
import '../features/breweries/presentation/bloc/brewery_list/brewery_list_bloc.dart';
import '../features/breweries/presentation/pages/brewery_detail_page.dart';
import '../features/breweries/presentation/pages/brewery_list_page.dart';

/// Composition root for screens: the only place that resolves dependencies
/// from the service locator. Pages receive their Bloc/Cubit through
/// [BlocProvider] and never touch [GetIt].
class AppRouter {
  const AppRouter(this._getIt);

  static const breweries = '/';
  static const breweryDetail = '/brewery';

  final GetIt _getIt;

  Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      breweryDetail => _detailRoute(settings),
      _ => _listRoute(settings),
    };
  }

  Route<void> _listRoute(RouteSettings settings) => MaterialPageRoute(
    settings: settings,
    builder: (context) => BlocProvider(
      create: (_) => _getIt<BreweryListBloc>()..add(const BreweryListStarted()),
      child: BreweryListPage(
        onBreweryTap: (brewery) =>
            Navigator.of(context).pushNamed(breweryDetail, arguments: brewery),
      ),
    ),
  );

  Route<void> _detailRoute(RouteSettings settings) {
    final brewery = settings.arguments! as Brewery;
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => BlocProvider(
        create: (_) => _getIt<BreweryDetailCubit>()..load(brewery.id),
        child: BreweryDetailPage(
          breweryId: brewery.id,
          initialName: brewery.name,
        ),
      ),
    );
  }
}
