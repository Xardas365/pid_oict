# Seed 04 — Stops screen

Use the project rules in this repository.

First read:

- `AGENTS.md`
- `.agents/context/assignment.md`
- `.agents/context/architecture.md`
- `.agents/context/verification.md`
- `StopsRepository`
- existing app entrypoint and navigation

Task:

Implement the stop list screen.

Requirements:

1. Create `StopsScreen`.
2. Load stops through `StopsRepository`.
3. Show loading, error, empty, and success states.
4. Add local search/filtering by stop name.
5. Keep filtering separate from API fetching.
6. Show a retry action for recoverable errors.
7. On stop tap, navigate to `DeparturesScreen` and pass the selected `Stop`.
8. Keep navigation simple.
9. Add a small test for filtering logic or a widget test if practical.

Do not implement departures UI or map UI beyond minimal route placeholders needed for compilation.

Run:

```bash
dart format .
flutter analyze
flutter test
```

Output:

- changed files,
- navigation choice,
- checks run and results.
