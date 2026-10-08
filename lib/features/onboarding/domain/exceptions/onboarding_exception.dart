/// The onboarding progress could not be saved.
final class OnboardingException implements Exception {
  const OnboardingException(this.cause);

  final Object cause;

  @override
  String toString() => 'OnboardingException: $cause';
}
