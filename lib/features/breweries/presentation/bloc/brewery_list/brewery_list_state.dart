part of 'brewery_list_bloc.dart';

sealed class BreweryListState extends Equatable {
  const BreweryListState({this.query = ''});

  /// The search query this state belongs to. Empty means "all breweries".
  final String query;

  @override
  List<Object?> get props => [query];
}

final class BreweryListInitial extends BreweryListState {
  const BreweryListInitial();
}

/// First page in flight; nothing to show yet.
final class BreweryListLoading extends BreweryListState {
  const BreweryListLoading({super.query});
}

/// The first page came back empty.
final class BreweryListEmpty extends BreweryListState {
  const BreweryListEmpty({super.query});
}

final class BreweryListLoaded extends BreweryListState {
  const BreweryListLoaded({
    required this.items,
    required this.page,
    required this.hasMore,
    super.query,
    this.isLoadingMore = false,
    this.nextPageError,
  });

  final List<Brewery> items;

  /// Last page successfully loaded.
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  /// Set when loading the next page failed. The loaded items stay visible
  /// and the list footer offers a retry.
  final String? nextPageError;

  BreweryListLoaded copyWith({
    List<Brewery>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? Function()? nextPageError,
  }) {
    return BreweryListLoaded(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      query: query,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextPageError: nextPageError != null
          ? nextPageError()
          : this.nextPageError,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    items,
    page,
    hasMore,
    isLoadingMore,
    nextPageError,
  ];
}

/// The first page failed. Nothing to show except the error and a retry.
final class BreweryListFailure extends BreweryListState {
  const BreweryListFailure(this.message, {super.query});

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
