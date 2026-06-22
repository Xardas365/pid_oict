# Seed 03 — Repository layer

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- API client and models created in previous steps
- relevant tests

Task:

Implement repositories that hide Golemio API details from UI.

Repositories:

1. `StopsRepository`
   - calls `GET /v2/gtfs/stops`,
   - returns `List<Stop>`.
2. `DeparturesRepository`
   - calls `GET /v2/public/departureboards`,
   - accepts selected `Stop`,
   - verifies or isolates the exact stop filtering query parameter,
   - returns `List<Departure>`.
3. `VehiclePositionRepository`
   - calls `GET /v2/public/vehiclepositions/{vehicleId}`,
   - returns `VehiclePosition` or a controlled no-position error/state.

Rules:

- Repositories must not import Flutter widgets.
- Do not invent undocumented query parameters silently.
- If the departure board query parameter is uncertain, isolate it in one place and document the assumption.
- Convert API/client exceptions into domain-friendly errors.
- Add an offline test with mocked/fake API client if practical.
- Do not implement screens in this step.

Run:

```bash
dart format .
flutter analyze
flutter test
```

Output:

- changed files,
- endpoint assumptions,
- checks run and results,
- risks that must be verified against live Golemio documentation or sampled API responses.
