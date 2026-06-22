# Seed 06 — Vehicle map screen

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/assignment.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- `VehiclePositionRepository`
- current navigation files

Task:

Implement the map screen for the current vehicle position.

Requirements:

1. Add a map dependency only if not already present. Prefer a map solution that does not require committing an extra API key.
2. Create `VehicleMapScreen`.
3. Accept `vehicleId`.
4. Load `VehiclePosition` through `VehiclePositionRepository`.
5. Show a map with a marker at the vehicle position.
6. Convert coordinates correctly: API/GeoJSON `[longitude, latitude]` to map `latitude, longitude`.
7. Center the map on the first successful vehicle position.
8. Refresh position periodically with `Timer.periodic`.
9. Prevent overlapping refresh requests.
10. Cancel the timer in `dispose`.
11. If refresh fails, keep the last known valid position and show a non-destructive warning/hint.
12. Show last update time if available.
13. Handle no-position state gracefully.

Run:

```bash
dart format .
flutter analyze
flutter test
```

Output:

- changed files,
- dependency additions and why,
- timer lifecycle handling,
- checks run and results.
