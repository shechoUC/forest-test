part of 'brewery_detail_cubit.dart';

sealed class BreweryDetailState extends Equatable {
  const BreweryDetailState();

  @override
  List<Object?> get props => [];
}

final class BreweryDetailLoading extends BreweryDetailState {
  const BreweryDetailLoading();
}

final class BreweryDetailLoaded extends BreweryDetailState {
  const BreweryDetailLoaded(this.brewery);

  final Brewery brewery;

  @override
  List<Object?> get props => [brewery];
}

final class BreweryDetailFailure extends BreweryDetailState {
  const BreweryDetailFailure(this.message, {required this.canRetry});

  final String message;

  /// False when retrying cannot help, e.g. the brewery does not exist.
  final bool canRetry;

  @override
  List<Object?> get props => [message, canRetry];
}
