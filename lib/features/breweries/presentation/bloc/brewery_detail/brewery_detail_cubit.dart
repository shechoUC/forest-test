import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/brewery.dart';
import '../../../domain/exceptions/brewery_exception.dart';
import '../../../domain/repositories/brewery_repository.dart';
import '../error_messages.dart';

part 'brewery_detail_state.dart';

@injectable
class BreweryDetailCubit extends Cubit<BreweryDetailState> {
  BreweryDetailCubit(this._repository) : super(const BreweryDetailLoading());

  final BreweryRepository _repository;

  Future<void> load(String id) async {
    emit(const BreweryDetailLoading());
    try {
      final brewery = await _repository.getBrewery(id);
      emit(BreweryDetailLoaded(brewery));
    } on BreweryException catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(
        BreweryDetailFailure(
          userMessageFor(e),
          canRetry: e is! BreweryNotFoundException,
        ),
      );
    }
  }
}
