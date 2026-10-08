import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_test/features/onboarding/domain/exceptions/onboarding_exception.dart';
import 'package:forest_test/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:forest_test/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository repository;

  setUp(() {
    repository = MockOnboardingRepository();
    when(() => repository.markCompleted()).thenAnswer((_) async {});
  });

  blocTest<OnboardingCubit, OnboardingState>(
    'moves through the tips and completes on the last one',
    build: () => OnboardingCubit(repository),
    act: (cubit) async {
      await cubit.next();
      await cubit.next();
      await cubit.next();
    },
    expect: () => const [
      OnboardingState(page: 1),
      OnboardingState(page: 2),
      OnboardingState(page: 2, completed: true),
    ],
    verify: (_) => verify(() => repository.markCompleted()).called(1),
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'follows swipes',
    build: () => OnboardingCubit(repository),
    act: (cubit) => cubit.pageChanged(2),
    expect: () => const [OnboardingState(page: 2)],
    verify: (cubit) => expect(cubit.state.isLastPage, isTrue),
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'skipping completes from any tip',
    build: () => OnboardingCubit(repository),
    act: (cubit) => cubit.complete(),
    expect: () => const [OnboardingState(completed: true)],
    verify: (_) => verify(() => repository.markCompleted()).called(1),
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'still completes and reports the error when saving fails',
    setUp: () => when(() => repository.markCompleted())
        .thenThrow(const OnboardingException('disk full')),
    build: () => OnboardingCubit(repository),
    act: (cubit) => cubit.complete(),
    expect: () => const [OnboardingState(completed: true)],
    errors: () => [isA<OnboardingException>()],
  );

  test('saves once when completing twice while the first save runs', () async {
    final save = Completer<void>();
    when(() => repository.markCompleted()).thenAnswer((_) => save.future);
    final cubit = OnboardingCubit(repository);

    final first = cubit.complete();
    final second = cubit.complete();
    save.complete();
    await Future.wait([first, second]);

    verify(() => repository.markCompleted()).called(1);
    expect(cubit.state.completed, isTrue);
    await cubit.close();
  });

  test('does not emit when closed before the save finishes', () async {
    final save = Completer<void>();
    when(() => repository.markCompleted()).thenAnswer((_) => save.future);
    final cubit = OnboardingCubit(repository);

    final pending = cubit.complete();
    await cubit.close();
    save.complete();

    await expectLater(pending, completes);
    expect(cubit.state.completed, isFalse);
  });
}
