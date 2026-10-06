import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_test/features/breweries/domain/entities/brewery.dart';
import 'package:forest_test/features/breweries/domain/exceptions/brewery_exception.dart';
import 'package:forest_test/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:forest_test/features/breweries/presentation/bloc/brewery_list/brewery_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockBreweryRepository extends Mock implements BreweryRepository {}

void main() {
  late MockBreweryRepository repository;

  setUp(() => repository = MockBreweryRepository());

  void stubPage(int page, Future<List<Brewery>> Function() answer) {
    when(() => repository.getBreweries(page: page, perPage: kBreweriesPerPage))
        .thenAnswer((_) => answer());
  }

  final firstPage = breweries(kBreweriesPerPage);
  final loadedFirstPage = BreweryListLoaded(
    items: firstPage,
    page: 1,
    hasMore: true,
  );

  group('first page', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'emits Loading then Loaded when the repository succeeds',
      setUp: () => stubPage(1, () async => firstPage),
      build: () => BreweryListBloc(repository),
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [const BreweryListLoading(), loadedFirstPage],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'marks hasMore false when the page is not full',
      setUp: () => stubPage(1, () async => breweries(3)),
      build: () => BreweryListBloc(repository),
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoading(),
        BreweryListLoaded(items: breweries(3), page: 1, hasMore: false),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'emits Loading then Failure and reports the error',
      setUp: () => stubPage(1, () async => throw const NetworkException()),
      build: () => BreweryListBloc(repository),
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [
        const BreweryListLoading(),
        isA<BreweryListFailure>().having(
          (s) => s.message,
          'message',
          contains('connection'),
        ),
      ],
      errors: () => [isA<NetworkException>()],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'emits Loading then Empty when there are no results',
      setUp: () => stubPage(1, () async => []),
      build: () => BreweryListBloc(repository),
      act: (bloc) => bloc.add(const BreweryListStarted()),
      expect: () => [const BreweryListLoading(), const BreweryListEmpty()],
    );
  });

  group('pagination', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'appends the next page',
      setUp: () => stubPage(2, () async => breweries(5, from: 20)),
      build: () => BreweryListBloc(repository),
      seed: () => loadedFirstPage,
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      expect: () => [
        loadedFirstPage.copyWith(isLoadingMore: true),
        BreweryListLoaded(
          items: [...firstPage, ...breweries(5, from: 20)],
          page: 2,
          hasMore: false,
        ),
      ],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'keeps loaded items and exposes the error when the next page fails',
      setUp: () => stubPage(2, () async => throw const ServerException(500)),
      build: () => BreweryListBloc(repository),
      seed: () => loadedFirstPage,
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      expect: () => [
        loadedFirstPage.copyWith(isLoadingMore: true),
        isA<BreweryListLoaded>()
            .having((s) => s.items, 'items', firstPage)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.nextPageError, 'nextPageError', isNotNull),
      ],
      errors: () => [isA<ServerException>()],
    );

    blocTest<BreweryListBloc, BreweryListState>(
      'does nothing when there are no more pages',
      build: () => BreweryListBloc(repository),
      seed: () => loadedFirstPage.copyWith(hasMore: false),
      act: (bloc) => bloc.add(const BreweryListNextPageRequested()),
      expect: () => <BreweryListState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );
  });

  group('search', () {
    blocTest<BreweryListBloc, BreweryListState>(
      'debounces typing into a single request for the final query',
      setUp: () => when(
        () => repository.searchBreweries(
          query: 'dog',
          page: 1,
          perPage: kBreweriesPerPage,
        ),
      ).thenAnswer((_) async => breweries(2)),
      build: () => BreweryListBloc(repository),
      act: (bloc) => bloc
        ..add(const BreweryListSearchChanged('d'))
        ..add(const BreweryListSearchChanged('do'))
        ..add(const BreweryListSearchChanged('dog ')),
      wait: kSearchDebounce + const Duration(milliseconds: 100),
      expect: () => [
        const BreweryListLoading(query: 'dog'),
        BreweryListLoaded(
          items: breweries(2),
          page: 1,
          hasMore: false,
          query: 'dog',
        ),
      ],
      verify: (_) {
        verify(
          () => repository.searchBreweries(
            query: any(named: 'query'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).called(1);
      },
    );

    final slowPage2 = Completer<List<Brewery>>();
    blocTest<BreweryListBloc, BreweryListState>(
      'ignores a page that arrives after the query changed',
      setUp: () {
        stubPage(2, () => slowPage2.future);
        when(
          () => repository.searchBreweries(
            query: 'dog',
            page: 1,
            perPage: kBreweriesPerPage,
          ),
        ).thenAnswer((_) async => breweries(1));
      },
      build: () => BreweryListBloc(repository),
      seed: () => loadedFirstPage,
      act: (bloc) async {
        bloc
          ..add(const BreweryListNextPageRequested())
          ..add(const BreweryListSearchChanged('dog'));
        await Future<void>.delayed(
          kSearchDebounce + const Duration(milliseconds: 100),
        );
        slowPage2.complete(breweries(20, from: 20));
      },
      expect: () => [
        loadedFirstPage.copyWith(isLoadingMore: true),
        const BreweryListLoading(query: 'dog'),
        BreweryListLoaded(
          items: breweries(1),
          page: 1,
          hasMore: false,
          query: 'dog',
        ),
      ],
    );
  });
}
