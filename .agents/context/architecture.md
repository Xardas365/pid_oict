# Architecture Context — OICT PID Flutter

## General approach

Keep the app small and reviewable. Prefer simple, explicit code over heavy architecture.

Use a feature-first structure, with shared network/config/widgets kept under `core` or `shared`.

## Dependencies

Keep dependencies minimal and justify each addition.

Allowed or preferred dependencies:

* `http` or `dio` for REST calls. Choose one, not both.
* `flutter_map` for map rendering without a Google Maps key.
* `latlong2` for map coordinates when using `flutter_map`.
* `flutter_lints` or `very_good_analysis` for linting.

Optional dependencies when justified:

* `flutter_riverpod` for state management if the app grows beyond simple local widget state.
* `freezed_annotation` and `json_annotation` for immutable models and JSON mapping when they reduce meaningful boilerplate.
* `go_router` only if route names and deep links improve the code without adding complexity.
* `mocktail` for tests.

Allowed dev dependencies:

* Flutter test tooling,
* `build_runner` if code generation is used,
* `freezed` if Freezed is used,
* `json_serializable` if generated JSON parsing is used.

Do not add:

* Bloc,
* GetX,
* Provider when Riverpod is already used,
* service locator packages,
* generated or third-party Golemio Dart API clients,
* map SDKs that require extra API keys unless explicitly justified.

## State management

Use exactly one state-management approach.

Acceptable options:

* simple `StatefulWidget`/`FutureBuilder`/`ValueNotifier` for a small solution,
* Riverpod if it improves readability and testability.

Do not mix multiple state-management systems.

State should be easy to inspect and should explicitly represent:

* loading,
* data,
* empty,
* error,
* refreshing where useful.

Avoid unnecessary rebuilds:

* keep widgets small,
* pass only the data each widget needs,
* split large UI files into focused components.

## Code generation

Use Freezed and json_serializable only where they improve correctness or readability.

Generated files must not be edited manually:

* `*.freezed.dart`
* `*.g.dart`

If generated model files or annotations change, run:

```bash
dart run build_runner build
```

Do not introduce code generation for every trivial class.

## Recommended structure

```text
lib/
  main.dart
  app/
    pid_departures_app.dart
    router.dart
    theme.dart
  core/
    config/
      api_config.dart
    network/
      golemio_api_client.dart
      api_exception.dart
      logging_interceptor.dart
    utils/
      date_time_formatters.dart
  features/
    stops/
      data/
        stops_repository.dart
        models/
          stop_dto.dart
      domain/
        stop.dart
      presentation/
        stops_screen.dart
        widgets/
          stop_list_tile.dart
    departures/
      data/
        departures_repository.dart
        models/
          departure_dto.dart
      domain/
        departure.dart
      presentation/
        departures_screen.dart
        widgets/
          departure_tile.dart
    vehicle_map/
      data/
        vehicle_position_repository.dart
        models/
          vehicle_position_dto.dart
      domain/
        vehicle_position.dart
      presentation/
        vehicle_map_screen.dart
  shared/
    widgets/
      loading_view.dart
      error_view.dart
      empty_view.dart
test/
```

This structure is a guide, not a strict requirement. Prefer the existing project layout if one already exists.

## Data modeling

Separate raw API DTOs from domain/UI models when it improves clarity.

Recommended model types:

* `StopDto` for raw stop API data,
* `Stop` for app/domain usage,
* `DepartureDto` for raw departure board data,
* `Departure` for app/domain usage,
* `VehiclePositionDto` for raw vehicle position data,
* `VehiclePosition` for app/domain usage.

Prefer explicit mapping from DTO to domain model instead of leaking raw API responses into widgets.

## UI rules

Each screen should handle:

* initial loading,
* success,
* empty data,
* user-friendly error,
* retry where useful.

Shared reusable widgets are encouraged for loading/error/empty states, but do not create a component library larger than the assignment needs.

## Map rules

* Use `flutter_map` unless the project already has a justified map solution.
* Convert coordinates from API order to map order explicitly.
* Center the map on the first valid vehicle position.
* Keep the last known marker on refresh failure.
* Cancel polling timers when leaving the screen.
