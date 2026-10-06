import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/bloc/event_transformers.dart';
import '../../../domain/entities/brewery.dart';
import '../../../domain/exceptions/brewery_exception.dart';
import '../../../domain/repositories/brewery_repository.dart';
import '../error_messages.dart';

part 'brewery_list_event.dart';
part 'brewery_list_state.dart';

const kBreweriesPerPage = 20;
const kSearchDebounce = Duration(milliseconds: 300);

@injectable
class BreweryListBloc extends Bloc<BreweryListEvent, BreweryListState> {
  BreweryListBloc(this._repository) : super(const BreweryListInitial()) {
    on<BreweryListStarted>(
      (_, emit) => _loadFirstPage(state.query, emit),
      transformer: droppable(),
    );
    on<BreweryListRetried>(
      (_, emit) => _loadFirstPage(state.query, emit),
      transformer: droppable(),
    );
    on<BreweryListSearchChanged>(
      _onSearchChanged,
      transformer: debounceRestartable(kSearchDebounce),
    );
    // droppable: scroll events fire repeatedly while a page is in flight;
    // only the first one should trigger a request.
    on<BreweryListNextPageRequested>(
      _onNextPageRequested,
      transformer: droppable(),
    );
  }

  final BreweryRepository _repository;

  /// Incremented on every first-page load. Handlers compare it after each
  /// `await` so a response for an outdated query never overwrites the
  /// current one (e.g. page 2 of the full list arriving after a search).
  int _generation = 0;

  Future<void> _onSearchChanged(
    BreweryListSearchChanged event,
    Emitter<BreweryListState> emit,
  ) async {
    final query = event.query.trim();
    final alreadyShowing = query == state.query && state is! BreweryListFailure;
    if (alreadyShowing && state is! BreweryListInitial) return;
    await _loadFirstPage(query, emit);
  }

  Future<void> _loadFirstPage(
    String query,
    Emitter<BreweryListState> emit,
  ) async {
    final generation = ++_generation;
    emit(BreweryListLoading(query: query));
    try {
      final items = await _fetch(query: query, page: 1);
      if (generation != _generation) return;
      emit(
        items.isEmpty
            ? BreweryListEmpty(query: query)
            : BreweryListLoaded(
                items: items,
                page: 1,
                hasMore: items.length == kBreweriesPerPage,
                query: query,
              ),
      );
    } on BreweryException catch (e, stackTrace) {
      if (generation != _generation) return;
      addError(e, stackTrace);
      emit(BreweryListFailure(userMessageFor(e), query: query));
    }
  }

  Future<void> _onNextPageRequested(
    BreweryListNextPageRequested event,
    Emitter<BreweryListState> emit,
  ) async {
    final current = state;
    if (current is! BreweryListLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    final generation = _generation;
    emit(current.copyWith(isLoadingMore: true, nextPageError: () => null));
    try {
      final nextPage = current.page + 1;
      final items = await _fetch(query: current.query, page: nextPage);
      if (generation != _generation) return;
      emit(
        current.copyWith(
          items: [...current.items, ...items],
          page: nextPage,
          hasMore: items.length == kBreweriesPerPage,
          isLoadingMore: false,
          nextPageError: () => null,
        ),
      );
    } on BreweryException catch (e, stackTrace) {
      if (generation != _generation) return;
      addError(e, stackTrace);
      emit(
        current.copyWith(
          isLoadingMore: false,
          nextPageError: () => userMessageFor(e),
        ),
      );
    }
  }

  Future<List<Brewery>> _fetch({required String query, required int page}) {
    return query.isEmpty
        ? _repository.getBreweries(page: page, perPage: kBreweriesPerPage)
        : _repository.searchBreweries(
            query: query,
            page: page,
            perPage: kBreweriesPerPage,
          );
  }
}
