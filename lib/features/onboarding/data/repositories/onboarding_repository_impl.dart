import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/exceptions/onboarding_exception.dart';
import '../../domain/repositories/onboarding_repository.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._preferences);

  static const completedKey = 'onboarding_completed';

  final SharedPreferences _preferences;

  @override
  bool get isCompleted => _preferences.getBool(completedKey) ?? false;

  @override
  Future<void> markCompleted() async {
    final bool saved;
    try {
      saved = await _preferences.setBool(completedKey, true);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(OnboardingException(e), stackTrace);
    }
    if (!saved) throw const OnboardingException('setBool returned false');
  }
}
