# PID OICT Golemio Flutter

Small Flutter app for the OICT Praha / Golemio PID assignment. It shows Prague
public transport stops, stop departures, and the current position of a selected
vehicle on a map.

Tested with Flutter 3.44.1 and Dart 3.12.1.

## Features

- Stops list loaded from Golemio.
- Local stop search by stop name.
- Departures for the selected stop.
- Pull-to-refresh on the departures screen.
- Vehicle map for departures that include a usable GTFS trip ID.
- Periodic vehicle position refresh every 15 seconds.
- Loading, error, and empty states on the main screens.
- Offline unit and widget tests using local maps, fakes, and mocked HTTP.

## API Setup

The app uses the Golemio API at:

```text
https://api.golemio.cz
```

Provide the API token at run or build time with:

```bash
--dart-define=GOLEMIO_API_TOKEN=your_token_here
```

The token is sent in the `x-access-token` HTTP header. Do not hardcode it in
Dart code, store it in committed files, or commit local environment files.

## Setup

Install dependencies:

```bash
flutter pub get
```

## Run

```bash
flutter run --dart-define=GOLEMIO_API_TOKEN=your_token_here
```

## Local run with API token

For local development, keep your real token in an ignored local env file:

1. Copy `.env.example` to `.env.local`.
2. Put your real Golemio token into `.env.local`.
3. Run with your IDE, the direct Flutter command, or the helper for your shell.

Android Studio:

1. Open the project.
2. Select the run configuration `OICT PID - local token`.
3. Run the app.

If the shared configuration is not visible, create a Flutter run configuration
manually:

- Dart entrypoint: `lib/main.dart`
- Additional run args: `--dart-define-from-file=.env.local`

VS Code:

1. Open Run and Debug.
2. Select `OICT PID - local token`.
3. Run the app.

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

`.env.local` is ignored by Git and must not be committed. Only `.env.example`
with `GOLEMIO_API_TOKEN=your_token_here` is committed. The direct
`flutter run --dart-define=GOLEMIO_API_TOKEN=your_token_here` command above is
still supported as an alternative.

## Build

This showcase supports Android only. The non-Android Flutter platform folders
are intentionally not maintained in this repository.

```bash
flutter build apk --dart-define=GOLEMIO_API_TOKEN=your_token_here
```

## Verification

```bash
dart format .
flutter analyze
flutter test
```

If Freezed or JSON-serializable source files change, run code generation before
analysis and tests:

```bash
dart run build_runner build
```

If localization files under `lib/i18n/*.i18n.json` change, regenerate Slang
translations before analysis and tests:

```bash
dart run slang
```

If localization files under `packages/pid_seeds/lib/i18n/*.i18n.json` change,
regenerate that package too:

```bash
cd packages/pid_seeds
dart run slang
cd ../..
```

The tests are offline. They do not call the real Golemio API and do not require
`GOLEMIO_API_TOKEN`.

## Dependencies

- `dio`: REST HTTP requests to the Golemio API, timeout handling, and safe
  debug request/response diagnostics.
- `flutter_map`: OpenStreetMap-based map rendering without a Google Maps key.
- `latlong2`: latitude/longitude value type used by `flutter_map`.
- `pid_seeds`: local PID UI seed package used for theme and reusable UI
  components.
- `freezed_annotation` / `json_annotation`: annotation packages for the
  approved generated model/state migration.
- `build_runner`, `freezed`, `json_serializable`: code generation tooling.
- `slang` / `slang_flutter`: type-safe Czech and English app localization.
- `flutter_localizations`: Flutter Material localization delegates.

The current runtime still contains manual DTO/domain parsing in several places.
The generator toolchain is available for the planned incremental Freezed/JSON
mapping migration.

## Architecture

- `lib/src/core/config`: base URL and token configuration.
- `lib/src/core/network`: Dio-based Golemio API client, JSON decoding, HTTP status,
  timeout, and network error handling.
- `lib/src/core/errors`: shared application exception types.
- `lib/src/features/stops`: stop DTO/domain model, repository, filtering, and
  stops screen.
- `lib/src/features/departures`: departure DTO/domain model, repository, and
  departure board screen.
- `lib/src/features/vehicle_map`: vehicle position DTO/domain model,
  repository, and map screen with polling.
- `lib/src/shared/widgets`: reusable loading, error, empty, and centered state
  widgets.
- `lib/src/shared/utils`: JSON parsing, user-facing error text, and small date
  formatting helpers.
- `lib/i18n`: Czech and English Slang translation sources and generated typed
  accessors.
- `packages/pid_seeds/lib/i18n`: package-local Czech and English fallback
  strings for reusable PID UI widgets.

DTOs parse Golemio response shapes and convert to small domain models used by
repositories and widgets. Repositories skip invalid records and surface
controlled `AppException` errors.

## Known Limitations

- The departure board stop filter parameter is isolated as `ids[]`; it should
  be live-verified against the current Golemio documentation before final
  submission if documentation access is available.
- The vehicle map action is available only for departures with a usable
  `gtfsTripId`. The selected trip is requested through
  `/v2/vehiclepositions/{gtfsTripId}` with vehicle-position query options.
- Map tiles require network access.
- Vehicle polling preserves the last known position after a refresh failure,
  but it does not implement background updates or push updates.
- Tests use local/fake data and mocked HTTP instead of the real API.

## Troubleshooting

- Missing token: run or build with
  `--dart-define=GOLEMIO_API_TOKEN=your_token_here`.
- Unauthorized or invalid token: check that the Golemio token is valid and has
  access to the used endpoints.
- Network failure or timeout: verify internet connectivity and retry from the
  in-app error state.
- Empty departures: the selected stop may have no current departures, the stop
  filter parameter may need live verification, or the API response may contain
  no usable records.
- No vehicle map action: the departure did not include a usable GTFS trip ID.
- Vehicle position unavailable: the vehicle may not have a current public
  position, or the API returned no usable coordinates.
- Map tiles do not load: verify network access to OpenStreetMap tile servers.
