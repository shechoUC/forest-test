import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'app/app_router.dart';
import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = const AppBlocObserver();
  runApp(BreweryApp(router: AppRouter(getIt)));
}
