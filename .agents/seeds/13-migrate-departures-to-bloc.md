# Seed 13 — Migrate Departures To Bloc

Use the project rules in this repository.

Implement only this seed.

Context:

- Stops migration is complete.
- Preserve the current departures UI, pull-to-refresh, and vehicle selection
  behavior.

Scope:

- Create departures domain repository interface and use cases where not already
  present.
- Create departures data datasource and repository implementation using the
  existing Golemio API client and DTO parsing.
- Add a Departures Bloc:
  - load selected stop,
  - retry after error,
  - refresh without replacing the screen with initial loading,
  - expose empty/error/loading/data/refreshing state.
- Preserve the isolated departureboards stop filter parameter. Do not change it
  without proof from Golemio docs/API.
- Keep the vehicle map action callback behavior.
- Do not migrate vehicle map in this seed.
- Do not change token handling or endpoint parameters.

Testing:

- Add focused Bloc tests for load, error, retry, refresh, empty, and vehicle ID
  availability if practical.
- Keep widget tests offline.
- Tests must not call the real Golemio API.
- Tests must not require `GOLEMIO_API_TOKEN`.

Verification:

```bash
dart format .
flutter analyze
flutter test
```

Also run:

```bash
git diff --stat
git diff --check
git status --short
```

Security:

- No real token.
- No `.env.local`.
- No local machine path.

Recommended commit message:

```text
refactor: migrate departures feature to Bloc
```
