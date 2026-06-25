# Implementation Plan - OICT Praha Flutter PID App

Use this only for planning. Implement one phase at a time.

## Completed MVP Baseline

Seeds `00` through `10` produced the functional MVP:

* Flutter project bootstrap and OICT/Golemio rule cleanup.
* Golemio API token configuration and API client.
* Stop, Departure, and VehiclePosition DTO/domain models.
* Repositories for stops, departure boards, and vehicle positions.
* Stops, departures, and vehicle map screens.
* Loading/error/empty states.
* Offline parser/repository/widget tests.
* README and final readiness checks.

The current app may still contain simple `StatefulWidget` state from the MVP.
Future work should migrate incrementally to Flutter Bloc and pragmatic Clean
Architecture.

## Post-MVP Phase 8 - Bloc/Clean Foundation

* Add `flutter_bloc` as the single state-management package.
* Add explicit app composition using `RepositoryProvider` and `BlocProvider`.
* Keep Dio as the approved HTTP foundation. Freezed/JSON code generation is not
  currently used; add it only if a future phase clearly benefits from generated
  immutable models or parsers.
* Introduce domain repository interfaces and use case folders without changing
  behavior.
* Keep constructor injection. Do not add service locators.

Checks:

```bash
dart format .
flutter analyze
flutter test
```

## Post-MVP Phase 9 - Feature Bloc Migrations

Migrate one feature at a time:

1. Stops loading/search/selection.
2. Departures loading/retry/pull-to-refresh/vehicle selection.
3. Vehicle map loading/polling/stale-position behavior.

Each migration must preserve existing behavior and tests must remain offline.

## Post-MVP Phase 10 - Developer Observability

* Migrate or adapt the API client toward Dio and add safe debug HTTP logging.
* Add local API sample tooling that writes only ignored debug artifacts.
* Add parser/repository diagnostics for skipped records.
* Never log or commit real tokens.

## Post-MVP Phase 11 - UI Seed Package and Hardening

* Add reusable UI/polish prompts for future focused work.
* Keep no fake production data.
* Add CI/final hardening only after the Bloc migration and diagnostics are
  stable.

## Non-Goals Unless Separately Requested

* No Riverpod, Provider, GetX, Bloc alternatives, or service locator packages.
* No generated Golemio client.
* No endpoint parameter changes without proof from Golemio docs/API.
* No non-Android platform support unless the assignment scope changes.
