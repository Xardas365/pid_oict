# Assignment Context — OICT PID Flutter

## Project goal

Build a small Flutter mobile app for the OICT Praha assignment. The app presents Prague Integrated Transport data and demonstrates:

* clean Flutter/Dart code,
* good REST API handling,
* understandable architecture,
* clear loading, empty, and error states,
* safe API token handling,
* a usable map screen with live-ish vehicle position refresh.

Do not over-engineer the solution. It should look like a small but professionally structured interview or take-home assignment.

## Mandatory requirements

The app must include three main screens.

### 1. Stop list screen

* Load stops from `GET https://api.golemio.cz/v2/gtfs/stops`.
* Display a scrollable list of public transport stops.
* Support local search/filtering by stop name.
* Tapping a stop opens the departure board screen for that stop.

### 2. Departures screen

* Load departures from `GET https://api.golemio.cz/v2/public/departureboards`.
* Use the selected stop to filter the departure board. Verify the exact query parameter in the current Golemio documentation before implementation.
* Display basic departure data, such as route/line, destination/headsign, scheduled or predicted departure time, platform when available, and delay when available.
* Add pull-to-refresh.
* For departures with a usable vehicle ID, show an action that opens the vehicle map screen.
* For departures without a usable vehicle ID, hide the map action or show a disabled action with a clear explanation.

### 3. Vehicle map screen

* Load vehicle position from `GET https://api.golemio.cz/v2/public/vehiclepositions/{vehicleId}`.
* Include query parameter `scopes=info`.
* Display a map with a marker for the current vehicle position.
* Refresh the vehicle position periodically.
* Cancel timers/subscriptions when leaving the screen.
* Preserve the last known position if a refresh fails.
* Show the last update time when available.

## API token requirement

* Send the token in the `x-access-token` header.
* Do not hardcode the token in Dart source code.
* Do not commit the token to the repository.
* Prefer `--dart-define=GOLEMIO_API_TOKEN=...` for local run/build commands.
* Missing or invalid token must produce a user-friendly error state.

## Strongly expected quality requirements

Although some of these may be optional in the assignment, treat them as expected for a polished submission:

* loading state,
* error state with retry where useful,
* empty state,
* at least one unit or widget test,
* clear README with setup, run, build, token, and test instructions.

## UX acceptance criteria

* The app must not look broken while loading, empty, or offline.
* Error messages should explain what happened in user-friendly language.
* User actions should give immediate feedback.
* The stop list search should feel responsive.
* The departure list should be readable at a glance.
* The map should clearly show whether the vehicle position is current, stale, unavailable, or loading.

## Navigation

Use simple navigation. Flutter's built-in `Navigator` is acceptable. `go_router` is acceptable only if it keeps the route setup minimal.

Suggested routes if using a router:

* `/` or `/stops`
* `/stops/:stopId/departures`
* `/vehicles/:vehicleId/map`

Do not introduce complex nested navigation.
