# Seed 07 — UX polish and edge cases

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/assignment.md`
- `.agents/context/api.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- all implemented screens

Task:

Polish UX without changing the architecture unnecessarily.

Requirements:

1. Create reusable widgets for loading, error, and empty states where it reduces duplication.
2. Check all screens:
   - `StopsScreen`,
   - `DeparturesScreen`,
   - `VehicleMapScreen`.
3. Add user-friendly messages for:
   - missing token,
   - invalid token/unauthorized,
   - network failure,
   - timeout,
   - empty response,
   - no vehicle position.
4. Format departure times clearly.
5. Format delays clearly.
6. Show last known map update or stale state clearly.
7. Avoid debug prints and noisy logs.
8. Do not add bonus features or large refactors.

Run:

```bash
dart format .
flutter analyze
flutter test
```

Output:

- changed files,
- UX changes,
- checks run and results.
