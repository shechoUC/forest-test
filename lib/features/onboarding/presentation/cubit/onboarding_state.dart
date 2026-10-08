part of 'onboarding_cubit.dart';

final class OnboardingState extends Equatable {
  const OnboardingState({this.page = 0, this.completed = false});

  /// Index of the tip on screen.
  final int page;

  /// The user finished or skipped the tips; the app should move on.
  final bool completed;

  bool get isLastPage => page == onboardingTips.length - 1;

  OnboardingState copyWith({int? page, bool? completed}) => OnboardingState(
    page: page ?? this.page,
    completed: completed ?? this.completed,
  );

  @override
  List<Object?> get props => [page, completed];
}
