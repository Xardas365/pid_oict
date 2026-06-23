# Architecture Context — OICT PID Flutter

## Current Direction

The MVP is functionally complete. The post-MVP direction is a more senior but
still pragmatic Flutter implementation using:

* `flutter_bloc` as the single state-management package,
* Dio as the target HTTP client for the app-owned API layer,
* Freezed and `json_serializable` for generated immutable models/states and
  JSON mapping where they reduce boilerplate,
* Slang for Czech and English user-facing strings,
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

* `dio` for the target Golemio REST client, interceptors, timeout handling, and
  safe debug logging.
* `flutter_bloc` for state management.
* `flutter_map` for map rendering without a Google Maps key.
* `latlong2` for map coordinates when using `flutter_map`.
* `freezed_annotation` and `json_annotation` for generated models, DTOs, and
  Bloc state when the extra structure improves reviewability.
* `slang` and `slang_flutter` for app localization. The `pid_seeds`
  package may use `slang` for its own package-local fallback strings.
* `flutter_lints` or a stricter analyzer package for linting.

Allowed dev dependencies:

* Flutter test tooling.
* `build_runner`, `freezed`, and `json_serializable` for code generation.
* `bloc_test` only if it materially improves Bloc/Cubit tests.
* `mocktail` only if handwritten fakes become too costly.

Do not add:

* Riverpod,
* Provider,
* GetX,
* service locator packages,
* generated or third-party Golemio Dart API clients,
* map SDKs that require extra API keys.

## Platform Scope

This repository is an Android-only showcase for the OICT/Golemio assignment.

Keep only the Android Flutter platform unless the assignment scope explicitly
changes. Do not restore or maintain:

* `ios/`,
* `macos/`,
* `linux/`,
* `web/`,
* `windows/`.

README, build commands, CI, and verification notes should describe Android
only. Cross-platform helper scripts may remain for local developer convenience
when they do not imply app platform support.

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

Code generation is part of the approved post-MVP architecture for selected
models, DTOs, and Bloc state classes. Use it pragmatically where it reduces
manual boilerplate or parsing risk.

Generated files must not be edited manually:

* `lib/i18n/strings.g.dart`
* `lib/i18n/strings_*.g.dart`
* `packages/pid_seeds/lib/i18n/pid_seed_strings.g.dart`
* `packages/pid_seeds/lib/i18n/pid_seed_strings_*.g.dart`
* `*.freezed.dart`
* `*.g.dart`

If root app localization JSON files change, run:

```bash
dart run slang
```

If `pid_seeds` localization JSON files change, run:

```bash
cd packages/pid_seeds
dart run slang
cd ../..
```

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

User-facing app text belongs in Slang translations under `lib/i18n/` with both
Czech and English values. User-facing fallback text inside the local
`pid_seeds` package belongs under `packages/pid_seeds/lib/i18n/`. Technical
constants such as endpoint paths, JSON field names, and internal exception
debug messages may remain as Dart strings.

Shared reusable widgets are encouraged, but do not create a broad design system
unless it removes real duplication.

## Map Rules

* Use `flutter_map`.
* Convert GeoJSON `[longitude, latitude]` into map `[latitude, longitude]`.
* Center the map on the first valid vehicle position.
* Keep the last known marker on refresh failure.
* Cancel polling timers/subscriptions when leaving the screen or closing Bloc.
* Avoid overlapping refresh requests.
