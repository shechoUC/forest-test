import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/exceptions/onboarding_exception.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../onboarding_tips.dart';

part 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._repository) : super(const OnboardingState());

  final OnboardingRepository _repository;

  /// Guards against a double tap saving twice while the first save runs.
  bool _completing = false;

  /// The user swiped to another tip.
  void pageChanged(int page) {
    if (state.completed) return;
    emit(state.copyWith(page: page));
  }

  Future<void> next() async {
    if (state.isLastPage) return complete();
    emit(state.copyWith(page: state.page + 1));
  }

  /// Finishes the onboarding, from the last tip or by skipping it.
  Future<void> complete() async {
    if (state.completed || _completing) return;
    _completing = true;
    try {
      await _repository.markCompleted();
    } on OnboardingException catch (e, stackTrace) {
      // Not saving only means the tips show again next launch, so the user
      // still moves on.
      addError(e, stackTrace);
    }
    if (isClosed) return;
    emit(state.copyWith(completed: true));
  }
}
