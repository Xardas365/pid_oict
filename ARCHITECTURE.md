# Architecture

This project is a pragmatic Clean Architecture Flutter implementation for the
OICT Praha / PID Golemio assignment. The goal is not to maximize layers, but to
keep the assignment reviewable while making API, domain, state, UI, and tests
easy to reason about independently.

## High-Level Flow

```text
UI -> Bloc/Cubit -> UseCase -> Repository Interface -> Repository Impl -> RemoteDataSource -> GolemioApiClient -> Golemio API
```

The same dependency direction is used across stops, departures, and vehicle
tracking. Presentation depends on use cases and domain models. Domain defines
interfaces and entities. Data implements the interfaces and owns DTO parsing,
remote requests, and local persistence details.

## Project Shape

The app uses a feature-first structure:

```text
lib/
  main.dart
  src/
    app/
    core/
    features/
      stops/
        data/
        domain/
        presentation/
      departures/
        data/
        domain/
        presentation/
      vehicle_map/
        data/
        domain/
        presentation/
    shared/
packages/
  pid_seeds/
```

Feature-first organization keeps related API, domain, state, widgets, and tests
near each other. Shared code is kept only when it is genuinely cross-feature.

## Core Layer

`lib/src/core` contains application-wide concerns:

- configuration and `String.fromEnvironment` access for `GOLEMIO_API_TOKEN`,
- the Dio-based `GolemioApiClient`,
- `GolemioQueryParameters` for deterministic query serialization, including
  repeated array-style keys such as `names[]`,
- safe debug HTTP logging with token redaction,
- `AppException` for API/data errors and `AppFailure` for typed presentation
  errors,
- PID transport line classification and transport visual mapping.

The API token is never hardcoded. Runtime requests send it through the
`x-access-token` header.

## Data Layer

Data code owns infrastructure details:

- `RemoteDataSource` classes contain endpoint paths and request serialization,
- typed request/value objects (`StopsRequest`, `DepartureBoardRequest`,
  `VehiclePositionRequest`) build paths and query parameters,
- request objects expose queries through `GolemioQueryParameters` rather than
  hand-built endpoint strings,
- request objects guard documented API limits where the contract is known,
  such as departure board group, stop-count, limit, and time-window bounds,
- DTOs parse external JSON shapes,
- repository implementations map DTOs into domain entities,
- local data sources persist public stops cache and saved favorite/recent stop
  IDs.

Repositories no longer build raw endpoint strings directly. They call remote
data sources, then apply domain-facing rules such as public-stop filtering,
deduplication, sorting, and DTO-to-entity mapping.

## Domain Layer

Domain code contains the application rules that should not depend on Flutter or
Dio:

- entities such as stop points, grouped public stops, departures, vehicle
  positions, and vehicle IDs,
- repository interfaces,
- use cases for loading stops, refreshing/searching stop groups, saved stops,
  departure boards, and vehicle positions,
- pure helpers for stop visibility, stop grouping, departure aggregation, and
  PID line classification.

Domain entities and Bloc/Cubit states are handwritten immutable value types with
manual equality where that improves tests and state comparisons. The project
does not currently use Freezed, `json_serializable`, or `build_runner`.

Some use cases are intentionally thin. That is a trade-off: thin use cases keep
presentation isolated from repositories and make later behavior changes safer
without forcing screens or blocs to import data-layer types.

## Presentation Layer

Presentation uses `flutter_bloc` as the single app state-management approach:

- `StopsCubit` handles stop loading, search, pagination, cached restore,
  favorites, and recent stop state through use cases.
- `DeparturesBloc` handles initial loading, retry, pull-to-refresh, periodic
  refresh, transport filters, stale refresh errors, and last-updated state.
- `VehicleMapBloc` handles vehicle-position loading, polling, retry,
  no-position state, and stale marker behavior.

Realtime flows share the `RefreshTicker` abstraction. Production code uses
`TimerRefreshTicker`; tests inject fakes to avoid real timers. Departure refresh
state is further shaped by `DepartureBoardRefreshPolicy` so refresh failures
with previous data stay non-destructive.

Screens are responsible for binding bloc state to widgets and navigation
callbacks. Business and API decisions stay in use cases, repositories, data
sources, or pure helpers.

## Error Boundaries

The Dio client and data layer throw or propagate `AppException` for operational
failures such as missing token, unauthorized responses, timeout, network
failure, invalid JSON, invalid data, empty responses, and unexpected status
codes.

Bloc/Cubit code maps those failures into `AppFailure`. `AppFailure` carries a
category, message key, debug message, retryability, and optional status code.
That keeps UI states typed without exposing Dio or raw exception details to
widgets.

## API Flows

### Stops

`StopsRemoteDataSource` receives a `StopsRequest` and calls
`GET /v2/gtfs/stops` with typed query parameters:

- `limit`,
- `offset`,
- `names[]`,
- `ids[]`,
- `aswIds[]`,
- `cisIds[]`.

Responses are parsed as GTFS GeoJSON stop features. Coordinates are converted
from GeoJSON order `[longitude, latitude]` into explicit latitude/longitude
domain fields. Technical GTFS records are filtered out before public display.
Remaining public stop points are grouped into `StopGroup` values by
`parent_station` or normalized stop name.

The stops flow supports paginated loading, API-backed search, local fallback
filtering, cache restore, stale cache warnings, favorites, and recent stops.

### Departures

`DeparturesRemoteDataSource` receives a `DepartureBoardRequest` and calls
`GET /v2/public/departureboards` with grouped stop IDs from the selected
`StopGroup`. The request intentionally uses the `stopIds` query parameter, not
`stopIds[]`, with a JSON value such as `{"0":["U118Z101P","U118Z102P"]}`.

Departures are parsed, deduplicated, sorted by the best available departure
time, and enriched with route type classification. A 404 response with an empty
departure-board body is treated as an empty board rather than a fatal error.

The departure screen keeps the previous successful board visible when refresh
fails and surfaces a stale warning instead of replacing useful data with a
full-screen error.

### Vehicle Position

Vehicle tracking uses the real `vehicleId` from the departure board response.
It does not use `gtfsTripId` as the tracking path parameter. Navigation accepts
or parses a raw string at the edge, converts it into `VehicleId` through
`VehicleMapArgs`, and passes the typed value through `VehicleMapBloc`, the use
case, repository, and remote data source.

`VehiclePositionsRemoteDataSource` receives a `VehiclePositionRequest` and
calls:

```text
GET /v2/public/vehiclepositions/{vehicleId}?scopes=info
```

The response parser reads coordinates from `geometry.coordinates`, maps
metadata into `VehiclePosition`, and falls back to the request vehicle ID when
the response body does not include one. The map keeps the last known valid
marker visible if a polling refresh fails.

## Query Serialization

All Golemio request objects expose query data through
`GolemioQueryParameters`. This centralizes encoding instead of letting each
repository or request object build ad hoc query strings.

The helper supports nullable entries, deterministic encoded output for tests,
and Golemio's bracketed array parameter names. It preserves `[]` in keys such
as `names[]`, while still URL-encoding query values. Repositories do not know
endpoint strings or query formatting details.

## App Cache And Stale Data Strategy

The app-level cache policy is separate from HTTP cache headers returned by
Golemio. The app uses its own local persistence only where stale data is useful
and safe for the user experience.

Public GTFS stops are cached locally because the stop list changes relatively
slowly compared with departures or vehicle positions. The cache stores only
filtered public stop records needed to rebuild `StopGroup` values. It uses a
24-hour TTL, app-specific support storage through `path_provider`, and ignores
corrupted or unsupported cache payloads safely.

When the stops screen opens, `StopsCubit` tries to restore cached stops first.
If usable cached stops exist, it emits grouped stops immediately. Expired cache
is marked as stale, then a background API refresh is started. A successful
refresh merges fresh public stops by stop ID, rebuilds groups, updates the
cache, and clears stale warnings. If that refresh fails, cached groups remain
visible with a non-blocking warning. If no cache exists, the flow stays
network-first and an initial network failure becomes the normal retryable error
state.

Departure boards and vehicle positions are treated as real-time-like data and
are not persisted as long-term local cache. Their latest successful values live
only in Bloc state while the screen is active. Manual or periodic refreshes do
not clear useful previous data: `DeparturesBloc` keeps the previous board
visible and surfaces a stale refresh warning, while `VehicleMapBloc` keeps the
last known marker visible after a polling failure. Initial failures with no
previous data still show normal loading/error/no-position states.

Favorites and recent stops are a separate local persistence concern. They store
stable stop group IDs and small metadata instead of duplicating the full stops
dataset. Unknown saved group IDs are tolerated when the corresponding group is
not currently loaded.

Debug request logging and parser diagnostics remain developer-facing and token
safe. They do not persist API tokens, `.env.local` values, or runtime response
samples into the app cache.

## UI Composition And pid_seeds

The app uses `packages/pid_seeds` as a local Atomic Design package:

- atoms and tokens for spacing, radius, colors, type, and small primitives,
- molecules for reusable search/status/filter pieces,
- organisms/templates for larger reusable PID UI patterns where useful.

Feature screens still own feature-specific presentation and bloc wiring. Generic
PID UI pieces live in `pid_seeds` when they do not depend on app feature
models. This avoids import cycles and keeps the package reusable.

## SOLID Boundaries

The architecture applies SOLID principles pragmatically:

- Single responsibility: API clients, remote data sources, repositories, use
  cases, blocs, and widgets each have separate jobs.
- Open/closed: new API behavior can be added through request objects,
  datasources, or use cases without rewriting screens.
- Liskov/interface substitution: tests use fake repositories, data sources, and
  clients through interfaces.
- Interface segregation: stops, departures, vehicle positions, cache, and saved
  stops have separate contracts.
- Dependency inversion: presentation depends on domain use cases and repository
  interfaces, while data implements those contracts.

## Testing Strategy

The test suite is offline and deterministic. It does not require a real
`GOLEMIO_API_TOKEN`, call the live Golemio API, or load real map tiles.

Coverage includes:

- unit tests for parsing, request serialization, classification, filtering,
  grouping, deduplication, cache models, and use cases,
- repository tests with fake API clients or local JSON maps,
- Bloc/Cubit tests for loading, retry, search, pagination, refresh, stale state,
  favorites, recent stops, and polling behavior,
- widget tests for screen states and user interactions,
- integration-style widget tests for the main flow from stops to departures to
  vehicle tracking,
- golden tests for selected stable UI states,
- parser/API fixture tests under `test/fixtures/golemio`.

## Intentional Trade-Offs

- Some use cases are thin by design. They protect layer boundaries and keep
  presentation code from depending on data implementations.
- Parsers are tolerant because Golemio is an external API. Invalid records are
  skipped or mapped to controlled failures where possible, and diagnostics help
  explain skipped records.
- `pid_seeds` is local rather than published. That keeps the assignment
  self-contained while still demonstrating Atomic Design composition.
- The app is Android-focused for this showcase. Other Flutter platform folders
  are intentionally not maintained here.
