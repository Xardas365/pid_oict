# Implementation Plan - OICT Praha Flutter PID App

Use this only for planning. Implement one phase at a time.

## Phase 1 - Skeleton and Configuration

* Create or validate Flutter project.
* Add feature-first folders.
* Add dependencies with justification.
* Add API token configuration through `GOLEMIO_API_TOKEN`.
* Add central Golemio API client and error model.

Checks:

```bash
dart format .
flutter analyze
flutter test
```

## Phase 2 - Models and Repositories

* Add Stop, Departure, and VehiclePosition DTO/domain models.
* Add robust JSON parsing.
* Implement repositories for stops, departure boards, and vehicle positions.
* Add parser/repository tests with fixtures or mocked client.

Run code generation first if generated models are used.

## Phase 3 - Stop List Screen

* Load stops.
* Show loading/error/empty/success states.
* Add local search/filter by stop name.
* Navigate to departures for selected stop.

## Phase 4 - Departures Screen

* Load departures for selected stop.
* Show line, destination, time, delay, and map action.
* Add pull-to-refresh.
* Hide or disable map action when vehicle ID is missing.

## Phase 5 - Vehicle Map Screen

* Load first vehicle position.
* Show map and marker.
* Center map on first valid position.
* Refresh periodically.
* Cancel polling in `dispose`.
* Keep last valid position on refresh failure.

## Phase 6 - UX Polish and Tests

* Reuse loading/error/empty widgets.
* Improve user-facing messages.
* Add tests for parsing/filtering/error handling.
* Check no real API calls are used in tests.

## Phase 7 - README and Final Check

* Complete README.
* Remove debug prints, dead code, and irrelevant TODOs.
* Verify no token is committed.
* Run final checks.
