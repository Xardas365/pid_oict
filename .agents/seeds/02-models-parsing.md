# Seed 02 — Domain models and JSON parsing

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/assignment.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- relevant files under `lib/src/`
- existing tests under `test/`

Task:

Implement the app data models and robust JSON parsing.

Create models for:

1. `Stop`
   - stable ID,
   - human-readable name,
   - optional platform/code,
   - optional latitude/longitude.
2. `Departure`
   - route or line short name,
   - headsign/destination,
   - departure time,
   - optional delay,
   - optional platform,
   - optional vehicle ID.
3. `VehiclePosition`
   - vehicle ID,
   - latitude,
   - longitude,
   - optional bearing,
   - optional last updated timestamp.

Parsing rules:

- tolerate missing optional fields,
- parse dates safely,
- parse numeric values safely,
- support GeoJSON coordinates in `[longitude, latitude]` order,
- skip or safely reject records that miss required data,
- do not let malformed API records crash the app.

Add at least one unit test for parsing. Prefer tests for GeoJSON coordinate order if practical.

Do not implement repositories or UI in this step.

Run:

```bash
dart format .
flutter analyze
flutter test
```

If code generation is introduced or changed, run first:

```bash
dart run build_runner build
```

Output:

- changed files,
- model fields and assumptions,
- checks run and results.
