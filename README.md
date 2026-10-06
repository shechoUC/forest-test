# Breweries — Forest Flutter test

Two-screen Flutter app on top of [Open Brewery DB](https://www.openbrewerydb.org/):
a paginated, searchable list of breweries and a detail screen.

## How to run

Requires Flutter stable (built with 3.47 / Dart 3.13).

```bash
flutter pub get
flutter run
```

Tests:

```bash
flutter test
```

The generated DI file (`lib/core/di/injection.config.dart`) is committed so the
project runs without code generation. After changing an `@injectable`
annotation, regenerate it with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## What I completed

**Core requirements**

- **Paginated list** (name, type, city) with loading, error, empty and
  end-of-list states. Infinite scroll loads 20 per page.
- **Detail screen** that fetches the brewery by id and shows name, address,
  phone and website. Phone and website are tappable; if a link cannot be
  opened the user gets a SnackBar instead of nothing happening.
- **Layered architecture** per feature:

  ```
  lib/
  ├── app/                  MaterialApp, router (composition root), BlocObserver
  ├── core/                 DI setup, Dio module, shared event transformers
  └── features/breweries/
      ├── domain/           Brewery entity, repository contract, typed exceptions
      ├── data/             DTO + mapping, remote data source (dio), repository impl
      └── presentation/     Bloc/Cubit with sealed states, pages, widgets
  ```

- **DI** with `get_it` + `injectable`. `AppRouter` is the only class that
  touches the service locator; pages receive their Bloc/Cubit through
  `BlocProvider` and never call `getIt`.
- **Error handling**: the repository converts `DioException` and malformed
  JSON into a sealed `BreweryException` (`NetworkException`,
  `BreweryNotFoundException`, `ServerException`, `DataParsingException`).
  Blocs catch only those types, turn them into user-facing states and report
  them via `addError`, so they all reach `AppBlocObserver`. There are no empty
  `catch` blocks.
- **Tests** (23): `bloc_test` + `mocktail` for the list Bloc (Loading → Loaded,
  Loading → Failure, empty state, pagination, a failed next page, debounce,
  stale responses) and the detail Cubit, plus repository error mapping and
  DTO parsing.

**Bonus: search with debounce**

`BreweryListSearchChanged` uses a `debounce` + `restartable` transformer
(300 ms). Rapid typing results in one request, and a request still running for
an old query is cancelled. Search results are paginated through the same flow
as the full list, and clearing the field goes back to the full list.

**UI in Forest's visual language**

The theme (`lib/core/theme`) and the shared widgets (`lib/core/widgets`) follow
the Forest app and forest.bike:

- The palette comes from the site's design tokens: pine and forest green,
  mist green, the cream background and acer orange.
- Pill buttons and cards have an outline and a hard, unblurred drop shadow.
- Titles and button labels use an upper-case heavy italic.

Forest's typefaces (GT Haptik and Mohr) are commercial, so the app uses their
closest Google Fonts matches, Figtree and Archivo Black Italic, through
`google_fonts`. The package is pinned to `^8.0.0` because v9 builds its
`TextTheme` on the new `material_ui` package, which is incompatible with
`ThemeData` from `flutter/material`.

## Decisions and trade-offs

- **Bloc for the list, Cubit for the detail.** The list has several event types
  that need different concurrency: `droppable` for "next page" (scroll fires it
  repeatedly) and `restartable` + debounce for search. A Bloc makes that
  explicit per event. The detail screen is a single load with a retry, so a
  Bloc would be ceremony.
- **Stale responses.** Concurrency transformers only apply to a single event
  type, so page 2 of the full list could still land after the user started a
  search. The Bloc keeps a generation counter that it bumps on every
  first-page load, and it drops any response from an older generation. There
  is a test that covers this.
- **A failed next page does not wipe the list.** The loaded items stay visible
  and the footer shows the error with a retry button. Only a first-page failure
  shows the full-screen error.
- **Not found is not retryable.** A 404 on the detail screen shows a message
  without a retry button; network and server errors offer a retry.
- **No use-case layer.** Every use case would have been a one-line call to the
  repository. I would add them once an operation combines several repositories
  or has its own rules.
- **A DTO separate from the entity.** The DTO absorbs the API's shape (snake_case
  keys, nullable fields, coordinates that have historically been strings or
  numbers) and validates types, so a malformed payload becomes a
  `DataParsingException` instead of a `TypeError`. Unknown brewery types map to
  `BreweryType.unknown`.
- **`Navigator` with `onGenerateRoute`** instead of go_router: two screens
  don't justify another dependency.
- **The entity is passed to the detail route**, so the app bar shows the name
  instantly while the detail request is in flight.

## What I left out intentionally

- **Sentry**: without a DSN it adds setup but no value here. Every handled
  error already goes through `AppBlocObserver.onError`, which is where
  `Sentry.captureException` would go, with `SentryFlutter.init` in `main`.
- **Map, distance and offline bonuses**: the brief asks for one bonus done
  well. Search was the best fit because it exercises `bloc_concurrency` and is
  fully testable without native setup (Mapbox token, location permissions).
- **Widget and golden tests, pixel-perfect UI, CI/CD.**

## What I would improve with more time

- Widget tests for the list (scroll-triggered pagination, footer retry) and the
  detail screen.
- Offline cache of the last successful first page (for example with
  `hydrated_bloc`, or a local data source behind the same repository).
- Sentry integration plus a dio interceptor that adds request breadcrumbs.
- Pull-to-refresh, and showing the user's distance to each brewery
  (Geolocator + Haversine).
- Localisation (the UI strings are currently hard-coded in English).
