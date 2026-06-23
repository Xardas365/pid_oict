# API Context — Golemio PID

## Source of truth

Use the assignment and the current Golemio PID OpenAPI documentation as the source of truth.

Known assignment endpoints:

* Base URL: `https://api.golemio.cz`
* Stops: `GET /v2/gtfs/stops`
* Departure boards: `GET /v2/public/departureboards`
* Vehicle position: `GET /v2/vehiclepositions/{gtfsTripId}`

Before implementing endpoint-specific query parameters or field mappings, verify them against the current Golemio documentation or a sampled response.

Do not use an existing generated or third-party Dart Golemio API client. Create the app's own API layer.

## Authentication

All Golemio requests require an API token.

Rules:

* Send the token as `x-access-token: <token>`.
* Prefer reading the token through `String.fromEnvironment('GOLEMIO_API_TOKEN')`.
* Local run example: `flutter run --dart-define=GOLEMIO_API_TOKEN=your_token_here`.
* Build example: `flutter build apk --dart-define=GOLEMIO_API_TOKEN=your_token_here`.
* Never hardcode a real token.
* Never commit a token to the repository.
* Do not print or log the token.
* Handle missing and invalid token states explicitly.

## API client expectations

Create one central API client responsible for:

* base URL,
* auth header,
* request timeout,
* JSON decoding,
* HTTP status handling,
* network error normalization,
* debug-only technical logging.

Recommended error categories:

* missing token,
* unauthorized or invalid token,
* network failure,
* timeout,
* not found,
* empty response,
* invalid JSON,
* invalid or missing required data.

User-facing UI must show friendly error messages. Technical details belong only in debug logs.

## DTO parsing

DTOs should reflect the API response. Domain models should contain the data the app actually needs.

Parsing rules:

* Do not assume perfect API data.
* Parse dates and numeric values safely.
* Treat optional fields as optional.
* Skip or safely mark invalid records that miss required data.
* Use explicit field mapping annotations when generated JSON mapping is used.
* Do not let API or parsing errors crash the app.

## Coordinates

Golemio responses may use GeoJSON-like coordinates.

GeoJSON coordinate order is usually:

```text
[longitude, latitude]
```

Map libraries usually expect:

```text
latitude, longitude
```

Always convert carefully and add parser tests for vehicle coordinates if possible.

## Stops endpoint

For `GET /v2/gtfs/stops`:

* parse a stable stop ID,
* parse a human-readable stop name,
* parse platform/code/zone only if available and useful,
* parse coordinates only if present and reliable,
* keep local search/filtering separate from API fetching.

## Departure boards endpoint

For `GET /v2/public/departureboards`:

* verify the exact stop filtering query parameter before implementing,
* parse route/line,
* parse headsign/destination,
* parse scheduled or predicted departure time,
* parse delay if available,
* parse GTFS trip ID only when a reliable field exists,
* do not show the map action if GTFS trip ID is missing or unusable.

Do not invent query parameters or response paths. If the API shape is uncertain, add a small adapter/parser and document the assumption.

## Vehicle positions endpoint

For `GET /v2/vehiclepositions/{gtfsTripId}`:

Required query parameters:

* `includeNotTracking=true`,
* `includePositions=true`,
* `preferredTimezone=Europe_Prague`.

Use the selected departure's `gtfsTripId` as the path segment. Parse returned
vehicle ID only as response metadata.

Also parse:

* parse latitude and longitude,
* parse bearing if available,
* parse last update timestamp if available,
* handle no-position and not-found states gracefully.

For periodic refresh:

* avoid overlapping requests,
* preserve the last known valid position on refresh failure,
* show a stale/error hint rather than clearing the map,
* cancel timers in `dispose`.
