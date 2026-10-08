import 'package:flutter_test/flutter_test.dart';
import 'package:forest_test/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<OnboardingRepositoryImpl> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return OnboardingRepositoryImpl(await SharedPreferences.getInstance());
  }

  test('is not completed on a fresh install', () async {
    final repository = await repositoryWith({});

    expect(repository.isCompleted, isFalse);
  });

  test('is completed after markCompleted', () async {
    final repository = await repositoryWith({});

    await repository.markCompleted();

    expect(repository.isCompleted, isTrue);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(OnboardingRepositoryImpl.completedKey), isTrue);
  });

  test('remembers a previous completion', () async {
    final repository = await repositoryWith({
      OnboardingRepositoryImpl.completedKey: true,
    });

    expect(repository.isCompleted, isTrue);
  });
}
