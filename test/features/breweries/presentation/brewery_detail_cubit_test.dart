import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_test/features/breweries/domain/exceptions/brewery_exception.dart';
import 'package:forest_test/features/breweries/domain/repositories/brewery_repository.dart';
import 'package:forest_test/features/breweries/presentation/bloc/brewery_detail/brewery_detail_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockBreweryRepository extends Mock implements BreweryRepository {}

void main() {
  late MockBreweryRepository repository;

  setUp(() => repository = MockBreweryRepository());

  blocTest<BreweryDetailCubit, BreweryDetailState>(
    'emits Loading then Loaded when the brewery is found',
    setUp: () =>
        when(() => repository.getBrewery('id-1'))
            .thenAnswer((_) async => brewery(1)),
    build: () => BreweryDetailCubit(repository),
    act: (cubit) => cubit.load('id-1'),
    expect: () => [
      const BreweryDetailLoading(),
      BreweryDetailLoaded(brewery(1)),
    ],
  );

  blocTest<BreweryDetailCubit, BreweryDetailState>(
    'emits a retryable Failure on network errors',
    setUp: () =>
        when(() => repository.getBrewery('id-1'))
            .thenThrow(const NetworkException()),
    build: () => BreweryDetailCubit(repository),
    act: (cubit) => cubit.load('id-1'),
    expect: () => [
      const BreweryDetailLoading(),
      isA<BreweryDetailFailure>().having((s) => s.canRetry, 'canRetry', true),
    ],
    errors: () => [isA<NetworkException>()],
  );

  blocTest<BreweryDetailCubit, BreweryDetailState>(
    'emits a non-retryable Failure when the brewery does not exist',
    setUp: () =>
        when(() => repository.getBrewery('gone'))
            .thenThrow(const BreweryNotFoundException('gone')),
    build: () => BreweryDetailCubit(repository),
    act: (cubit) => cubit.load('gone'),
    expect: () => [
      const BreweryDetailLoading(),
      isA<BreweryDetailFailure>().having((s) => s.canRetry, 'canRetry', false),
    ],
    errors: () => [isA<BreweryNotFoundException>()],
  );

  blocTest<BreweryDetailCubit, BreweryDetailState>(
    'goes back to Loading when retrying after a failure',
    setUp: () =>
        when(() => repository.getBrewery('id-1'))
            .thenAnswer((_) async => brewery(1)),
    build: () => BreweryDetailCubit(repository),
    seed: () => const BreweryDetailFailure('boom', canRetry: true),
    act: (cubit) => cubit.load('id-1'),
    expect: () => [
      const BreweryDetailLoading(),
      BreweryDetailLoaded(brewery(1)),
    ],
  );
}
