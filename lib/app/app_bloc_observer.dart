import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Every Bloc/Cubit reports handled failures with `addError`, so this is the
/// single place to forward them to a crash reporter such as Sentry
/// (`Sentry.captureException(error, stackTrace: stackTrace)`).
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} error: $error');
    super.onError(bloc, error, stackTrace);
  }
}
