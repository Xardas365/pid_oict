# Seed 08 — Tests

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/assignment.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- existing tests
- implemented models, repositories, and screens

Task:

Add meaningful offline tests for the highest-risk logic.

Minimum useful tests:

1. `Stop` parsing.
2. `Departure` parsing.
3. `VehiclePosition` parsing, including GeoJSON coordinate order.
4. Stop name filtering.
5. API client or repository error handling with a fake/mocked client.

Rules:

- Tests must not call the real Golemio API.
- Tests must not require a real API token.
- Use small local JSON fixtures or inline JSON maps.
- Prefer testing parsing and pure logic over brittle widget details.
- If existing code is hard to test, make the smallest refactor needed.

Run:

```bash
dart format .
flutter analyze
flutter test
```

Output:

- changed files,
- test coverage added,
- checks run and results.
