# Seed 05 — Departures screen

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/assignment.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- `DeparturesRepository`
- current navigation files

Task:

Implement the departures screen for a selected stop.

Requirements:

1. Create `DeparturesScreen`.
2. Accept a selected `Stop`.
3. Load departures through `DeparturesRepository`.
4. Display at least:
   - route/line,
   - headsign/destination,
   - departure time,
   - delay if available,
   - platform if available.
5. Show loading, error, empty, and success states.
6. Add `RefreshIndicator` for pull-to-refresh.
7. If a departure has a reliable `vehicleId`, show an action to open `VehicleMapScreen`.
8. If a departure has no reliable `vehicleId`, hide the map action or disable it with a clear explanation.
9. Do not add periodic map refresh in this step.

Run:

```bash
dart format .
flutter analyze
flutter test
```

Output:

- changed files,
- vehicle ID field assumption,
- checks run and results.
