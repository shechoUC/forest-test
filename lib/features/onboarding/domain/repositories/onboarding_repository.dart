/// Remembers whether the user has already gone through the onboarding tips.
///
/// Implementations must only throw `OnboardingException`.
abstract interface class OnboardingRepository {
  bool get isCompleted;

  Future<void> markCompleted();
}
