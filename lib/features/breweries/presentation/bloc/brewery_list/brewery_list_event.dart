part of 'brewery_list_bloc.dart';

sealed class BreweryListEvent extends Equatable {
  const BreweryListEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page. Dispatched when the screen opens.
final class BreweryListStarted extends BreweryListEvent {
  const BreweryListStarted();
}

/// Reloads the first page for the current query after a full-screen error.
final class BreweryListRetried extends BreweryListEvent {
  const BreweryListRetried();
}

/// The user scrolled near the end, or tapped retry on a failed page.
final class BreweryListNextPageRequested extends BreweryListEvent {
  const BreweryListNextPageRequested();
}

/// The search text changed. Debounced; an empty query shows the full list.
final class BreweryListSearchChanged extends BreweryListEvent {
  const BreweryListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
