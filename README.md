# PID OICT Golemio Flutter

Flutter showcase app for the OICT Praha public transport assignment. The app
uses the Golemio PID API to browse public Prague transit stops, show grouped
departure boards, and display the current position of a selected vehicle trip
on a map.

The repository is intentionally Android-focused. Non-Android Flutter platform
folders are not maintained for this assignment.

Project SDK constraint: Dart `^3.12.1`. The latest local verification was run
with Flutter 3.44.1 and Dart 3.12.1.

## Features

- Public-facing PID stops loaded from `/v2/gtfs/stops`.
- Paginated stop loading with `limit` and `offset`.
- API-backed stop search using `names[]`, with local fallback search.
- Conservative filtering of technical GTFS stop points before display.
- Grouped public stops, so platforms of one stop are shown as one item.
- Departure boards for grouped stop IDs.
- Departure deduplication, sorting, pull-to-refresh, periodic refresh, and
  stale-data warning.
- Vehicle tracking by departure `vehicleId` on an OpenStreetMap-based map.
- Last known vehicle position stays visible when a refresh fails.
- Public stops cache with 24-hour TTL and app-specific storage via
  `path_provider`.
- Favorite and recent stop groups persisted locally.
- Czech and English UI localization through Slang.
- Offline unit, widget, and golden tests.

## API Token

Generate a Golemio API token at:

```text
https://api.golemio.cz/api-keys
```

Pass the token at run or build time:

```bash
flutter run --dart-define=GOLEMIO_API_TOKEN=your_token_here
```

The app sends the token in the `x-access-token` HTTP header. Never hardcode a
real token, commit it, or store it in tracked files.

## Local Run With API Token

For local development, keep your real token in an ignored file:

1. Copy `.env.example` to `.env.local`.
2. Put your real token into `.env.local`.
3. Run with the CLI, helper script, or IDE template.

Direct Flutter command:

```bash
flutter run --dart-define-from-file=.env.local
```

Windows PowerShell:

```powershell
./scripts/run_local.ps1
```

Bash or Git Bash:

```bash
./scripts/run_local.sh
```

Android Studio:

1. Select the run configuration `OICT PID - local token`.
2. Run the app.

VS Code:

1. Open Run and Debug.
2. Select `OICT PID - local token`.
3. Run the app.

Only `.env.example` is committed. `.env.local` is ignored by Git.

## Build

```bash
flutter build apk --dart-define=GOLEMIO_API_TOKEN=your_token_here
```

The release build currently uses debug signing so the showcase can be built and
run locally without private signing material.

## Verification

```bash
flutter pub get
dart run slang
dart format .
flutter analyze
flutter test
git diff --check
```

Also run the project token scan used during review and confirm it returns no
real token-like strings.

Update goldens only after intentional UI changes:

```bash
flutter test --update-goldens
```

If generated model sources are changed later, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

The test suite is offline. It does not call the real Golemio API, require a real
token, or load real map tiles.

The local `pid_seeds` package can be checked separately when shared UI package
code changes:

```bash
cd packages/pid_seeds
flutter pub get
dart format .
flutter analyze
flutter test
```

## CI And Submission Hygiene

GitHub Actions runs the same review checks for the app and the local
`packages/pid_seeds` package:

- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- a JWT-like token scan that fails when a committed encoded token prefix is
  found

Before submitting or packaging the project, keep these files out of Git:

- real Golemio API tokens,
- `.env.local` and other local env files,
- `.dart_tool/`, `build/`, and `coverage/`,
- `.debug/`, runtime logs, and downloaded API samples,
- IDE caches or workspace files.

Only `.env.example` with `GOLEMIO_API_TOKEN=your_token_here` is committed. Use
`--dart-define=GOLEMIO_API_TOKEN=your_token_here`,
`--dart-define-from-file=.env.local`, or the provided local run scripts for
reviewer/developer runs.

## API Endpoints

Base URL:

```text
https://api.golemio.cz
```

Used endpoints:

- `GET /v2/gtfs/stops`
  - `limit`
  - `offset`
  - `names[]`
  - `ids[]`
  - `aswIds[]`
  - `cisIds[]`
- `GET /v2/public/departureboards`
  - grouped `stopIds`, for example
    `stopIds={"0":["U118Z101P","U118Z102P"]}`
- `GET /v2/public/vehiclepositions/{vehicleId}`
  - `scopes=info`

GTFS stops are filtered before they reach the public list because the raw feed
also contains infrastructure and technical records. Public stop points are then
grouped by `parent_station` or normalized stop name so the UI shows one stop row
with all related platform stop IDs.

## Architecture

The app uses pragmatic Clean Architecture with Flutter Bloc:

- `lib/src/core/config`: base URL, environment configuration, token access.
- `lib/src/core/network`: Dio API client, safe debug logging, JSON handling,
  status-code mapping, timeout and network error mapping.
- `lib/src/core/errors`: app-level exceptions used by repositories and UI.
- `lib/src/app`: app theme, bottom navigation shell, and explicit
  `RepositoryProvider` composition.
- `lib/src/features/stops`: GTFS stop DTO/domain parsing, public filtering,
  grouping, pagination, cache data sources, favorites/recent storage,
  `StopsCubit`, and the stops UI.
- `lib/src/features/departures`: departure DTO/domain parsing, repository,
  use case, `DeparturesBloc`, refresh/stale state, and departure board UI.
- `lib/src/features/vehicle_map`: vehicle position parsing, repository, use
  case, `VehicleMapBloc`, polling, stale state, and map UI.
- `lib/src/shared`: reusable loading/error/empty widgets, JSON parsing helpers,
  formatting helpers, and user-facing error mapping.
- `lib/i18n`: Slang source files and generated Czech/English accessors.
- `packages/pid_seeds`: local reusable PID UI/theme package.

State flow is intentionally explicit:

```text
UI -> Cubit/Bloc -> Use case -> Domain repository -> Data implementation -> Dio
```

Constructor injection and Flutter Bloc providers are used instead of service
locators.

## Cache And Saved Stops

- Public stop records that pass filtering are cached locally.
- Cache schema version is `1`.
- Cache TTL is 24 hours.
- Runtime cache files are stored in app-specific support storage via
  `path_provider`.
- Cached stops are restored immediately on startup when available.
- A background refresh updates the cache and clears stale warnings on success.
- Favorite and recent stops store stable `StopGroup.id` values plus timestamps,
  not duplicated full stop datasets.
- Recent stops are kept newest-first and capped to 10 items.

Real-time departure and vehicle-position data is not cached.

## Debugging Golemio Responses

Debug HTTP logging is disabled by default and can be enabled with:

```bash
flutter run --dart-define=GOLEMIO_API_TOKEN=your_token_here --dart-define=GOLEMIO_DEBUG_LOGS=true
```

Logs include request method, URL, query parameters, status code, duration,
bounded response preview, and parser diagnostics. The API token and sensitive
headers are redacted.

To fetch local sample responses for manual inspection:

```bash
GOLEMIO_API_TOKEN=your_token_here dart run tool/fetch_golemio_samples.dart --stop-id=U118Z101P --vehicle-id=service-3-1001
```

On PowerShell:

```powershell
$env:GOLEMIO_API_TOKEN="your_token_here"
dart run tool/fetch_golemio_samples.dart --stop-id=U118Z101P --vehicle-id=service-3-1001
```

The tool writes only under `.debug/golemio_samples/`, which is ignored by Git.

## Known Limitations

- `names[]` is not guaranteed to behave as true full-text search, so the app
  keeps a local fallback over loaded/cached groups.
- Manual runtime verification requires a valid Golemio token.
- Vehicle tracking depends on a departure containing a usable `vehicleId`.
- Map tiles require network access.
- The stop cache TTL is fixed at 24 hours.
- Favorites and recent stops store group IDs; if a saved group is not present in
  the current loaded/cached stop set, it is kept in storage but not shown.
- The Android release build uses debug signing for local review only.
