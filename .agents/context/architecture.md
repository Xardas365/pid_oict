# Architecture Context — OICT PID Flutter

## Current Direction

The MVP is functionally complete. The post-MVP direction is a more senior but
still pragmatic Flutter implementation using:

* `flutter_bloc` as the single state-management package,
* Cubit for simple state/actions,
* Bloc where events make flows clearer, especially loading, retry, refresh,
  search, and polling,
* pragmatic Clean Architecture with feature-first folders,
* constructor injection through Flutter Bloc `RepositoryProvider` and
  `BlocProvider`.

Do not rewrite the app in one large pass. Migrate feature by feature and keep
every step reviewable.

## Dependency Rules

Keep dependencies minimal and justify each addition.

Allowed or preferred dependencies:

* `http` for REST calls. Do not add `dio` unless there is a separate justified
  migration.
* `flutter_bloc` for state management.
* `flutter_map` for map rendering without a Google Maps key.
* `latlong2` for map coordinates when using `flutter_map`.
* `flutter_lints` or a stricter analyzer package for linting.

Allowed dev dependencies:

* Flutter test tooling.
* `bloc_test` only if it materially improves Bloc/Cubit tests.
* `mocktail` only if handwritten fakes become too costly.
* Code generation tooling only if a later task explicitly justifies it.

Do not add:

* Riverpod,
* Provider,
* GetX,
* service locator packages,
* generated or third-party Golemio Dart API clients,
* map SDKs that require extra API keys,
* code generation by default.

## State Management

Use exactly one application state-management approach: Flutter Bloc.

Use Cubit when:

* the state is mostly loaded directly by method calls,
* events would only mirror method names,
* the flow is narrow and easy to inspect.

Use Bloc when:

* separate user/system events improve clarity,
* the feature has loading, retry, refresh, search, polling, or cancellation
  paths,
* tests benefit from event-to-state assertions.

State objects should explicitly represent:

* initial/loading,
* data,
* empty,
* error,
* refreshing or stale data where useful.

Do not mix Bloc with Riverpod, Provider, GetX, or a service locator.

## Clean Architecture Shape

Use pragmatic Clean Architecture per feature. Do not add layers that do not
remove complexity.

Recommended feature structure:

```text
lib/
  main.dart
  src/
    app/
      pid_oict_app.dart
      pid_oict_shell.dart
      app_providers.dart
      app_theme.dart
    core/
      config/
      errors/
      network/
      logging/
    features/
      stops/
        data/
          datasources/
          dto/
          repositories/
        domain/
          entities/
          repositories/
          usecases/
        presentation/
          bloc/
          widgets/
          stops_screen.dart
      departures/
        data/
          datasources/
          dto/
          repositories/
        domain/
          entities/
          repositories/
          usecases/
        presentation/
          bloc/
          widgets/
          departures_screen.dart
      vehicle_map/
        data/
          datasources/
          dto/
          repositories/
        domain/
          entities/
          repositories/
          usecases/
        presentation/
          bloc/
          widgets/
          vehicle_map_screen.dart
    shared/
      widgets/
      utils/
test/
```

This is a target structure. Prefer incremental moves over mechanical churn.

## Layer Responsibilities

Domain:

* entities used by app logic and UI,
* repository interfaces,
* use cases for meaningful operations,
* no Flutter widgets,
* no HTTP package dependency,
* no DTO leakage.

Data:

* Golemio datasources using the API client,
* DTO parsing,
* DTO-to-domain mapping,
* repository implementations that satisfy domain interfaces,
* safe skipping or reporting of invalid records.

Presentation:

* Bloc/Cubit state and events,
* screens and widgets,
* local UI-only filtering/search state where appropriate,
* friendly loading/error/empty/stale states.

App composition:

* construct shared API client,
* provide repositories/use cases through `RepositoryProvider`,
* provide feature Bloc/Cubit instances through `BlocProvider`,
* keep creation explicit and reviewable.

## API and Observability

The app owns its Golemio API layer. Token handling remains:

* `String.fromEnvironment('GOLEMIO_API_TOKEN')`,
* `x-access-token` header,
* no hardcoded token,
* no committed real token.

Debug logging should be safe:

* enabled only in debug mode and/or explicit dart define,
* never log `x-access-token`,
* log method/path/query/status/duration/response-size,
* use bounded response previews,
* provide parser/repository diagnostics for skipped records where useful.

## Code Generation

Do not introduce code generation by default.

Generated files must not be edited manually:

* `*.freezed.dart`
* `*.g.dart`

If a later task explicitly adds generated models, run:

```bash
dart run build_runner build
```

Then run formatting, analysis, and tests.

## Testing Rules

Tests must be offline by default:

* no real Golemio API calls,
* no real `GOLEMIO_API_TOKEN`,
* no real map tile loading in widget tests,
* use fakes or mocked HTTP clients,
* test DTO parsing, use cases, repository implementations, and Bloc/Cubit
  state transitions.

Run for code changes:

```bash
dart format .
flutter analyze
flutter test
```

## UI Rules

Screens should keep:

* loading state,
* success state,
* empty state,
* user-friendly error with retry where useful,
* readable PID/public-transport presentation,
* no fake production data.

Shared reusable widgets are encouraged, but do not create a broad design system
unless it removes real duplication.

## Map Rules

* Use `flutter_map`.
* Convert GeoJSON `[longitude, latitude]` into map `[latitude, longitude]`.
* Center the map on the first valid vehicle position.
* Keep the last known marker on refresh failure.
* Cancel polling timers/subscriptions when leaving the screen or closing Bloc.
* Avoid overlapping refresh requests.
