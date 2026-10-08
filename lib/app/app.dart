import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_router.dart';

class BreweryApp extends StatelessWidget {
  const BreweryApp({super.key, required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breweries',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: router.initialRoute,
      onGenerateInitialRoutes: router.onGenerateInitialRoutes,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
